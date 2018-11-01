/*
 * -------------------------------------------------------------------------------
 * comm.js
 *
 * Interface between the server via Socket.io and the Elm client via ports. We use
 * a single Socket.io namespace but distinguish various types of messages with the
 * "namespace" key within the message. We do not use more than one Socket.io
 * namespace in order to retain a degree of compatibility with standard websocket.
 *
 *    data: bi-directional for any and all data, whether it is changed or not.
 *    site: server to client stats regarding the application.
 *    system: server to client information regarding system status, notices, etc.
 *
 * We do not use Socket.io rooms.
 *
 * Sub-protocol:
 *
 * - All messages are passed as a string, but are from JSON that has been stringified.
 * - After parsing the message into JSON, the top level of the object has three fields:
 *   - namespace: either 'data', 'system', or 'site'.
 *   - msgType: application specific.
 *   - payload: the data being passed.
 * - Routing is accomplished using the namespace and msgType fields.
 * -------------------------------------------------------------------------------
 */

io = require('socket.io-client');
var _ = require('underscore');
var app;      // Required: set by caller via setApp().


// --------------------------------------------------------
// Setup a single Socket.io connection to the server.
// --------------------------------------------------------
var ioSocket = io.connect(window.location.origin + '/');

// --------------------------------------------------------
// Socket.io event types that we will use.
// --------------------------------------------------------
// The message key and sub-protocol namespace keys.
var MESSAGE = 'message';    // All messages use this key so that we are most compatible with websocket API.
var SITE = 'SITE';          // All site messages use this key for the namespace.
var SYSTEM = 'SYSTEM';      // All system messages use this key for the namespace.
var DATA = 'DATA';          // All data messages use this key for the namespace.

// The msgTypes from the data namespace.
var ADD = 'ADD';            // Client to server data addition request in data namespace.
var ADD_RESPONSE = 'ADD_RESPONSE';  // Server to client data add response in data namespace.
var CHG = 'CHG';            // Client to server data change request in data namespace.
var CHG_RESPONSE = 'CHG_RESPONSE';  // Server to client data change response in data namespace.
var DEL = 'DEL';            // Client to server data deletion request in data namespace.
var DEL_RESPONSE = 'DEL_RESPONSE';  // Server to client data deletion response in data namespace.
var SELECT = 'SELECT';      // Client to server data request in data namespace.
var SELECT_RESPONSE = 'SELECT_RESPONSE';  // Server to client data request response in data namespace.
var ADHOC = 'ADHOC';        // Server to client message type in the data namespace.
var ADHOC_RESPONSE = 'ADHOC_RESPONSE';  // Server to client response in data namespace.
var ADHOC_LOGIN = 'ADHOC_LOGIN';        // Client to server for login request, the adhocType of the ADHOC message.
var ADHOC_USER_PROFILE = 'ADHOC_USER_PROFILE';    // Client to server for user profile request.
var ADHOC_USER_PROFILE_UPDATE = 'ADHOC_USER_PROFILE_UPDATE';  // User updates their own user profile.
var ADHOC_SYSTEM_MODE = 'ADHOC_SYSTEM_MODE';  // Client changes system mode.
var ADD_CHG_DELETE = 'ADD_CHG_DELETE';



// ========================================================
// ========================================================
// Utility functions.
// ========================================================
// ========================================================

/* --------------------------------------------------------
 * wrapByType()
 *
 * Wrap a message with a outer object with a field named
 * namespace that specifies the course level type of message
 * this is, which is one of 'SYSTEM', 'SITE', or 'DATA'.
 * Another field named payload contains the data
 * passed. Yet another field named version is added to specify
 * the sub-protocol version being used. Return a stringifed
 * object to the caller.
 *
 * param       namespace
 * param       msgType
 * param       data
 * return      stringifed object
 * -------------------------------------------------------- */
var wrapByType = function(namespace, msgType, data) {
  return JSON.stringify({
    namespace: namespace,
    msgType: msgType,
    version: 1,
    payload: data
  });
};
var wrapData = function(msgType, data) { return wrapByType(DATA, msgType, data); };


/* --------------------------------------------------------
 * sendMsg()
 *
 * Sends a data message to the server using the event and
 * the payload passed. The site and system namespaces are
 * not ever used to send client to server messages.
 * -------------------------------------------------------- */
var sendMsg = function(msg, payload) {
  ioSocket.send(wrapData(msg, payload));
}

/* --------------------------------------------------------
 * wrapTableChange()
 *
 * Wrap the tbl and data passed in an object assigned to
 * table and data fields respectively.
 * -------------------------------------------------------- */
var wrapTableChange = function(tbl, data) {
  return {
    table: tbl,
    data: data
  };
}

// ========================================================
// ========================================================
// Handling server to client messages.
// ========================================================
// ========================================================

// --------------------------------------------------------
// Handle incoming messages for the data namespace. Note
// that our single parameter is already JSON.
// --------------------------------------------------------
var handleData = function(json) {
  // Sanity checks.
  if (! app) {
    console.log('ERROR: handleData() called when app has not been set.');
    return;
  }
  if (! json || ! json.msgType) {
    console.log('ERROR: improper data sent to handleData().');
    console.log(json);
    return;
  }

  switch (json.msgType) {
    case ADD_CHG_DELETE:
      // This is for notifications from the server about data changes that
      // other clients have made that our client may be interested in.
      console.log('ADD_CHG_DELETE');
      app.ports.addChgDelNotification.send(json.payload);
      break;

    case ADHOC_RESPONSE:
      // Responses from the server for requests for work that we have made.
      app.ports.adhocResponse.send(json.payload);
      break;

    case SELECT_RESPONSE:
      // Responses from the server for data that we have requested.
      console.log('Loading: ' + json.payload.table);
      app.ports.selectQueryResponse.send(json.payload);
      break;

    case ADD_RESPONSE:
      // Response from the server about a record add request we have made.
      app.ports.createResponse.send(json.payload);
      break;

    case CHG_RESPONSE:
      // Response from the server about a record change request we have made.
      app.ports.updateResponse.send(json.payload);
      break;

    case DEL_RESPONSE:
      // Response from the server about a record delete request we have made.
      app.ports.deleteResponse.send(json.payload);
      break;

    default:
      console.log('ERROR: unknown msgType of ' + json.msgType);
  }
};

// --------------------------------------------------------
// Handle incoming messages for the site namespace. Note
// that our single parameter is already JSON.
//
// TODO: set this up.
// --------------------------------------------------------
var handleSite = function(json) {
  console.log('Received SITE msg: unprocessed.');
}

// --------------------------------------------------------
// Handle incoming messages for the system namespace. Note
// that our single parameter is already JSON.
// --------------------------------------------------------
var handleSystem = function(json) {
  if (! json.payload) {
    console.log('=== ERROR: missing payload.');
    console.log(json);
    console.log('=== End ERROR: missing payload.');
    return;
  }

  // Elm does not like uppercase keys in records, so rename and remove
  // extraneous nesting while we are at it.
  // TODO: fix this on the server to not use upper case.
  if (json.payload.data && json.payload.data.SYSTEM_LOG) {
    json.payload.systemLog = json.payload.data.SYSTEM_LOG;
    delete json.payload.data;
  }
  app.ports.systemMessages.send(json.payload);
};

// --------------------------------------------------------
// Error handling.
// --------------------------------------------------------
ioSocket.on('error', function(err) {
  // TODO: catch error such as session timeouts, etc. and deal with properly.
  // Maybe means sending a message via a port to Elm about this?
  if (! app) return;
  console.log('=== Error ==>');
  console.log(err);
  console.log('<== Error ===');
});

ioSocket.on('reconnect_error', function(err) {
  if (! app) return;
  console.log('=== Reconnect Error ==>');
  console.log(err);
  console.log('<== Reconnect Error ===');
});

ioSocket.on('connect_error', function(err) {
  if (! app) return;
  console.log('=== Connect Error ==>');
  console.log(err);
  console.log('<== Connect Error ===');
});

// --------------------------------------------------------
// Handle all messages coming from the server by parsing to
// JSON, performing nominal sanity checks, and passing out
// to handlers for processing.
// --------------------------------------------------------
ioSocket.on(MESSAGE, function(data) {
  // Sanity checks
  if (! app) {
    console.log('ERROR: message received from the server before app has been initialized.');
    return;
  }
  if (! data) {
    console.log('ERROR: message received from the server with no content.');
    return;
  }

  // Parsing to JSON.
  var json;
  try {
    json = JSON.parse(data);
  } catch (e) {
    console.log('ERROR parsing JSON.');
    console.log(e);
    return;
  }

  // More sanity checks.
  if (! json || ! json.namespace || ! json.msgType || ! json.payload) {
    console.log('ERROR: message received from the server is in improper format.');
    //console.log(json);
  }

  // Forward work to handlers.
  if (json && json.namespace) {
    switch (json.namespace) {
      case SYSTEM:
        handleSystem(json);
        break;

      case SITE:
        handleSite(json.payload);
        break;

      case DATA:
        handleData(json);
        break;

      default:
        console.log('ERROR: unknown or missing namespace of: ' + json.namespace);
        break;
    }
  }
});

// ========================================================
// ========================================================
// Handling Elm client to server messages.
// ========================================================
// ========================================================

/* --------------------------------------------------------
 * setApp()
 *
 * Save the reference to the Elm client. Everything here
 * requires this so this needs to be set by the caller as
 * soon as possbile after the Elm client is created.
 *
 * Listen for messages coming from the Elm client and send
 * them to the server.
 * -------------------------------------------------------- */
var setApp = function(theApp) {
  app = theApp;

  app.ports.login.subscribe(function(data) {
    sendMsg(ADHOC_LOGIN, data);
  });

  app.ports.keyValueUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('keyValue', data));
  });

  app.ports.labSuiteCreate.subscribe(function(data) {
    sendMsg(ADD, wrapTableChange('labSuite', data));
  });

  app.ports.labSuiteDelete.subscribe(function(data) {
    sendMsg(DEL, wrapTableChange('labSuite', data));
  });

  app.ports.labSuiteUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('labSuite', data));
  });

  app.ports.labTestCreate.subscribe(function(data) {
    sendMsg(ADD, wrapTableChange('labTest', data));
  });

  app.ports.labTestDelete.subscribe(function(data) {
    sendMsg(DEL, wrapTableChange('labTest', data));
  });

  app.ports.labTestUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('labTest', data));
  });

  app.ports.labTestValueCreate.subscribe(function(data) {
    sendMsg(ADD, wrapTableChange('labTestValue', data));
  });

  app.ports.labTestValueDelete.subscribe(function(data) {
    sendMsg(DEL, wrapTableChange('labTestValue', data));
  });

  app.ports.labTestValueUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('labTestValue', data));
  });

  app.ports.medicationTypeCreate.subscribe(function(data) {
    sendMsg(ADD, wrapTableChange('medicationType', data));
  });

  app.ports.medicationTypeDelete.subscribe(function(data) {
    sendMsg(DEL, wrapTableChange('medicationType', data));
  });

  app.ports.medicationTypeUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('medicationType', data));
  });

  app.ports.requestUserProfile.subscribe(function(uselessData) {
    sendMsg(ADHOC_USER_PROFILE, {});
  });

  app.ports.selectDataCreate.subscribe(function(data) {
    sendMsg(ADD, wrapTableChange('selectData', data));
  });

  app.ports.selectDataDelete.subscribe(function(data) {
    sendMsg(DEL, wrapTableChange('selectData', data));
  });

  app.ports.selectDataUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('selectData', data));
  });

  app.ports.selectQuery.subscribe(function(query) {
    sendMsg(SELECT, query);
  });

  app.ports.systemMode.subscribe(function(data) {
    sendMsg(ADHOC_SYSTEM_MODE, data);
  });

  app.ports.userCreate.subscribe(function(data) {
    sendMsg(ADD, wrapTableChange('user', data));
  });

  app.ports.userDelete.subscribe(function(data) {
    sendMsg(DEL, wrapTableChange('user', data));
  });

  app.ports.userUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('user', data));
  });

  app.ports.userProfileUpdate.subscribe(function(data) {
    sendMsg(ADHOC_USER_PROFILE_UPDATE, data);
  });

  app.ports.vaccinationTypeCreate.subscribe(function(data) {
    sendMsg(ADD, wrapTableChange('vaccinationType', data));
  });

  app.ports.vaccinationTypeDelete.subscribe(function(data) {
    sendMsg(DEL, wrapTableChange('vaccinationType', data));
  });

  app.ports.vaccinationTypeUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapTableChange('vaccinationType', data));
  });

};

module.exports = {
  setApp: setApp
};
