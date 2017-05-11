/*
 * -------------------------------------------------------------------------------
 * comm.js
 *
 * Handle the Socket.io interface with the clients, the IPC interface with the
 * other cluster worker processes, and the RxJS interface to the other modules
 * in this worker process. Expose only RxJS streams to the other modules and
 * leave the Socket.io and IPC interfaces private to this module.
 *
 * There are three communication streams (system, site, and data) that are active
 * across each of the three interfaces (Socket.io, IPC, and RxJS). All messages
 * created are delivered to all subscribers in the current process, to all
 * subscribers in other cluster processes, and to all subscribing clients
 * irrespective of which server process they are currently attached to.
 *
 * All messages are "wrapped" in a wrapper that contains the following fields:
 * - id         - a unique id for the message
 * - type       - one of system, site, or data
 * - updatedAt  - date/time in milliseconds of creation/update
 * - workerId   - the process.env.WORKER_ID that created/updated the message
 * - scope      - if specified, names the worker id that message is limited to
 * - data       - the payload
 *
 * The system stream:
 * - Purpose: server to client broadcast to subscribers. System messages pertain to
 *   the server's operations as opposed to application issues. Examples include
 *   a shutdown notice, shutdown canceled, notification that a worker process is
 *   dying, etc.
 * - Characteristics:
 *    - Client to server system messages are not allowed.
 *    - Messages are not aggregated on the server like site messages are. Instead
 *      messages are sent individually to all subscribers.
 *    - At subscription, the most recent message is not conveyed to the subscriber,
 *      only new messages after that point are delivered to that subscriber.
 *
 * The site stream:
 * - Purpose: server to server or server to client broadcast to subscribers. Site
 *   messages generally are for communication about statistics and facts about the
 *   Midwife-EMR instance itself at the application level. Examples might be the
 *   number of prenatalExams conducted by today or the number of patients waiting
 *   to be served.
 * - Characteristics:
 *    - Client to server site messages are not allowed.
 *    - The stream always conveys an object to subscribers containing all of the
 *      key/value pairs set up until that point in time. There is not a separate
 *      message delivered for each key/value pair because all key/values, no matter
 *      what process/module/function set it, will be aggregated to the object.
 *    - At subscription, the most recent message will be conveyed to the subscriber.
 *    - Whenever there is a change or addition of any key/value pair, a new message
 *      is delivered to subscribers with all of the key/value pairs.
 *    - Scope is always unspecified for site messages, which are delivered to all
 *      processes without exception.
 *
 * The data stream:
 * - Purpose: client to server process and server process to client broadcast to
 *   subscribers. All data management is handled through the data stream, including
 *   the client retrieving data or the server pushing data to interested clients or
 *   the client sending changed data, etc.
 * - Characteristics:
 *    - Client to server data messages are allowed.
 *    - Subscriptions to all data messages are not allowed, only subsets of data.
 *       - Allowable subscription levels:
 *          - Pregnancy id
 *          - Patient id
 *          - User id
 *          - Generally subscriptions are to the ids of major tables as opposed to
 *            the more detailed tables.
 *    - Sub-categories of data client to server messages.
 *       - Get data
 *          - Scope of message is automatically limited to receiving process, other
 *            processes on the server do not receive the message.
 *          - Data is returned to client.
 *          - Message is not broadcast to other clients.
 *          - ALTERNATIVE: subscribe to data against a BehaviorSubject, created on
 *            the fly, that returns the data as the first message and all changes
 *            to the data after that. ???
 *       - Subscribe to changes for specific data
 *          - Scope of message allows notification of all processes.
 *       - Update data
 *          - Update is handled be receiving process.
 *          - Other processes are notified of change.
 *
 *
 * -------------------------------------------------------------------------------
 */

var rx = require('rx')
  , uuid = require('uuid')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('./config')
  , User = require('./models').User
  , getLookupTable = require('./routes/comm/lookupTables').getLookupTable
  , saveUser = require('./routes/comm/userRoles').saveUser
  , checkInOut = require('./routes/comm/checkInOut').checkInOut
  , savePrenatal = require('./routes/comm/pregnancy').savePrenatal
  , buildChangeObject = require('./changes').buildChangeObject
  , socketToUserInfo = require('./commUtils').socketToUserInfo
  , sendData = require('./commUtils').sendData
  , isInitialized = false
  , ioSystem          // our system socket
  , ioSite            // our site socket
  , ioData            // our data socket
  , sessionMiddleware
  , rxSite            // Stream for site messages
  , rxSystem          // Stream for system messages
  , rxData            // Stream for data messages
  , cntSystem = 0
  , cntSite = 0
  , cntData = 0
  , siteSubject
  , siteSubjectData
  , systemSubject
  , dataSubject
  , CONST = require('./commUtils').getConstants('CONST')
  , DATA_CHANGE = require('./commUtils').getConstants('DATA_CHANGE')  // Note: used in old code only.
  , SYSTEM_LOG = 'SYSTEM_LOG'
  , DATA_TABLE_REQUEST = 'DATA_TABLE_REQUEST'
  , DATA_TABLE_SUCCESS = 'DATA_TABLE_SUCCESS'
  , DATA_TABLE_FAILURE = 'DATA_TABLE_FAILURE'
  , ADD_USER_REQUEST = 'ADD_USER_REQUEST'
  , SAVE_PRENATAL_REQUEST = 'SAVE_PRENATAL_REQUEST'
  , CHECK_IN_OUT_REQUEST = 'CHECK_IN_OUT_REQUEST'
  , DATA_SELECT = 'SELECT'                    // SELECT event in the data namespace.
  , DATA_SELECT_RESPONSE = 'SELECT_RESPONSE'  // SELECT_RESPONSE event in the data namespace.
  //
  // Elm Client stuff - corresponds with comm.js on the client.
  //
  , ADD = 'ADD'                             // data add request.
  , ADD_RESPONSE = 'ADD_RESPONSE'           // data add response.
  , CHG = 'CHG'                             // data change request.
  , CHG_RESPONSE = 'CHG_RESPONSE'           // data change response.
  , DEL = 'DEL'                             // data delete request.
  , DEL_RESPONSE = 'DEL_RESPONSE'           // data delete response.
  , ADHOC = 'ADHOC'                         // data adhoc request.
  , ADHOC_RESPONSE = 'ADHOC_RESPONSE'       // data adhoc response.
  , ADHOC_LOGIN = 'ADHOC_LOGIN'             // adhocType from the client.
  , ADHOC_USER_PROFILE = 'ADHOC_USER_PROFILE' // AdhocType from the client.
  , ADHOC_USER_PROFILE_UPDATE = 'ADHOC_USER_PROFILE_UPDATE'
  , TABLE_medicationType = 'medicationType'
  , TABLE_user = 'user'
  , updateMedicationType = require('./routes/comm/lookupTables').updateMedicationType
  , addMedicationType = require('./routes/comm/lookupTables').addMedicationType
  , delMedicationType = require('./routes/comm/lookupTables').delMedicationType
  , addUser = require('./routes/comm/userRoles').addUser
  , delUser = require('./routes/comm/userRoles').delUser
  , updateUser = require('./routes/comm/userRoles').updateUser
  , updateUserProfile = require('./routes/comm/userRoles').updateUserProfile
  , getUserProfile = require('./routes/comm/userRoles').getUserProfile
  , returnLogin = require('./util').returnLogin
  , returnUserProfile = require('./util').returnUserProfile
  , returnUserProfileUpdate = require('./util').returnUserProfileUpdate
  , returnStatusADD = require('./util').returnStatusADD
  , returnStatusCHG = require('./util').returnStatusCHG
  , returnStatusDEL = require('./util').returnStatusDEL
  , returnStatusSELECT = require('./util').returnStatusSELECT
  , LoginFailErrorCode = require('./util').LoginFailErrorCode
  , LoginSuccessErrorCode = require('./util').LoginSuccessErrorCode
  , LoginSuccessDifferentUserErrorCode = require('./util').LoginSuccessDifferentUserErrorCode
  , UserProfileSuccessErrorCode = require('./util').UserProfileSuccessErrorCode
  , UserProfileFailErrorCode = require('./util').UserProfileFailErrorCode
  , UserProfileUpdateSuccessErrorCode = require('./util').UserProfileUpdateSuccessErrorCode
  , UserProfileUpdateFailErrorCode = require('./util').UserProfileUpdateFailErrorCode
  , NoErrorCode = require('./util').NoErrorCode
  , SessionExpiredErrorCode = require('./util').SessionExpiredErrorCode
  , SqlErrorCode = require('./util').SqlErrorCode
  , UnknownTableErrorCode = require('./util').UnknownTableErrorCode
  , UnknownErrorCode = require('./util').UnknownErrorCode
  , assertModule = require('./comm_assert')
  , DO_ASSERT = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
  ;


/* --------------------------------------------------------
 * getFormattedLogMsg()
 *
 * Returns the message passed in the format expected by
 * the logs.
 *
 * param       msg
 * return      message
 * -------------------------------------------------------- */
var getFormattedLogMsg = function(msg) {
  var id = process.env.WORKER_ID? process.env.WORKER_ID: 0
  , theDate = moment().format('YYYY-MM-DD HH:mm:ss.SSS')
  , message = id + '|' + theDate + ': ' + msg
  ;
  return message;
};

/* --------------------------------------------------------
 * writeLog()
 *
 * Writes a log message to the console.
 *
 * NOTE: WE DO NOT USE THESE FUNCTIONS FROM util.js BECAUSE
 * OF CIRCULAR REFERENCES AND BECAUSE THE FUNCTIONS IN util.js
 * USE sendSystem() TO DISTRIBUTE MESSAGES TO THE administrators
 * AND LOGGING MESSAGES FROM THE comm LIBRARY DO NOT ALWAYS
 * NEED THIS.
 *
 * param      msg
 * param      logType
 * return     message
 * -------------------------------------------------------- */
var INFO = 1
  , WARN = 2
  , ERROR = 3
  ;
var writeLog = function(msg, logType) {
  var fn = 'info'
    , message = getFormattedLogMsg(msg)
    ;
  if (logType === WARN || logType === ERROR) fn = 'error';
  console[fn](message);
  return message;
};

/* --------------------------------------------------------
 * logCommInfo()
 *
 * Writes an informative message to the console.
 *
 * NOTE: WE DO NOT USE THESE FUNCTIONS FROM util.js BECAUSE
 * OF CIRCULAR REFERENCES AND BECAUSE THE FUNCTIONS IN util.js
 * USE sendSystem() TO DISTRIBUTE MESSAGES TO THE administrators
 * AND LOGGING MESSAGES FROM THE comm LIBRARY DO NOT ALWAYS
 * NEED THIS.
 *
 * param      msg
 * param      doSysMsg - boolean whether to write to socket SYSTEM_LOG
 * return     undefined
 * -------------------------------------------------------- */
var logCommInfo = function(msg, doSysMsg) {
  var message = writeLog(msg, INFO);
  if (doSysMsg) sendSystem(SYSTEM_LOG, message);
};

/* --------------------------------------------------------
 * logCommWarn()
 *
 * Writes a warning message to the console.
 *
 * NOTE: WE DO NOT USE THESE FUNCTIONS FROM util.js BECAUSE
 * OF CIRCULAR REFERENCES AND BECAUSE THE FUNCTIONS IN util.js
 * USE sendSystem() TO DISTRIBUTE MESSAGES TO THE administrators
 * AND LOGGING MESSAGES FROM THE comm LIBRARY DO NOT ALWAYS
 * NEED THIS.
 *
 * param      msg
 * param      doSysMsg - boolean whether to write to socket SYSTEM_LOG

 * return     undefined
 * -------------------------------------------------------- */
var logCommWarn = function(msg, doSysMsg) {
  var message = writeLog(msg, WARN);
  if (doSysMsg) sendSystem(SYSTEM_LOG, message);
};

/* --------------------------------------------------------
 * logCommError()
 *
 * Writes an error message to the console.
 *
 * NOTE: WE DO NOT USE THESE FUNCTIONS FROM util.js BECAUSE
 * OF CIRCULAR REFERENCES AND BECAUSE THE FUNCTIONS IN util.js
 * USE sendSystem() TO DISTRIBUTE MESSAGES TO THE administrators
 * AND LOGGING MESSAGES FROM THE comm LIBRARY DO NOT ALWAYS
 * NEED THIS.
 *
 * param      msg
 * param      doSysMsg - boolean whether to write to socket SYSTEM_LOG

 * return     undefined
 * -------------------------------------------------------- */
var logCommError = function(msg, doSysMsg) {
  var message = writeLog(msg, ERROR);
  if (doSysMsg) sendSystem(SYSTEM_LOG, message);
};

/* --------------------------------------------------------
 * wrap()
 *
 * Wrap data in a message wrapper per the message type. The
 * message id, type, updatedAt, workerID, and processedBy
 * fields are automatically set. This is only done when new
 * data is sent into the stream.
 *
 * The workerId field contains the id of the process that
 * initiated the message.
 *
 * The processedBy field contains the ids of the processes
 * that have received the message via IPC or, as is the
 * case here, when the message was created. This is used to
 * prevent messages from bouncing between processes without
 * end.
 *
 * param       type
 * param       data
 * param       scope - optional, for system messages only
 * return      message object
 * -------------------------------------------------------- */
var wrap = function(type, data, scope) {
  return {
    id: uuid.v1()
    , type: type
    , updatedAt: Date.now()
    , workerId: process.env.WORKER_ID
    , processedBy: [process.env.WORKER_ID]
    , scope: type == CONST.TYPE.SITE? undefined:
             type == CONST.TYPE.DATA? undefined:
             type == CONST.TYPE.SYSTEM? scope: undefined
    , data: data? data: {}
  };
};
// Initialize siteSubjectData with wrapper and empty data set.
siteSubjectData = wrap(CONST.TYPE.SITE);

/* --------------------------------------------------------
 * makeSend()
 *
 * Create a function that handles sending a certain type
 * of message.
 *
 * param       type     - type: site, system, or data
 * return      function
 * -------------------------------------------------------- */
function makeSend(type) {
  return function(key, val, scope) {
    var data = {};
    var wrapped;
    switch (type) {
      case CONST.TYPE.SITE:
        // --------------------------------------------------------
        // For site messages, the most recent copy is stored so
        // update the data portion with the key/val pair, refresh
        // the wrapper and notify subscribers. Return the unique
        // message id to the caller.
        // --------------------------------------------------------
        data[key] = val;
        siteSubjectData = wrap(type, _.extendOwn(siteSubjectData.data, data));
        siteSubject.onNext(siteSubjectData);
        return siteSubjectData.id;

      case CONST.TYPE.SYSTEM:
        // --------------------------------------------------------
        // For system messages, there is no aggregation and there
        // is an optional scope parameter allowed.
        // --------------------------------------------------------
        data[key] = val;
        wrapped = wrap(type, data, scope);
        if (isInitialized) systemSubject.onNext(wrapped);
        break;

      default:
        logCommError('Error: makeSend() unimplemented for this type: ' + type);
    }
  };
};

/* --------------------------------------------------------
 * sendSite()
 * sendSystem()
 *
 * Send a message of a certain type.
 *
 * param       key      - the key of the key/val pair
 * param       val      - the value of the key/val pair
 * param       scope    - the scope of the message (system only)
 * return      id       - the unique message id
 * -------------------------------------------------------- */
var sendSite = makeSend(CONST.TYPE.SITE);
var sendSystem = makeSend(CONST.TYPE.SYSTEM);
// Note: sendData() has been refactored into commUtils.js.
//var sendData = makeSend(CONST.TYPE.DATA);

/* --------------------------------------------------------
 * subscribeSite()
 *
 * Allows other modules to subscribe to site type messages.
 *
 * param       onNext       - function to call upon msg
 * param       onError      - function to call upon error
 * param       onCompleted  - function to call when done
 * return      subscription object
 * -------------------------------------------------------- */
var subscribeSite = function(onNext, onError, onCompleted) {
  return siteSubject.subscribe(onNext, onError, onCompleted);
};

/* --------------------------------------------------------
 * subscribeSystem()
 *
 * Allows other modules to subscribe to system type messages.
 *
 * param       onNext       - function to call upon msg
 * param       onError      - function to call upon error
 * param       onCompleted  - function to call when done
 * return      subscription object
 * -------------------------------------------------------- */
var subscribeSystem = function(onNext, onError, onCompleted) {
  return systemSubject.subscribe(onNext, onError, onCompleted);
};

/* --------------------------------------------------------
 * subscribeData()
 *
 * Allows other modules to subscribe to data type messages.
 *
 * param       onNext       - function to call upon msg
 * param       onError      - function to call upon error
 * param       onCompleted  - function to call when done
 * return      subscription object
 * -------------------------------------------------------- */
var subscribeData = function(onNext, onError, onCompleted) {
  return dataSubject.subscribe(onNext, onError, onCompleted);
};

/* --------------------------------------------------------
  * isValidSocketSession()
  *
  * Determine if the socket has a valid session and return
  * the boolean answer.
  *
  * param       socket
  * return      boolean
  * -------------------------------------------------------- */
var isValidSocketSession = function(socket) {
  if (DO_ASSERT) assertModule.isValidSocketSession(socket);
  var notExpired = false;
  var isValid = socket &&
                socket.request &&
                socket.request.session &&
                socket.request.session.roleInfo &&
                socket.request.session.roleInfo.isAuthenticated? true: false;
  if (isValid && socket.request.session.cookie._expires) {
    notExpired = moment().isBefore(moment(socket.request.session.cookie._expires, moment.ISO_8601));
  }
  return !! (isValid && notExpired);
};

/* --------------------------------------------------------
 * touchSocketSession()
 *
 * Touch the session within the socket passed in order to
 * extend the expiry timeout accordingly.
 *
 * param       socket
 * return      undefined
 * -------------------------------------------------------- */
var touchSocketSession = function(socket) {
  if (DO_ASSERT) assertModule.touchSocketSession(socket);
  socket.request.session.touch();
};

/* --------------------------------------------------------
  * getSocketSessionId()
  *
  * Return the socket session id if the session is valid and
  * has one, otherwise returns an empty string.
  *
  * param       socket
  * return      string
  * -------------------------------------------------------- */
var getSocketSessionId = function(socket) {
  if (! isValidSocketSession(socket)) return '';
  return socket.request.sessionID? socket.request.sessionID: '';
};

/* --------------------------------------------------------
 * loginUser()
 *
 * Find the user by username. If there is no user with the
 * given username, or the password is not correct, set the
 * user to 'false' in order to indicate failure. Otherwise,
 * return the authenticated user.
 *
 * param       username
 * param       password
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var loginUser = function(username, password, cb) {
  User.findByUsername(username, function(err, user) {
    if (!user) { return cb(null, false, { message: 'Unknown user ' + username }); }
    if (user.get('status') != 1) {
      return cb(null, false, {
        message: username + ' is not an active account.'
      });
    }
    user.checkPassword(password, function(err, same) {
      if (err) return cb(err);
      if (same) {
        return cb(null, user);
      } else {
        return cb(null, false, {message: 'Invalid password'});
      }
    });
  });
};

var getFuncForTableOp = function(table, op) {
  var func = void 0;
  switch (table) {
    case TABLE_medicationType:
      switch (op) {
        case ADD: func = addMedicationType; break;
        case CHG: func = updateMedicationType; break;
        case DEL: func = delMedicationType; break;
      }
      break;
    case TABLE_user:
      switch (op) {
        case ADD: func = addUser; break;
        case CHG: func = updateUser; break;
        case DEL: func = delUser; break;
      }
      break;
  }
  return func;
};

/* --------------------------------------------------------
 * handleData()
 *
 * Handle a Socket.io event in the DATA namespace.
 *
 * param        evtName
 * param        payload
 * param        socket
 * return       undefined
 * -------------------------------------------------------- */
var handleData = function(evtName, payload, socket) {
  if (DO_ASSERT) assertModule.handleData(evtName, payload, socket);
  var wrapper = JSON.parse(payload);
  var table = wrapper.table? wrapper.table: void 0
    , data = wrapper.data? wrapper.data: {}
    , recId = data? data.id: -1
    , userInfo = socketToUserInfo(socket)
    , retAction
    , dataFunc
    , returnStatusFunc
    , responseEvt
  ;
  console.log('handleData() for ' + evtName + ' with payload of: ' + payload);
  switch (evtName) {
    case ADD:
      if (! table || ! data || (! recId < 0) ) {
        // TODO: send the proper msg back to the client to this effect.
        console.log('Data ADD request: Improper data sent from client!');
        return;
      }
      returnStatusFunc = returnStatusADD;
      responseEvt = ADD_RESPONSE;
      break;

    case CHG:
      if (! table || ! data || recId === -1 || data.stateId === -1) {
        // TODO: send the proper msg back to the client to this effect.
        console.log('Data CHG request: Improper data sent from client!');
        return;
      }
      returnStatusFunc = returnStatusCHG;
      responseEvt = CHG_RESPONSE;
      break;

    case DEL:
      if (! table || ! data || recId === -1 || data.stateId === -1) {
        // TODO: send the proper msg back to the client to this effect.
        console.log('Data DEL request: Improper data sent from client!');
        return;
      }
      returnStatusFunc = returnStatusDEL;
      responseEvt = DEL_RESPONSE;
      break;

    default:
      console.log('UNKNOWN event of ' + evtName + ' in handeData().');
      retAction = returnStatusFunc(table, data.id, data.stateId, false, UnknownErrorCode, "This event cannot be handled by the server: " + evtName + '.');
      return socket.emit(responseEvt, JSON.stringify(retAction));
  }

  dataFunc = getFuncForTableOp(table, evtName);
  if (! dataFunc) {
    retAction = returnStatusFunc(table, data.id, data.stateId, false, UnknownErrorCode, "This table cannot be handled by the server.");
    return socket.emit(responseEvt, JSON.stringify(retAction));
  }

  if (! isValidSocketSession(socket)) {
    retAction = returnStatusFunc(table, data.id, data.stateId, false, SessionExpiredErrorCode, "Your session has expired.");
    return socket.emit(responseEvt, JSON.stringify(retAction));
  } else touchSocketSession(socket);

  if (! userInfo) {
    // NOTE: this is an error that occurs and I have not been able to track down yet.
    console.log('ERROR: userInfo object not populated in comm.js handleData(). ABORTING!');
    return;
  }

  dataFunc(data, userInfo, function(err, success, additionalData) {
    var errMsg;
    if (err) {
      logCommError(err);
      errMsg = err.message? err.message: err;
      if (evtName === ADD) {
        retAction = returnStatusFunc(table, data.id, data.id, false, SqlErrorCode, errMsg);
      } else {
        retAction = returnStatusFunc(table, data.id, data.stateId, false, SqlErrorCode, errMsg);
      }
      return socket.emit(responseEvt, JSON.stringify(retAction));
    }
    if (evtName == ADD) {
      retAction = returnStatusFunc(table, data.id, additionalData.id, true);
    } else {
      retAction = returnStatusFunc(table, data.id, data.stateId, true);
    }
    socket.emit(responseEvt, JSON.stringify(retAction));

    // --------------------------------------------------------
    // Write out to the log and SYSTEM_LOG for administrators.
    // --------------------------------------------------------
    return logCommInfo(userInfo.user.username + ": " + table + ": " + evtName, true);
  });

};

var handleLogin = function(json, socket) {
  if (DO_ASSERT) assertModule.handleLogin(json, socket);
  var username = json.data && json.data.username ? json.data.username: void 0;
  var password = json.data && json.data.password ? json.data.password: void 0;
  var isDifferentUser = false;
  var retAction;
  var msg;

  if (! username || ! password ) {
    msg = 'Username and/or password not supplied.';
    retAction = returnLogin(false, LoginFailErrorCode, msg);
    return socket.emit(ADHOC_RESPONSE, JSON.stringify(retAction));
  }

  // Check if this is the same user as is possibly in the session now.
  if (socket.request.session &&
      socket.request.session.user &&
      socket.request.session.user.username &&
      socket.request.session.user.username !== username) {
    isDifferentUser = true;
  }


  // Login the user.
  loginUser(username, password, function(err, user, msgObj) {
    if (err) {
      // Unknown failure, not just a failed login.
      console.log(err);
      retAction = returnLogin(false, LoginFailErrorCode, err);
      return socket.emit(ADHOC_RESPONSE, JSON.stringify(retAction));
    }

    if (user) {
      if (isDifferentUser) {
        sendUserProfile(socket, user.toJSON(), LoginSuccessDifferentUserErrorCode);
      } else {
        sendUserProfile(socket, user.toJSON(), LoginSuccessErrorCode);
      }
    } else {
      // Failed login.
      console.log(msgObj);
      retAction = returnLogin(false, LoginFailErrorCode, msgObj.message);
      return socket.emit(ADHOC_RESPONSE, JSON.stringify(retAction));
    }
  });
};

var handleUserProfile = function(socket, data, userInfo) {
  if (DO_ASSERT) assertModule.handleUserProfile(socket, data, userInfo);
  var retAction;
  var errCode;
  if (isValidSocketSession(socket)) {
    if (socket.request.session.user) {
      if (data && userInfo) {
        // User is updating (hopefully) their own profile. updateUserProfile()
        // will sanity check that they are only updating their own profile.
        updateUserProfile(data, userInfo, function(err, success, id) {
          if (err) {
            console.log(err);
            retAction = returnUserProfileUpdate(false, UserProfileUpdateFailErrorCode);
            return socket.emit(ADHOC_RESPONSE, JSON.stringify(retAction));
          }
          errCode = UserProfileUpdateFailErrorCode;
          if (success) errCode = UserProfileUpdateSuccessErrorCode;
          retAction = returnUserProfileUpdate(!!success, errCode);
          socket.emit(ADHOC_RESPONSE, JSON.stringify(retAction));

          // --------------------------------------------------------
          // Write out to the log and SYSTEM_LOG for administrators.
          // --------------------------------------------------------
          return logCommInfo(userInfo.user.username + ": updated user profile", true);
        });
      } else {
        // Get the user profile information.
        getUserProfile(socket.request.session.user.id, function(err, success, userObj) {
          if (err || ! success) {
            console.log(err);
            return sendUserProfile(socket, userObj, UserProfileFailErrorCode);
          } else {
            return sendUserProfile(socket, userObj, UserProfileSuccessErrorCode);
          }
        });
      }
    } else {
      // Do not have the user in session, so fail.
      sendUserProfile(socket, void 0, UserProfileFailErrorCode);
    }
  } else {
    // Session has expired, so fail.
    sendUserProfile(socket, void 0, UserProfileFailErrorCode);
  }
};

/* --------------------------------------------------------
 * sendUserProfile()
 *
 * Updates the session with user information, resets the
 * session expiry, and sends the user profile to the client.
 *
 * param       socket
 * param       user - assumes is a simple JSON object.
 * param       errCode - error code to return to client.
 * return      undefined
 * -------------------------------------------------------- */
var sendUserProfile = function(socket, user, errCode) {
  if (DO_ASSERT) assertModule.sendUserProfile(socket, user, errCode);
  var retAction;
  // Reset session timeout.
  touchSocketSession(socket);

  // Save user information into the session and return response to client.
  if (user) {
    socket.request.session.roleInfo = {
      isAuthenticated: errCode === LoginSuccessErrorCode ||
        errCode === UserProfileSuccessErrorCode ||
        errCode === LoginSuccessDifferentUserErrorCode? true: false,
      roleName: user.roleName? user.roleName: user.role && user.role.name? user.role.name: ''
    };

    socket.request.session.save(function(err) {
      if (err) {
        console.log('ERROR: login successful but unable to save to session.');
        console.log(err);
      }

      switch (errCode) {
        case LoginSuccessErrorCode:
          retAction = returnLogin(true, errCode);
          retAction.isLoggedIn = true;
          break;
        case LoginSuccessDifferentUserErrorCode:
          retAction = returnLogin(true, errCode);
          retAction.isLoggedIn = true;
          break;
        case LoginFailErrorCode:
          retAction = returnLogin(false, errCode);
          break;
        case UserProfileSuccessErrorCode:
          retAction = returnUserProfile(true, errCode);
          retAction.isLoggedIn = true;
          break;
        case UserProfileFailErrorCode:
          retAction = returnUserProfile(false, errCode);
          break;
        default:
          throw new Error('Unknown errCode of ' + errCode + ' in comm/sendUserProfile().');
      }

      if (retAction && user) {
        _.extendOwn(retAction, _.pick(user,
            ['id', 'userId', 'username', 'firstname', 'lastname', 'email',
            'lang', 'shortName', 'displayName', 'role_id', 'roleName'])
        );
        // User Profile uses userId instead of id. Massage data into correct format.
        if (! retAction.userId && user.id) {
          retAction.userId = user.id;
          if (retAction.id) delete retAction.id;
        }
        // Assumes roleName assigned to session earlier in this function.
        if (! retAction.roleName) retAction.roleName = socket.request.session.roleInfo.roleName;
        socket.emit(ADHOC_RESPONSE, JSON.stringify(retAction));
      }
    });
  }

};

/* --------------------------------------------------------
 * init()
 *
 * Initialize the three communication interfaces that this
 * module uses: Socket.io for the clients, IPC for
 * inter-process communication, and RxJS for intra-module
 * communication within this server process.
 *
 * Each cluster worker process should call init() for itself
 * to allow proper communication between modules within a
 * worker process, cross-process communication, and socket
 * server communication.
 *
 * param       io             - the Socket.io socket
 * param       sessionMiddle  - authorization routine
 * return
 * -------------------------------------------------------- */
var init = function(io, sessionMiddle) {
  if (isInitialized) return;
  isInitialized = true;

  // --------------------------------------------------------
  // Handle messages from other worker processes.
  // --------------------------------------------------------
  process.on('message', function(wrapper) {
    var data = wrapper.data;
    switch (wrapper.type) {
      case CONST.TYPE.DATA:
        dataSubject.onNext(data);
        break;
      case CONST.TYPE.SITE:
        // --------------------------------------------------------
        // Insure that we don't process messages that we have already
        // received from other processes by checking for our own
        // process id in the message and putting it there if not found.
        // --------------------------------------------------------
        if (data.processedBy && _.contains(data.processedBy, process.env.WORKER_ID)) {
          return;
        }
        data.processedBy.push(process.env.WORKER_ID);

        // --------------------------------------------------------
        // Completely replace siteSubjectData, including wrapper,
        // with what we received from the other process, then
        // notify subscribers in this process. Be careful not to
        // overwrite any new, yet unpublished key/val pairs in
        // the existing siteSubjectData.data due to a race condition.
        // --------------------------------------------------------
        siteSubjectData.id = data.id;
        siteSubjectData.type = data.type;
        siteSubjectData.updatedAt = data.updatedAt;
        siteSubjectData.workerId = data.workerId;
        siteSubjectData.scope = undefined;    // by definition for site
        siteSubjectData.data = _.extendOwn(siteSubjectData.data, data.data);
        siteSubject.onNext(siteSubjectData);
        break;

      case CONST.TYPE.SYSTEM:
        // --------------------------------------------------------
        // We just received a message from the other process so we
        // check to see if our process id is already in the
        // processedBy field. If it is, we drop it because we have
        // already handled this message, else we add our process id
        // and send the message on it's way within our process.
        // --------------------------------------------------------
        if (! _.contains(data.processedBy, process.env.WORKER_ID)) {
          data.processedBy.push(process.env.WORKER_ID);
          systemSubject.onNext(data);
        }
        break;

      default:
        // --------------------------------------------------------
        // There are other messages that we are not interested in.
        // --------------------------------------------------------
        //logCommInfo('Client: Received UNHANDLED msg: ' + JSON.stringify(wrapper));
    }
  });


  // ========================================================
  // ========================================================
  // Configure the RxJS Streams.
  // ========================================================
  // ========================================================

  // --------------------------------------------------------
  // siteSubject is a BehaviorSubject which always provides
  // subscribers with the latest message provided. All key/val
  // pairs sent using sendSite() are used to extend the
  // siteSubjectData object.
  // --------------------------------------------------------
  siteSubject = new rx.BehaviorSubject(siteSubjectData);

  // --------------------------------------------------------
  // Pass the site data to the other cluster processes.
  // --------------------------------------------------------
  var siteSubscription = siteSubject.subscribe(
    function(data) {
      // Empty data, likely due to first message, don't send out.
      if (data && data.data && _.isEmpty(data.data)) return;
      // Message is from another process already so don't send out.
      if (data && data.workerId && data.workerId !== process.env.WORKER_ID) {
        return;
      }
      process.send({type: CONST.TYPE.SITE, data: data});
    },
    function(err) {
      logCommError('Error: ' + err);
    },
    function() {
      logCommInfo('siteSubject completed.');
    }
  );

  // --------------------------------------------------------
  // systemSubject is a normal rx.Subject and key/value pairs
  // are not aggregated but sent out individually.
  // --------------------------------------------------------
  systemSubject = new rx.Subject();

  var systemSubscription = systemSubject.subscribe(
    function(data) {
      // Message is from another process already so don't send out.
      if (data && data.workerId && data.workerId !== process.env.WORKER_ID) {
        return;
      }
      // Message is limited by scope to this process only so don't send out.
      if (data && data.scope && data.scope === process.env.WORKER_ID) {
        return;
      }
      process.send({type: CONST.TYPE.SYSTEM, data: data});
    },
    function(err) {
      logCommError('Error: ' + err);
    },
    function() {
      logCommInfo('systemSubject completed.');
    }
  );

  // --------------------------------------------------------
  // Whatever is received here is sent to the sockets.
  // --------------------------------------------------------
  dataSubject = new rx.Subject();

  // ========================================================
  // ========================================================
  // Configure the Socket.io sockets.
  // ========================================================
  // ========================================================

  // --------------------------------------------------------
  // Configure the sockets.
  // Integrate Express sessions into Socket.io.
  // See: https://stackoverflow.com/a/25618636
  // --------------------------------------------------------
  ioSystem = io.of('/system');
  ioData = io.of('/data');
  ioSite = io.of('/site');
  sessionMiddleware = sessionMiddle;
  ioSystem.use(function(socket, next) {
    sessionMiddleware(socket.request, socket.request.res, next);
  });
  ioSite.use(function(socket, next) {
    sessionMiddleware(socket.request, socket.request.res, next);
  });
  ioData.use(function(socket, next) {
    sessionMiddleware(socket.request, socket.request.res, next);
  });

  // --------------------------------------------------------
  // The system namespace.
  // Purpose: Server to client broadcast of anything regarding
  //          the operation of this instance of the Midwife-EMR
  //          system. This does not handle client to server
  //          communication.
  // Examples:
  //  - pending shutdown
  //  - shutdown
  //  - suspend
  //  - unsuspend
  //  - cluster worker process failure
  // --------------------------------------------------------
  ioSystem.on('connection', function(socket) {
    var systemSubscription;
    socket.on('disconnect', function() {
      systemSubscription.dispose();
      cntSystem--;
    });
    cntSystem++;

    // --------------------------------------------------------
    // Send all system messages out to the authenticated clients.
    // --------------------------------------------------------
    systemSubscription = systemSubject.subscribe(
      function(data) {
        // Don't do work unless logged in. This can happen while
        // we still have some client code running phase 1.
        if (! isValidSocketSession(socket)) {
          return;
        }

        // --------------------------------------------------------
        // Special handling for SYSTEM_LOG messages: only users with
        // the administrator role get these messages.
        // --------------------------------------------------------
        if (data.data && _.has(data.data, SYSTEM_LOG)) {
          if (socket.request.session.roleInfo.roleName !== 'administrator') {
            return;
          }
        }
        socket.emit(CONST.TYPE.SYSTEM, data);
      },
      function(err) {
        logCommError('Error: ' + err);
      },
      function() {
        logCommInfo('systemSubject completed.');
      }
    );
  });

  // --------------------------------------------------------
  // The site namespace.
  // Purpose: Server to client broadcast of anything regarding
  //          stats about the current Midwife-EMR instance.
  //          This does not handle client to server communication.
  //
  // Note that each message to the client contains the entirety
  // of the site messages in one object.
  //
  // Examples:
  //  - number of connected clients
  //  - number of prenatal exams completed today, this week, month
  //  - number of patients waiting to be served
  //  - number of logged in staff
  // --------------------------------------------------------
  ioSite.on('connection', function(socket) {
    var siteSubscription;
    socket.on('disconnect', function() {
      siteSubscription.dispose();
      cntSite--;
    });
    cntSite++;

    // --------------------------------------------------------
    // Send all site messages out to the authenticated clients.
    // --------------------------------------------------------
    siteSubscription = siteSubject.subscribe(
      function(data) {
        // Don't do work unless logged in.
        if (! isValidSocketSession(socket)) return;
        socket.emit(CONST.TYPE.SITE, data);
      },
      function(err) {
        logCommInfo('Error: ' + err);
      },
      function() {
        logCommInfo('siteSubject completed.');
      }
    );
  });

  // --------------------------------------------------------
  // The data namespace.
  // Purpose: Bi-directional communication between each client
  //          and the server in regard to Midwife-EMR data.
  //          This may include patient, pregnancy, user, or
  //          other data that is stored in the database. Allows
  //          clients to request data, write data, and otherwise
  //          interact with data. Server pushes data updates to
  //          clients per client subscriptions.
  // Examples:
  //  - search
  //  - get pregnancy
  //  - write new field value
  //  - receive update on field value another client changed
  // --------------------------------------------------------
  ioData.on('connection', function(socket) {
    // TODO: report number of connections to data messages.
    socket.on('disconnect', function() {
      cntData--;
      console.log('Number data websocket connections: ' + cntData);
    });
    cntData++;
    console.log('Number data websocket connections: ' + cntData);

    // --------------------------------------------------------
    // ADHOC processing for the Elm client on the data channel.
    // --------------------------------------------------------
    socket.on(ADHOC, function(data) {
      if (DO_ASSERT) assertModule.ioData_socket_on_ADHOC(data);
      var json = JSON.parse(data);
      var adhocType = json.adhocType;
      var userInfo = socketToUserInfo(socket);

      switch (adhocType) {
        case ADHOC_LOGIN:
          handleLogin(json, socket);
          break;

        case ADHOC_USER_PROFILE:
          handleUserProfile(socket);
          break;

        case ADHOC_USER_PROFILE_UPDATE:
          handleUserProfile(socket, json.data, userInfo);
          break;

        default:
          console.log('UNKNOWN adhocType of ' + adhocType + ' encountered.');
      }

    });

    // --------------------------------------------------------
    // SELECT event for the Elm client.
    // --------------------------------------------------------
    socket.on(DATA_SELECT, function(data) {
      if (DO_ASSERT) assertModule.ioData_socket_on_DATA_SELECT(data);
      var json = JSON.parse(data);
      var retAction;

      if (! isValidSocketSession(socket)) {
        retAction = returnStatusSELECT(json, void 0, false, SessionExpiredErrorCode, "Your session has expired.");
        console.log(retAction);
        return socket.emit(DATA_SELECT_RESPONSE, JSON.stringify(retAction));
      } else touchSocketSession(socket);

      // --------------------------------------------------------
      // TODO: handle all tables, not just certain ones and handle
      // requests for individual records instead of all records.
      // --------------------------------------------------------
      if (json.table) {
        getLookupTable(json.table, json.id, json.pregnancy_id, json.patient_id, function(err, data) {
          if (err) {
            logCommError(err);
            retAction = returnStatusSELECT(json, void 0, false, SqlErrorCode, err.msg);
            return socket.emit(DATA_SELECT_RESPONSE, JSON.stringify(retAction));
          }
          retAction = returnStatusSELECT(json, data, true);
          return socket.emit(DATA_SELECT_RESPONSE, JSON.stringify(retAction));
        });
      } else {
        retAction = returnStatusSELECT(json, void 0, false, UnknownErrorCode, 'Table not specified.');
        return socket.emit(DATA_SELECT_RESPONSE, JSON.stringify(retAction));
      }
    });

    // --------------------------------------------------------
    // Data ADD request from the Elm client.
    // --------------------------------------------------------
    socket.on(ADD, function(payload) {
      if (DO_ASSERT) assertModule.ioData_socket_on_ADD(payload);
      handleData(ADD, payload, socket);
    });

    // --------------------------------------------------------
    // Data CHG request from the Elm client. Record will have
    // a stateId field with the client's transaction
    // id. This needs to be stripped and not inserted into DB,
    // but response needs to include it.
    // --------------------------------------------------------
    socket.on(CHG, function(payload) {
      if (DO_ASSERT) assertModule.ioData_socket_on_CHG(payload);
      handleData(CHG, payload, socket);
    });

    // --------------------------------------------------------
    // Data DEL request from the Elm client. Record will have
    // a stateId field with the client's transaction
    // id. This needs to be stripped and not inserted into DB,
    // but response needs to include it.
    // --------------------------------------------------------
    socket.on(DEL, function(payload) {
      if (DO_ASSERT) assertModule.ioData_socket_on_DEL(payload);
      handleData(DEL, payload, socket);
    });

    // ========================================================
    // ========================================================
    //
    //
    //
    // NOTE: SOME of the following code from the React/Redux
    // client that is no longer being used such as:
    // socket.on(DATA_TABLE_REQUEST, ...
    // socket.on(DATA_CHANGE, ...
    //
    // NOTE: this IS still being used:
    // dataSubscription = dataSubject.subscribe(
    //
    //
    // ========================================================
    // ========================================================

    // --------------------------------------------------------
    // DATA_TABLE_REQUEST: this is used to populate the lookup
    // tables on the client. Only certain tables are allowed.
    // --------------------------------------------------------
    socket.on(DATA_TABLE_REQUEST, function(data) {
      var action = JSON.parse(data);
      var retAction
      var table = action && action.payload && action.payload.table? action.payload.table: void 0;
      if (table) {
        logCommInfo(DATA_TABLE_REQUEST + ': ' + table);
        getLookupTable(table, function(err, data) {
          if (err) {
            logCommError(err);
            retAction = {
              type: DATA_TABLE_FAILURE,
              payload: {
                error: err
              }
            }
            return socket.emit(DATA_TABLE_FAILURE, JSON.stringify(retAction));
          }
          retAction = {
            type: DATA_TABLE_SUCCESS,
            payload: {
              table: table,
              data: data
            }
          }
          return socket.emit(DATA_TABLE_SUCCESS, JSON.stringify(retAction));
        });
      }
    });

    // --------------------------------------------------------
    // Handle a data change request from a client.
    // --------------------------------------------------------
    socket.on(DATA_CHANGE, function(data) {
      var action = JSON.parse(data)
        , retAction = _.extend({}, action)
        , payload = action && action.payload? action.payload: void 0
        , transaction = action && action.transaction? action.transaction: void 0
        , userInfo = socketToUserInfo(socket)
        , dataChangeFunc      // the function to handle the data change
        , payloadKey          // the key to store return object to caller
        , dataTableName       // the table name for the sendData operation
        , humanOpName         // the name of the operation for logging
        , errMsg = ''
        ;
      if (payload && transaction && userInfo) {
        // --------------------------------------------------------
        // Determine what action is required and handle unknown action types.
        // --------------------------------------------------------
        switch (action.type) {
          case ADD_USER_REQUEST:
            dataChangeFunc = saveUser;
            payloadKey = 'user';
            dataTableName = 'user';
            humanOpName = 'Add User';
            break;
          case CHECK_IN_OUT_REQUEST:
            dataChangeFunc = checkInOut;
            payloadKey = void 0;    // signify to merge with payload.
            dataTableName = 'priority';
            humanOpName = 'checkin/checkout';
            break;
          case SAVE_PRENATAL_REQUEST:
            dataChangeFunc = savePrenatal;
            payloadKey = 'preg';
            dataTableName = 'pregnancy';
            humanOpName = 'prenatal';
            break;

          default:
            errMsg = 'Comm: received unknown action.type: ' + action.type;
            break;
        }
        if (! dataChangeFunc || ! dataTableName) {
          retAction.payload.error = errMsg;
          logCommWarn(errMsg, true);
          return socket.emit(DATA_TABLE_FAILURE, JSON.stringify(retAction));
        }

        // --------------------------------------------------------
        // Execute the change against the database and respond to
        // the client appropriately.
        // --------------------------------------------------------
        dataChangeFunc(payload, userInfo, function(err, newData) {
          var data;
          if (err) {
            // We do not return to caller with DATA_TABLE_FAILURE because
            // the error is not due to a coding error, but rather more
            // likely that the user tried to checkin/out the wrong patient.
            // By returning on the same transaction, we allow the caller
            // to handle this "normal" use case rather than treat it as
            // something completely unexpected, which is what
            // DATA_TABLE_FAILURE is used for.
            retAction.payload.error = err;
            return socket.emit(''+transaction, JSON.stringify(retAction));
          }

          // --------------------------------------------------------
          // Return the action object back to the caller.
          // Note: if payloadKey is undefined, merge newData with payload.
          // --------------------------------------------------------
          if (payloadKey) {
            retAction.payload[payloadKey] = newData;
          } else {
            _.extendOwn(retAction.payload, newData);
          }
          socket.emit(''+transaction, JSON.stringify(retAction));

          // --------------------------------------------------------
          // Write out to the log and SYSTEM_LOG for administrators.
          // --------------------------------------------------------
          logCommInfo(userInfo.user.username + ": " + humanOpName, true);

          // --------------------------------------------------------
          // Notify all clients of the change.
          // NOTE: we assume that the payloadKey is the table name.
          // --------------------------------------------------------
          data = {
            table: dataTableName,
            id: newData.id,
            updatedBy: socket.request.session.user.id,
            sessionID: getSocketSessionId(socket)
          };
          sendData(DATA_CHANGE, JSON.stringify(data));
        })
      }
    });

    // --------------------------------------------------------
    // Send all data messages out to the authenticated clients.
    // Note: we ARE using this for the Elm client.
    // --------------------------------------------------------
    dataSubscription = dataSubject.subscribe(
      function(data) {
        // Don't do work unless logged in.
        if (! isValidSocketSession(socket)) return;

        // --------------------------------------------------------
        // Send the data change notification to the client if the
        // change originated with another client.
        // --------------------------------------------------------
        if (data.sessionID && getSocketSessionId(socket) !== data.sessionID) {
          // We don't leak sessionID to other clients.
          socket.emit(CONST.TYPE.DATA, _.omit(data, 'sessionID'));
        }
      },
      function(err) {
        logCommInfo('Error: ' + err);
      },
      function() {
        logCommInfo('dataSubject completed.');
      }
    );
  });
};

/* --------------------------------------------------------
 * getIsInitialized()
 *
 * Returns a function that tells the caller if the comm
 * module is initialized yet.
 * -------------------------------------------------------- */
function getIsInitialized() {return isInitialized;}

module.exports = {
  init
  , getIsInitialized
  , makeSend
  , sendSite
  , sendSystem
  , sendData
  , subscribeSite
  , subscribeSystem
  , subscribeData
  , SYSTEM_LOG
};

