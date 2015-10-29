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
 * - data       - the payload, all the key/value pairs set so far
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
 * -------------------------------------------------------------------------------
 */

var redis = require('redis')
  , rx = require('rx')
  , uuid = require('uuid')
  , _ = require('underscore')
  , logInfo = require('./util').logInfo
  , logWarn = require('./util').logWarn
  , logError = require('./util').logError
  , cfg = require('./config')
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
  , pubSub
  , rClient
  , siteSubject
  , siteSubjectData
  , systemSubject
  , systemSubjectLastId
  , CONST
  ;

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
 * message id, type, updatedAt, and workerID fields are
 * automatically set. This is only done when new data is
 * sent into the stream.
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
var makeSend = function(type) {
  return function(key, val, scope) {
    var data = {};
    var wrapped;
    if (type === CONST.TYPE.SITE) {
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
    } else if (type === CONST.TYPE.SYSTEM) {
      // --------------------------------------------------------
      // For system messages, there is no aggregation and there
      // is an optional scope parameter allowed. We store the
      // id of the message as we inject it into the rx stream in
      // order to prevent circularities.
      // --------------------------------------------------------
      data[key] = val;
      wrapped = wrap(type, data, scope);
      systemSubjectLastId = wrapped.id;
      systemSubject.onNext(wrapped);
    } else {
      logError('Error: makeSend() unimplemented for this type: ' + type);
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
  // pubSub is used exclusively for subscribing, receiving
  // messages, and unsubscribing. rClient is used for publishing
  // and anything else.
  // --------------------------------------------------------
  pubSub = redis.createClient(cfg.redis);
  rClient = redis.createClient(cfg.redis);
  pubSub.select(cfg.redis.db);
  rClient.select(cfg.redis.db);

  // --------------------------------------------------------
  // Handle messages from other worker processes.
  // --------------------------------------------------------
  pubSub.on('message', function(channel, message) {
    var data = JSON.parse(message);
    if (channel === CONST.TYPE.SITE) {
      // We already have this message, therefore do nothing.
      if (data.id && data.id === siteSubjectData.id) return;
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
    } else if (channel === CONST.TYPE.SYSTEM) {
      // We already have this message, therefore do nothing.
      if (data.id && data.id === systemSubjectLastId) return;
      // Save the id so we don't create a loop between Rx and Redis.
      systemSubjectLastId = data.id;
      systemSubject.onNext(data);
    } else {
      logError('pubSub: channel ' + channel + ' is not yet implemented.');
    }
  });
  pubSub.subscribe(CONST.TYPE.SITE);
  pubSub.subscribe(CONST.TYPE.SYSTEM);


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
  logInfo('Seeding siteSubject with ' + siteSubjectData.id);
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
      logInfo('Sending ' + data.id + ' to the other process.');
      rClient.publish(CONST.TYPE.SITE, JSON.stringify(data));
    },
    function(err) {
      logInfo('Error: ' + err);
    },
    function() {
      logInfo('siteSubject completed.');
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
      logInfo('Sending ' + data.id + ' to the other process.');
      rClient.publish(CONST.TYPE.SYSTEM, JSON.stringify(data));
    },
    function(err) {
      logInfo('Error: ' + err);
    },
    function() {
      logInfo('systemSubject completed.');
    }
  );

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
        // Don't do work unless logged in.
        if (! isValidSocketSession(socket)) {
          logInfo('Socket is invalid so not sending.');
          return;
        } else {
          logInfo('Socket is sending');
        }
        socket.emit(CONST.TYPE.SYSTEM, data);
      },
      function(err) {
        logInfo('Error: ' + err);
      },
      function() {
        logInfo('systemSubject completed.');
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
        logInfo('Error: ' + err);
      },
      function() {
        logInfo('siteSubject completed.');
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
  });


};

module.exports = {
  init: init
  , sendSite: sendSite
  , sendSystem: sendSystem
  , sendData: sendData
  , subscribeSite: subscribeSite
  , subscribeSystem: subscribeSystem
};

