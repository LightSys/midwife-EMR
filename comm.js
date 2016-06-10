/*
 * -------------------------------------------------------------------------------
 * comm.js
 *
 * Handle the Socket.io interface with the clients, the Redis interface with the
 * other cluster worker processes, and the RxJS interface to the other modules
 * in this worker process. Expose only RxJS streams to the other modules and
 * leave the Socket.io and Redis interfaces private to this module.
 *
 * There are three communication streams (system, site, and data) that are active
 * across each of the three interfaces (Socket.io, Redis, and RxJS). All messages
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

var redis = require('redis')
  , rx = require('rx')
  , uuid = require('uuid')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('./config')
  , getLookupTable = require('./routes/api/lookupTables').getLookupTable
  , saveUser = require('./routes/comm/userRoles').saveUser
  , buildChangeObject = require('./changes').buildChangeObject
  , socketToUserInfo = require('./commUtils').socketToUserInfo
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
  , redisSub
  , redisPub
  , siteSubject
  , siteSubjectData
  , systemSubject
  , dataSubject
  , CONST
  , DATA_CHANGE = 'DATA_CHANGE'
  , SYSTEM_LOG = 'SYSTEM_LOG'
  , DATA_TABLE_REQUEST = 'DATA_TABLE_REQUEST'
  , DATA_TABLE_SUCCESS = 'DATA_TABLE_SUCCESS'
  , DATA_TABLE_FAILURE = 'DATA_TABLE_FAILURE'
  , ADD_USER_REQUEST = 'ADD_USER_REQUEST'
  , ADD_USER_SUCCESS = 'ADD_USER_SUCCESS'
  , ADD_USER_FAILURE = 'ADD_USER_FAILURE'
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

// --------------------------------------------------------
// Constant definitions. Allow client of this module to use
// constants to help avoid spelling issues.
// --------------------------------------------------------
CONST = {
  TYPE: {
    SITE: 'site'
    , SYSTEM: 'system'
    , DATA: 'data'
  }
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
 * that have received the message via Redis or, as is the
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

      case CONST.TYPE.DATA:
        if (key === DATA_CHANGE) {
          try {
            data = JSON.parse(val)
          } catch (e) {
            logCommError('Error in makeSend processing data: ' + e.toString());
            return;
          }
          buildChangeObject(data).then(function(data2) {
            // --------------------------------------------------------
            // Broadcast this to the other processes for distribution
            // to all connected clients.
            // --------------------------------------------------------
            redisPub.publish(CONST.TYPE.DATA, JSON.stringify(data2));
          });
          break;

        } else {
          // TODO: Handle response from lookup table request. Only send to caller.
          // Intentional fall through to default.
        }

      default:
        logCommError('Error: makeSend() unimplemented for this type: ' + type);
    }
  };
};

/* --------------------------------------------------------
 * sendSite()
 * sendSystem()
 * sendData()
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
var sendData = makeSend(CONST.TYPE.DATA);

/* --------------------------------------------------------
 * subscribeSite()
 *
 * Subscribe to site type messages.
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
 * Subscribe to system type messages.
 *
 * param       onNext       - function to call upon msg
 * param       onError      - function to call upon error
 * param       onCompleted  - function to call when done
 * return      subscription object
 * -------------------------------------------------------- */
var subscribeSystem = function(onNext, onError, onCompleted) {
  return systemSubject.subscribe(onNext, onError, onCompleted);
};

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
  var isValid = socket &&
                socket.request &&
                socket.request.session &&
                socket.request.session.roleInfo &&
                socket.request.session.roleInfo.isAuthenticated? true: false;
  return isValid;
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
 * init()
 *
 * Initialize the three communication interfaces that this
 * module uses: Socket.io for the clients, Redis for
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

  // ========================================================
  // ========================================================
  // Configure the Redis clients.
  // ========================================================
  // ========================================================

  // --------------------------------------------------------
  // redisSub is used exclusively for subscribing, receiving
  // messages, and unsubscribing. redisPub is used for publishing
  // and anything else.
  // --------------------------------------------------------
  redisSub = redis.createClient(cfg.redis);
  redisPub = redis.createClient(cfg.redis);
  redisSub.select(cfg.redis.db);
  redisPub.select(cfg.redis.db);

  // --------------------------------------------------------
  // Handle messages from other worker processes.
  // --------------------------------------------------------
  redisSub.on('message', function(channel, message) {
    var data;
    try {
      data = JSON.parse(message);
    } catch (e) {
      logCommError('Error during parsing of Redis message: ' + e.toString());
      console.dir(util.inspect(message, {depth: 3}));
      data = {};
    }
    switch (channel) {
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

      case CONST.TYPE.DATA:
        // --------------------------------------------------------
        // Received a data notification from some other server process
        // (or possibly our own) so now we inject it into the RxJS data
        // stream so that it can be sent to the clients.
        // --------------------------------------------------------
        dataSubject.onNext(data);
        break;

      default:
        logCommError('redisSub: channel ' + channel + ' is not yet implemented.');
    }
  });
  redisSub.subscribe(CONST.TYPE.SITE);
  redisSub.subscribe(CONST.TYPE.SYSTEM);
  redisSub.subscribe(CONST.TYPE.DATA);


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
      redisPub.publish(CONST.TYPE.SITE, JSON.stringify(data));
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
      redisPub.publish(CONST.TYPE.SYSTEM, JSON.stringify(data));
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
    socket.on('disconnect', function() {
      cntData--;
    });
    cntData++;

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
        , payloadKey          // the data table
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
            humanOpName = 'Add User';
            break;
          default:
            errMsg = 'Comm: received unknown action.type: ' + action.type;
            break;
        }
        if (! dataChangeFunc || ! payloadKey) {
          retAction.payload = {error: errMsg};
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
            // Note: we don't log because callee already should have done so.
            retAction.payload = {error: err};
            return socket.emit(DATA_TABLE_FAILURE, JSON.stringify(retAction));
          }

          // --------------------------------------------------------
          // Return the action object back to the caller.
          // --------------------------------------------------------
          retAction.payload[payloadKey] = newData;
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
            table: payloadKey,
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
    // --------------------------------------------------------
    dataSubscription = dataSubject.subscribe(
      function(data) {
        // Don't do work unless logged in.
        if (! isValidSocketSession(socket)) return;
        // --------------------------------------------------------
        // Send the data change notification to the client, unless we
        // can detect that the data change was initiated by this socket.
        // --------------------------------------------------------
        if (! data.sessionID) {
          socket.emit(CONST.TYPE.DATA, data);
        } else if (getSocketSessionId(socket) !== data.sessionID) {
          // We don't leak another client's sessionID.
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
  init: init
  , getIsInitialized: getIsInitialized
  , sendSite: sendSite
  , sendSystem: sendSystem
  , sendData: sendData
  , subscribeSite: subscribeSite
  , subscribeSystem: subscribeSystem
  , subscribeData: subscribeData
  , DATA_CHANGE: DATA_CHANGE
  , SYSTEM_LOG: SYSTEM_LOG
};

