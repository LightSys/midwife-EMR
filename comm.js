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
 * - msgId      - a unique id for the message
 * - namespace  - one of system, site, or data
 * - updatedAt  - date/time in milliseconds of creation/update
 * - workerId   - the process.env.WORKER_ID that created/updated the message
 * - scope      - if specified, names the worker id that message is limited to
 * - data       - the payload
 *
 * The system stream:
 * - Purpose: server to client broadcast to subscribers. System messages pertain to
 *   the server's operations as opposed to application issues. Examples include
 *   a shutdown notice, shutdown canceled, notification that a worker process is
 *   dying, messages to administrator's about what users are doing, etc.
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
 *          - Generally subscriptions are to the ids of major tables as opposed to
 *            the more detailed tables.
 *          - Though there are exceptions, such as an administrator receiving notifications
 *            about changes to all records in the user table, for example.
 *    - Sub-categories of data client to server messages.
 *       - Get data
 *          - Scope of message is automatically limited to receiving process, other
 *            processes on the server do not receive the message.
 *          - Data is returned to client.
 *          - Message is not broadcast to other clients.
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
  , assert = require('assert')
  , moment = require('moment')
  , cfg = require('./config')
  , User = require('./models').User
  , getLookupTable = require('./routes/comm/lookupTables').getLookupTable
  , getTable2 = require('./routes/comm/lookupTables').getTable2
  , saveUser = require('./routes/comm/userRoles').saveUser
  , checkInOut = require('./routes/comm/checkInOut').checkInOut
  , savePrenatal = require('./routes/comm/pregnancy').savePrenatal
  , buildChangeObject = require('./changes').buildChangeObject
  , socketToUserInfo = require('./commUtils').socketToUserInfo
  , sendData = require('./commUtils').sendData
  , isInitialized = false
  , sessionMiddleware
  , rxSite            // Stream for site messages
  , rxSystem          // Stream for system messages
  , rxData            // Stream for data messages
  , cntSystem = 0
  , cntSite = 0
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
  , ADD_CHG_DELETE = 'ADD_CHG_DELETE'       // data notification of a change by another client.
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
  , ADHOC_TOUCH_SESSION = 'ADHOC_TOUCH_SESSION'   // Used by the Elm medical client
  , TABLE_keyValue = 'keyValue'
  , TABLE_labSuite = 'labSuite'
  , TABLE_labTest = 'labTest'
  , TABLE_labTestValue = 'labTestValue'
  , TABLE_medicationType = 'medicationType'
  , TABLE_membranesResus = 'membranesResus'
  , TABLE_selectData = 'selectData'
  , TABLE_vaccinationType = 'vaccinationType'
  , TABLE_user = 'user'
  , TABLE_labor = 'labor'
  , TABLE_laborStage1 = 'laborStage1'
  , TABLE_laborStage2 = 'laborStage2'
  , TABLE_laborStage3 = 'laborStage3'
  , TABLE_apgar = 'apgar'
  , TABLE_baby = 'baby'
  , updateKeyValue = require('./routes/comm/lookupTables').updateKeyValue
  , addBaby = require('./routes/comm/labor').addBaby
  , updateBaby = require('./routes/comm/labor').updateBaby
  , delBaby = require('./routes/comm/labor').delBaby
  , addLabor = require('./routes/comm/labor').addLabor
  , delLabor = require('./routes/comm/labor').delLabor
  , updateLabor = require('./routes/comm/labor').updateLabor
  , addLaborStage1 = require('./routes/comm/labor').addLaborStage1
  , delLaborStage1 = require('./routes/comm/labor').delLaborStage1
  , updateLaborStage1 = require('./routes/comm/labor').updateLaborStage1
  , addLaborStage2 = require('./routes/comm/labor').addLaborStage2
  , delLaborStage2 = require('./routes/comm/labor').delLaborStage2
  , updateLaborStage2 = require('./routes/comm/labor').updateLaborStage2
  , addLaborStage3 = require('./routes/comm/labor').addLaborStage3
  , delLaborStage3 = require('./routes/comm/labor').delLaborStage3
  , updateLaborStage3 = require('./routes/comm/labor').updateLaborStage3
  , addLabSuite = require('./routes/comm/lookupTables').addLabSuite
  , delLabSuite = require('./routes/comm/lookupTables').delLabSuite
  , updateLabSuite = require('./routes/comm/lookupTables').updateLabSuite
  , addLabTest = require('./routes/comm/lookupTables').addLabTest
  , delLabTest = require('./routes/comm/lookupTables').delLabTest
  , updateLabTest = require('./routes/comm/lookupTables').updateLabTest
  , addLabTestValue = require('./routes/comm/lookupTables').addLabTestValue
  , delLabTestValue = require('./routes/comm/lookupTables').delLabTestValue
  , updateLabTestValue = require('./routes/comm/lookupTables').updateLabTestValue
  , addMedicationType = require('./routes/comm/lookupTables').addMedicationType
  , delMedicationType = require('./routes/comm/lookupTables').delMedicationType
  , updateMedicationType = require('./routes/comm/lookupTables').updateMedicationType
  , addMembranesResus = require('./routes/comm/labor').addMembranesResus
  , updateMembranesResus = require('./routes/comm/labor').updateMembranesResus
  , delMembranesResus = require('./routes/comm/labor').delMembranesResus
  , addSelectData = require('./routes/comm/lookupTables').addSelectData
  , delSelectData = require('./routes/comm/lookupTables').delSelectData
  , updateSelectData = require('./routes/comm/lookupTables').updateSelectData
  , addVaccinationType = require('./routes/comm/lookupTables').addVaccinationType
  , delVaccinationType = require('./routes/comm/lookupTables').delVaccinationType
  , updateVaccinationType = require('./routes/comm/lookupTables').updateVaccinationType
  , addUser = require('./routes/comm/userRoles').addUser
  , delUser = require('./routes/comm/userRoles').delUser
  , updateUser = require('./routes/comm/userRoles').updateUser
  , updateUserProfile = require('./routes/comm/userRoles').updateUserProfile
  , getUserProfile = require('./routes/comm/userRoles').getUserProfile
  , returnLogin = require('./util').returnLogin
  , returnUserProfile = require('./util').returnUserProfile
  , returnUserProfileUpdate = require('./util').returnUserProfileUpdate
  , returnStatusADD = require('./util').returnStatusADD
  , returnStatusADD2 = require('./util').returnStatusADD2
  , returnStatusCHG2 = require('./util').returnStatusCHG2
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
  , getProcessId = require('./util').getProcessId
  , assertModule = require('./comm_assert')
  , DO_ASSERT = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
  , KEY_VALUE_UPDATE = require('./constants').KEY_VALUE_UPDATE
  ;

/* --------------------------------------------------------
 * getIsInitialized()
 *
 * Returns a function that tells the caller if the comm
 * module is initialized yet.
 * -------------------------------------------------------- */
function getIsInitialized() {return isInitialized;}


// ========================================================
// ========================================================
// Logging functions.
// ========================================================
// ========================================================

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

// ========================================================
// ========================================================
// Message handling functions.
// ========================================================
// ========================================================

/* --------------------------------------------------------
 * wrap()
 *
 * Wrap data in a message wrapper per the message namespace. The
 * message id, namespace, updatedAt, workerID, and processedBy
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
 * param       namespace
 * param       data
 * param       scope - optional, for system messages only
 * return      message object
 * -------------------------------------------------------- */
var wrap = function(namespace, data, scope) {
  return {
    msgId: uuid.v1()
    , namespace: namespace
    , updatedAt: Date.now()
    , workerId: process.env.WORKER_ID
    , processedBy: [process.env.WORKER_ID]
    , scope: namespace == CONST.TYPE.SITE? undefined:
             namespace == CONST.TYPE.DATA? undefined:
             namespace == CONST.TYPE.SYSTEM? scope: undefined
    , data: data? data: {}
  };
};
// Initialize siteSubjectData with wrapper and the process startTime.
siteSubjectData = wrap(CONST.TYPE.SITE, {processStartTime: Date.now()});

/* --------------------------------------------------------
 * makeSend()
 *
 * Create a function that handles sending a certain namespace
 * of message.
 *
 * param       namespace     - namespace: SITE, SYSTEM, or DATA
 * return      function
 * -------------------------------------------------------- */
function makeSend(namespace) {
  return function(key, val, scope) {
    var data = {};
    var wrapped;
    switch (namespace) {
      case CONST.TYPE.SITE:
        // --------------------------------------------------------
        // For site messages, the most recent copy is stored so
        // update the data portion with the key/val pair, refresh
        // the wrapper and notify subscribers. Return the unique
        // message id to the caller.
        // --------------------------------------------------------
        data[key] = val;
        siteSubjectData = wrap(namespace, _.extendOwn(siteSubjectData.data, data));
        siteSubject.onNext(siteSubjectData);
        return siteSubjectData.msgId;

      case CONST.TYPE.SYSTEM:
        // --------------------------------------------------------
        // For system messages, there is no aggregation and there
        // is an optional scope parameter allowed.
        // --------------------------------------------------------
        data[key] = val;
        wrapped = wrap(namespace, data, scope);
        if (isInitialized) systemSubject.onNext(wrapped);
        break;

      default:
        logCommError('Error: makeSend() unimplemented for this namespace: ' + namespace);
    }
  };
};

/* --------------------------------------------------------
 * sendSite()
 * sendSystem()
 *
 * Send a message of a certain namespace.
 *
 * param       key      - the key of the key/val pair
 * param       val      - the value of the key/val pair
 * param       scope    - the scope of the message (system only)
 * return      msgId    - the unique message id
 * -------------------------------------------------------- */
var sendSite = makeSend(CONST.TYPE.SITE);
var sendSystem = makeSend(CONST.TYPE.SYSTEM);
// Note: sendData() has been refactored into commUtils.js.
//var sendData = makeSend(CONST.TYPE.DATA);

/* --------------------------------------------------------
 * wrapByType()
 *
 * Used for sending messages out to the client.
 *
 * Wrap a message with a outer object with a field named
 * namespace that specifies the course level type of message
 * this is, which is one of 'SYSTEM', 'SITE', or 'DATA'.
 * Another field named msgType specifies at a more granular
 * level the type of message. The field named payload contains
 * the data passed.
 *
 * Return a stringifed object to the caller.
 *
 * param       namespace
 * param       msgType
 * param       data
 * return      stringifed object
 * -------------------------------------------------------- */
var wrapByType = function(namespace, msgType, data) {
  // We do not allow fields used solely for routing between the
  // process and RxJS systems to go to the client.
  // Also, namespace is already specified one level up so
  // no need to repeat it if it exists.
  var payload = _.omit(data, ['namespace', 'msgId', 'workerId', 'processedBy', 'scope']);

  // Temporary sanity checks.
  if (! msgType) {
    console.log('===== wrapByType() discrepancy ======');
    console.log('msgType field not passed.');
    console.log('namespace: ' + namespace);
    console.log(data);
    console.log('===== end wrapByType() =====');
  } else if (! data) {
    console.log('===== wrapByType() discrepancy ======');
    console.log('data field not passed.');
    console.log('namespace: ' + namespace + ', msgType: ' + msgType);
    console.log('===== end wrapByType() =====');
  } else if (data.type) {
    console.log('===== wrapByType() discrepancy ======');
    console.log('data.type field passed.');
    console.log('namespace: ' + namespace + ', msgType: ' + msgType);
    console.log('===== end wrapByType() =====');
  } else if ((data.msgType && data.msgType !== msgType) || data.msgType) {
    console.log('----- wrapByType() inner msgType -----');
    console.log('data.msgType found and/or does not equal msgType.');
    console.log('namespace: ' + namespace + ', msgType: ' + msgType);
    if (msgType === CONST.TYPE.SYSTEM) console.log(data);
    console.log('----- end wrapByType() -----');
  }

  var retVal = JSON.stringify({namespace: namespace, msgType: msgType, payload: payload});
  //console.log(getProcessId() + ': ' + retVal);
  return retVal;
};
var wrapSystem = function(msgType, data) { return wrapByType('SYSTEM', msgType, data); };
var wrapSite = function(msgType, data) { return wrapByType('SITE', msgType, data); };
var wrapData = function(msgType, data) { return wrapByType('DATA', msgType, data); };

/* --------------------------------------------------------
 * subscribeSite()
 *
 * Allows other modules to subscribe to site namespace messages.
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
 * Allows other modules to subscribe to system namespace messages.
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
 * Allows other modules to subscribe to data namespace messages.
 *
 * param       onNext       - function to call upon msg
 * param       onError      - function to call upon error
 * param       onCompleted  - function to call when done
 * return      subscription object
 * -------------------------------------------------------- */
var subscribeData = function(onNext, onError, onCompleted) {
  return dataSubject.subscribe(onNext, onError, onCompleted);
};

// ========================================================
// ========================================================
// Utils for session validity, logins, and profiles.
// ========================================================
// ========================================================

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
 * extend the expiry timeout accordingly. We call save()
 * with a do nothing function in order to have the expires
 * field in the sessions table in the database updated as well.
 *
 * param       socket
 * return      undefined
 * -------------------------------------------------------- */
var touchSocketSession = function(socket) {
  if (DO_ASSERT) assertModule.touchSocketSession(socket);
  socket.request.session.touch();
  socket.request.session.save(function() {});
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
    return socket.send(wrapData(ADHOC_RESPONSE, retAction));
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
      return socket.send(wrapData(ADHOC_RESPONSE, retAction));
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
      return socket.send(wrapData(ADHOC_RESPONSE, retAction));
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
            return socket.send(wrapData(ADHOC_RESPONSE, retAction));
          }
          errCode = UserProfileUpdateFailErrorCode;
          if (success) errCode = UserProfileUpdateSuccessErrorCode;
          retAction = returnUserProfileUpdate(!!success, errCode);
          socket.send(wrapData(ADHOC_RESPONSE, retAction));

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
        socket.send(wrapData(ADHOC_RESPONSE, retAction));
      }
    });
  }

};


// ========================================================
// ========================================================
// High-level data processing functions.
// ========================================================
// ========================================================

/* --------------------------------------------------------
 * getFuncForTableOp()
 *
 * Returns a function for a combination of table and operation
 * that will be used for processing. This works for legacy
 * messages and version 2 messages.
 *
 * param       table
 * param       op
 * return      func
 * -------------------------------------------------------- */
var getFuncForTableOp = function(table, op) {
  var func = void 0;
  switch (table) {
    case TABLE_baby:
      switch (op) {
        case ADD: func = addBaby; break;
        case CHG: func = updateBaby; break;
        case DEL: func = delBaby; break;
      }
      break;
    case TABLE_keyValue:
      switch (op) {
        // keyValue table can only be updated.
        case CHG: func = updateKeyValue; break;
      }
      break;
    case TABLE_labor:
      switch (op) {
        case ADD: func = addLabor; break;
        case CHG: func = updateLabor; break;
        case DEL: func = delLabor; break;
      }
      break;
    case TABLE_laborStage1:
      switch (op) {
        case ADD: func = addLaborStage1; break;
        case CHG: func = updateLaborStage1; break;
        case DEL: func = delLaborStage1; break;
      }
      break;
    case TABLE_laborStage2:
      switch (op) {
        case ADD: func = addLaborStage2; break;
        case CHG: func = updateLaborStage2; break;
        case DEL: func = delLaborStage2; break;
      }
      break;
    case TABLE_laborStage3:
      switch (op) {
        case ADD: func = addLaborStage3; break;
        case CHG: func = updateLaborStage3; break;
        case DEL: func = delLaborStage3; break;
      }
      break;
    case TABLE_labSuite:
      switch (op) {
        case ADD: func = addLabSuite; break;
        case CHG: func = updateLabSuite; break;
        case DEL: func = delLabSuite; break;
      }
      break;
    case TABLE_labTest:
      switch (op) {
        case ADD: func = addLabTest; break;
        case CHG: func = updateLabTest; break;
        case DEL: func = delLabTest; break;
      }
      break;
    case TABLE_labTestValue:
      switch (op) {
        case ADD: func = addLabTestValue; break;
        case CHG: func = updateLabTestValue; break;
        case DEL: func = delLabTestValue; break;
      }
      break;
    case TABLE_medicationType:
      switch (op) {
        case ADD: func = addMedicationType; break;
        case CHG: func = updateMedicationType; break;
        case DEL: func = delMedicationType; break;
      }
      break;
    case TABLE_membranesResus:
      switch (op) {
        case ADD: func = addMembranesResus; break;
        case CHG: func = updateMembranesResus; break;
        case DEL: func = delMembranesResus; break;
      }
      break;
    case TABLE_selectData:
      switch (op) {
        case ADD: func = addSelectData; break;
        case CHG: func = updateSelectData; break;
        case DEL: func = delSelectData; break;
      }
      break;
    case TABLE_user:
      switch (op) {
        case ADD: func = addUser; break;
        case CHG: func = updateUser; break;
        case DEL: func = delUser; break;
      }
      break;
    case TABLE_vaccinationType:
      switch (op) {
        case ADD: func = addVaccinationType; break;
        case CHG: func = updateVaccinationType; break;
        case DEL: func = delVaccinationType; break;
      }
      break;
  }
  return func;
};

/* --------------------------------------------------------
 * handleData2
 *
 * Handle a Socket.io event in the DATA namespace for version
 * 2 messages. Note that for version 2 messages we do not use
 * wrapData() and the evtName we are called with is what we
 * return as the msgType.
 *
 * param       evtName, i.e. msgType
 * param       json - the whole message from the client.
 * param       socket
 * return      undefined
 * -------------------------------------------------------- */
var handleData2 = function(evtName, json, socket) {
  if (DO_ASSERT) assertModule.handleData2(evtName, json, socket);

  var table = json.payload.table
    , data = json.payload.data
    , messageId = json.messageId
    , userInfo = socketToUserInfo(socket)
    , retAction
    , dataFunc
    , returnStatusFunc
    ;

  switch (evtName) {
    case ADD:
      if (! table || ! data ) {
        // NOTE: version 2 messages do not send an id for ADD.
        // TODO: send the proper msg back to the client to this effect.
        console.log('Data ADD request: Improper data sent from client!');
        return;
      }
      returnStatusFunc = returnStatusADD2;
      break;

    case CHG:
      if (! table || ! data || ! _.has(data, 'id') || data.id === -1) {
        // TODO: send the proper msg back to the client to this effect.
        console.log('Data CHG request: Improper data sent from client!');
        return;
      }
      returnStatusFunc = returnStatusCHG2;
      break;

    default:
      console.log('UNKNOWN event of ' + evtName + ' in handeData2().');
      retAction = returnStatusFunc(evtName, messageId, table, void 0, false,
          UnknownErrorCode, "This event cannot be handled by the server: " + evtName + '.');
      return socket.send(JSON.stringify(retAction));
  }

  dataFunc = getFuncForTableOp(table, evtName);
  if (! dataFunc) {
    retAction = returnStatusFunc(evtName, messageId, table, void 0, false,
        UnknownErrorCode, "This table cannot be handled by the server.");
    console.log(retAction);
    return socket.send(JSON.stringify(retAction));
  }

  if (! isValidSocketSession(socket)) {
    retAction = returnStatusFunc(evtName, messageId, table, void 0, false,
        SessionExpiredErrorCode, "Your session has expired.");
    console.log(retAction);
    return socket.send(JSON.stringify(retAction));
  } else touchSocketSession(socket);

  if (! userInfo) {
    // NOTE: this is an error that occurs and I have not been able to track down yet.
    console.log('ERROR: userInfo object not populated in comm.js handleData2(). ABORTING!');
    return;
  }

  dataFunc(data, userInfo, function(err, success, additionalData) {
    var errMsg;
    if (err) {
      logCommError(err);
      errMsg = err.message? err.message: err;
      retAction = returnStatusFunc(evtName, messageId, table, void 0, false,
        SqlErrorCode, errMsg);
      return socket.send(JSON.stringify(retAction));
    }
    retAction = returnStatusFunc(evtName, messageId, table, additionalData.id, true);
    socket.send(JSON.stringify(retAction));

    // --------------------------------------------------------
    // Write out to the log and SYSTEM_LOG for administrators.
    // --------------------------------------------------------
    return logCommInfo(userInfo.user.username + ": " + table + ": " + evtName, true);
  });
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
  //var wrapper = JSON.parse(payload);
  var table = payload.table? payload.table: void 0
    , data = payload.data? payload.data: {}
    , recId = data? data.id: -1
    , userInfo = socketToUserInfo(socket)
    , retAction
    , dataFunc
    , returnStatusFunc
    , responseEvt
  ;
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
      return socket.send(wrapData(responseEvt, retAction));
  }

  dataFunc = getFuncForTableOp(table, evtName);
  if (! dataFunc) {
    retAction = returnStatusFunc(table, data.id, data.stateId, false, UnknownErrorCode, "This table cannot be handled by the server.");
    console.log(retAction);
    return socket.send(wrapData(responseEvt, retAction));
  }

  if (! isValidSocketSession(socket)) {
    retAction = returnStatusFunc(table, data.id, data.stateId, false, SessionExpiredErrorCode, "Your session has expired. Please login again.");
    console.log(retAction);
    return socket.send(wrapData(responseEvt, retAction));
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
      return socket.send(wrapData(responseEvt, retAction));
    }
    if (evtName == ADD) {
      retAction = returnStatusFunc(table, data.id, additionalData.id, true);
    } else {
      retAction = returnStatusFunc(table, data.id, data.stateId, true);
    }
    socket.send(wrapData(responseEvt, retAction));

    // --------------------------------------------------------
    // Write out to the log and SYSTEM_LOG for administrators.
    // --------------------------------------------------------
    return logCommInfo(userInfo.user.username + ": " + table + ": " + evtName, true);
  });

};

/* --------------------------------------------------------
 * getTable()
 *
 * Select and return data requested back to the client.
 *
 * param       socket
 * param       json
 * return      undefined
 * -------------------------------------------------------- */
var getTable = function(socket, json) {
  var retVal = _.omit(json, 'payload'); // version 2 only

  if (DO_ASSERT) assertModule.getTable(socket, json);

  if (json.payload && json.payload.table) {
    console.log('Table: ' + json.payload.table + ', id: ' + json.payload.id + ', related: ' + json.payload.related);

    if (json.version && json.version === 2) {
      // Version 2
      getTable2(json.payload.table, json.payload.id, json.payload.related, function(err, data) {
        if (err) {
          logCommError(err);
          retVal.response = returnStatusSELECT({}, void 0, false, SqlErrorCode, err && err.msg? err.msg: '');
          // TEMP
          console.log(JSON.stringify(retVal));
          return socket.send(JSON.stringify(retVal));
        }
        retVal.response = returnStatusSELECT({}, data, true);
        return socket.send(JSON.stringify(retVal));
      });
    } else {
      // Legacy version.
      getLookupTable(json.payload.table, json.payload.id,
        json.payload.pregnancy_id, json.payload.patient_id, function(err, data) {
        if (err) {
          logCommError(err);
          retAction = returnStatusSELECT(json.payload, void 0, false, SqlErrorCode, err.msg);
          return socket.send(wrapData(DATA_SELECT_RESPONSE, retAction));
        }
        retAction = returnStatusSELECT(json.payload, data, true);
        return socket.send(wrapData(DATA_SELECT_RESPONSE, retAction));
      });
    }
  } else {
    console.log('=== Socket id: ' + socket.id + ' ===');
    retAction = returnStatusSELECT(json.payload, void 0, false, UnknownErrorCode, 'Table not specified.');
    return socket.send(wrapData(DATA_SELECT_RESPONSE, retAction));
  }
};

// ========================================================
// ========================================================
// Initialization of our three communication interfaces.
// ========================================================
// ========================================================

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
 * Only one Socket.io connection is used with each client
 * rather than one each for SITE, SYSTEM, and DATA messages.
 * This is for the sake of potential future compatibility
 * with standard websocket which does not multiplex the
 * connection like Socket.io does, so we would not want to
 * have so many websocket connections to each client in reality.
 *
 * param       io             - the Socket.io socket
 * param       sessionMiddle  - authorization routine
 * return
 * -------------------------------------------------------- */
var init = function(io, sessionMiddle) {
  if (isInitialized) return;
  isInitialized = true;

  // ========================================================
  // ========================================================
  // Receiving messages from other processes and forwarding
  // into the RxJS interface.
  // ========================================================
  // ========================================================

  // --------------------------------------------------------
  // Handle messages from other worker processes and forward
  // the messages into the rxJS interface.
  // --------------------------------------------------------
  process.on('message', function(wrapper) {
    var data = wrapper.data;
    switch (wrapper.namespace) {
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
        siteSubjectData.msgId = data.msgId;
        siteSubjectData.namespace = data.namespace;
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
        // There are other messages that we are not interested in but
        // other things use. Only report on what we don't recognize.
        // --------------------------------------------------------
        if (! _.has(wrapper, 'cmd')) {
          if (_.isObject(wrapper) && _.has(wrapper, KEY_VALUE_UPDATE)) {
            // config/index.js handles this, so ignore.
          } else {
            logCommInfo('Client: Received UNHANDLED msg: ' + JSON.stringify(wrapper));
          }
        }
    }
  });


  // ========================================================
  // ========================================================
  // Receiving messages from the RxJS interface and forwarding
  // to other processes.
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
      process.send({namespace: CONST.TYPE.SITE, data: data});
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
      process.send({namespace: CONST.TYPE.SYSTEM, data: data});
    },
    function(err) {
      logCommError('Error: ' + err);
    },
    function() {
      logCommInfo('systemSubject completed.');
    }
  );

  // --------------------------------------------------------
  // Whatever is received here is sent to the clients.
  // --------------------------------------------------------
  dataSubject = new rx.Subject();

  // ========================================================
  // ========================================================
  // Handling communications from this NodeJS process to it's
  // connected clients, i.e. the users.
  // ========================================================
  // ========================================================

  // --------------------------------------------------------
  // Configure the sockets.
  // Integrate Express sessions into Socket.io.
  // See: https://stackoverflow.com/a/25618636
  // --------------------------------------------------------
  ioSocket = io.of('/');
  sessionMiddleware = sessionMiddle;
  ioSocket.use(function(socket, next) {
    // Note: for this to work, Socket.io must be allowed to
    // use polling, i.e. a websocket only transport causes
    // this to fail because the response instance is unavailable.
    sessionMiddleware(socket.request, socket.request.res, next);
  });

  // --------------------------------------------------------
  // The Socket.io connection using a single namespace.
  // --------------------------------------------------------
  ioSocket.on('connection', function(socket) {
    var systemSubscription;
    socket.on('disconnect', function() {
      systemSubscription.dispose();
    });

    socket.on('error', function(err) {
      console.log('===== SOCKET ERROR =====');
      console.log(err);
      console.log('===== SOCKET ERROR =====');
    });

    socket.on('message', function(data) {
      assert(_.isString(data));
      var json = JSON.parse(data);
      var userInfo = socketToUserInfo(socket);
      assert(json.namespace && json.msgType);

      // --------------------------------------------------------
      // Sanity check that the client is not trying to send
      // messages using an invalid namespace.
      // --------------------------------------------------------
      if (json.namespace !== CONST.TYPE.DATA) {
          console.log('##### ERROR: invalid namespace received from client: ' + json.namespace);
          return;
      }

      // --------------------------------------------------------
      // Handle incoming message from the clients in the DATA
      // namespace.
      //
      // Differentiate between different versions of messages.
      // The Elm admin client uses the original message type that
      // does not have a version field, while the Elm medical
      // client uses the newer message type that has a version
      // field with a value of 2.
      // --------------------------------------------------------
      if (_.has(json, "version") && json.version === 2) {
        // Medical Elm client.
        switch (json.msgType) {
          case DATA_SELECT:
            getTable(socket, json);
            break;

          case ADD:
            if (DO_ASSERT) assertModule.ioData_socket_on_ADD(json.payload);
            handleData2(ADD, json, socket);
            break;

          case CHG:
            if (DO_ASSERT) assertModule.ioData_socket_on_CHG(json.payload);
            handleData2(CHG, json, socket);
            break;

          case ADHOC_TOUCH_SESSION:
            touchSocketSession(socket);
            break;

          default:
            console.log('ERROR: unhandled data msgType of: ' + json.msgType);
            console.log(json);
        }
      } else {
        // Admin Elm client.
        switch (json.msgType) {
          case ADHOC_LOGIN:
            handleLogin(json.payload, socket);
            break;

          case ADHOC_USER_PROFILE:
            handleUserProfile(socket);
            break;

          case ADHOC_USER_PROFILE_UPDATE:
            handleUserProfile(socket, json.payload, userInfo);
            break;

          case DATA_SELECT:
            getTable(socket, json);
            break;

          case ADD:
            if (DO_ASSERT) assertModule.ioData_socket_on_ADD(json.payload);
            handleData(ADD, json.payload, socket);
            break;

          case CHG:
            if (DO_ASSERT) assertModule.ioData_socket_on_CHG(json.payload);
            handleData(CHG, json.payload, socket);
            break;

          case DEL:
            if (DO_ASSERT) assertModule.ioData_socket_on_DEL(json.payload);
            handleData(DEL, json.payload, socket);
            break;

          default:
            console.log('ERROR: unhandled data msgType of: ' + json.msgType);
            console.log(json);
        }
      }
    });

    // --------------------------------------------------------
    // Send data change notifications to the client if the
    // change originated with another client.
    // --------------------------------------------------------
    dataSubscription = dataSubject.subscribe(
      function(data) {
        // Don't do work unless logged in.
        if (! isValidSocketSession(socket)) return;

        if (data.sessionID && getSocketSessionId(socket) !== data.sessionID) {
          // We don't leak sessionID to other clients.
          console.log('=== Socket id: ' + socket.id + ' ===');
          socket.send(wrapData(ADD_CHG_DELETE, _.omit(data, 'sessionID')));
        }
      },
      function(err) {
        logCommInfo('Error: ' + err);
      },
      function() {
        logCommInfo('dataSubject completed.');
      }
    );

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
          // Hack: we know what this is, so we set the msgType explicitly.
          // See to do below.
          console.log('=== Socket id: ' + socket.id + ' ===');
          socket.send(wrapSystem(SYSTEM_LOG, data));
        } else {
          // TODO: Need to handle msgType for all types of system messages.
          // This needs to be better handled in the format of the process
          // and rxJS messages. This needs to be done when we actually get
          // more types of system messages other than SYSTEM_LOG.
          console.log('=== Socket id: ' + socket.id + ' ===');
          socket.send(wrapSystem(data.msgType, data));
        }
      },
      function(err) {
        logCommError('Error: ' + err);
      },
      function() {
        logCommInfo('systemSubject completed.');
      }
    );

    // --------------------------------------------------------
    // Send all site messages out to the authenticated clients.
    // --------------------------------------------------------
    siteSubscription = siteSubject.subscribe(
      function(data) {
        // Don't do work unless logged in.
        if (! isValidSocketSession(socket)) return;
        console.log('=== Socket id: ' + socket.id + ' ===');
        console.log('**********************');
        console.log(data);
        console.log('**********************');
        socket.send(wrapSite(CONST.TYPE.SITE, data));
      },
      function(err) {
        logCommInfo('Error: ' + err);
      },
      function() {
        logCommInfo('siteSubject completed.');
      }
    );
  });
};    // end init()

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

