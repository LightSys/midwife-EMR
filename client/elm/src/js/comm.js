/*
 * -------------------------------------------------------------------------------
 * comm.js
 *
 * Interface between the server via Socket.io and the Elm client via ports. We use
 * Socket.io namespaces to separate communications into several broad categories:
 *
 *    data: bi-directional for any and all data, whether it is changed or not.
 *    site: server to client stats regarding the application.
 *    system: server to client information regarding system status, notices, etc.
 *
 * We do not use Socket.io rooms.
 *
 * We use custom events within namespaces to further differentiate the types of
 * communications.
 *
 *    system namespace: the only custom event used is 'system'.
 *    site namespace: the only custom event used is 'site'.
 *    data namespace: more than one event is used within the data interface.
 *
 *        The 'data' event is used for server initiated communications to the
 *        client within the data namespace.
 *
 *        The 'DATA_CHANGE' event is used by either the server or the client to
 *        inform the other about changed data.
 *
 *            When the client changes data, the message will use a DATA_CHANGE
 *            event and the payload will contain a transactionId. The server
 *            will respond with a payload that also contains a transactionId but
 *            the event will be the transactionId as well. This allows the interface
 *            on the client to clear any timeouts and do anything else to insure
 *            that there is always a one to one correspondence between the client's
 *            data change request and the server's response, or else reliably
 *            detect if that is not the case.
 *
 *        The 'DATA_TABLE_REQUEST' is used by the client to ask for a lookup table.
 *
 *        The 'DATA_TABLE_SUCCESS' or 'DATA_TABLE_FAILURE' events are used by the
 *        server to respond to a DATA_TABLE_REQUEST from the client.
 *
 *    THE WAY THAT IT SHOULD BE:
 *
 *        - Retire the 'data' event. We already have the data namespace and that
 *          is not adding value to a significant degree.
 *        - The 'ADD' event will be used by the client to request a data addition
 *          for the server. The client will send the transactionId as the
 *          pendingId field within the record, which the server will
 *          strip and use accordingly. The client will not send a populated id
 *          field.
 *        - The 'CHG' event will be used by the client to request a data change
 *          from the server. The client will send the transactionId as the
 *          stateId field within the record, which the server will
 *          strip and use accordingly.
 *        - The 'DEL' event will be used by the client to request a data deletion
 *          on the server. The client will send the transactionId as the
 *          stateId field within the record, which the server will
 *          strip and use accordingly. In this case the client will only send
 *          the table name and the primary key.
 *        - The 'ADD_RESPONSE' event will be used by the server in response to
 *          data addition requests from the client. The response will specify the
 *          pendingId (as passed by the client originally), the result
 *          of the addition request, and a human readable message in case of failure.
 *        - The 'CHG_RESPONSE' event will be used by the server in response to
 *          data change requests from the client. The response will specify the
 *          stateId (as passed by the client originally), the result
 *          of the change request, and a human readable message in case of failure.
 *        - The 'DEL_RESPONSE' event will be used by the server in response to
 *          data deletion requests from the client. The response will specify the
 *          stateId (as passed by the client originally), the result
 *          of the deletion request, and a human readable message in case of failure.
 *        - The 'INFORM' event will be used by the server to inform the client
 *          of data changes that the client may be interested in.
 *        - The 'SELECT' event will be used by the client to retrieve data from
 *          the server. The payload will specify details such as a lookup table
 *          in it's entirety or a query by specified criteria.
 *        - The 'SELECT_RESPONSE' event will be used by the server to return data
 *          to the client that was requested with a prior 'SELECT' event to the
 *          server. This response may contain a failure and the client needs to
 *          check the payload accordingly.
 *
 *
 * Finally, messages are wrapped in an object that has a type field, which is
 * known as msgType within Elm due to the conflict with the 'type' keyword.
 * -------------------------------------------------------------------------------
 */

io = require('socket.io-client');
var app;      // Required: set by caller via setApp().


// --------------------------------------------------------
// Setup three different Socket.io namespaces for data,
// site, and system communications with the server.
// --------------------------------------------------------
var ioData = io.connect(window.location.origin + '/data');
var ioSite = io.connect(window.location.origin + '/site');
var ioSystem = io.connect(window.location.origin + '/system');

// --------------------------------------------------------
// Socket.io event types that we will use.
// --------------------------------------------------------
// The data namespace.
var INFORM = 'INFORM';      // Server to client data change notification in data namespace.
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
var ADHOC_LOGIN_RESPONSE = 'ADHOC_LOGIN_RESPONSE';    // Server to client login response, the adhocType of the message.
var ADHOC_USER_PROFILE = 'ADHOC_USER_PROFILE';    // Client to server for user profile request.
var ADHOC_USER_PROFILE_RESPONSE = 'ADHOC_USER_PROFILE_RESPONSE';  // Server to client user profile response.

// The site and system namespaces.
var SITE = 'site';          // All site messages use this message key.
var SYSTEM = 'system';      // All system messages use this message key.



// ========================================================
// ========================================================
// Utility functions.
// ========================================================
// ========================================================

/* --------------------------------------------------------
 * getNextTransactionId()
 *
 * Returns the next transaction id to use. This is used for
 * the data namespace with client initiated change requests.
 * The server will respond with an event of 'CHG:' + the
 * transaction id that the client sent.
 * -------------------------------------------------------- */
var nextTransactionId = 0
var getNextTransactionId = function() {
  return ++nextTransactionId;
};

/* --------------------------------------------------------
 * sendMsg()
 *
 * Sends a data message to the server using the event and
 * the payload passed. The site and system namespaces are
 * not ever used to send client to server messages.
 * -------------------------------------------------------- */
var sendMsg = function(msg, payload) {
  ioData.emit(msg, JSON.stringify(payload));
}

/* --------------------------------------------------------
 * wrapData()
 *
 * Wrap the tbl and data passed in an object assigned to
 * table and data fields respectively.
 * -------------------------------------------------------- */
var wrapData = function(tbl, data) {
  return {
    table: tbl,
    data: data
  };
}

/* --------------------------------------------------------
 * wrapAdHoc()
 *
 * Wrap the adhocType and data fields passed in an object.
 * -------------------------------------------------------- */
var wrapAdHoc = function(adhocType, data) {
  return {
    adhocType: adhocType,
    data: data
  };
}

// ========================================================
// ========================================================
// The data namespace.
// ========================================================
// ========================================================

// --------------------------------------------------------
// Server to client data change notifications.
// --------------------------------------------------------
ioData.on(INFORM, function(data) {
  if (! app) return;
});

// --------------------------------------------------------
// Client requesting data from the server.
// --------------------------------------------------------
ioData.on(SELECT_RESPONSE, function(data) {
  if (! app) return;

  var json = JSON.parse(data);
  app.ports.selectQueryResponse.send(json);
});

// --------------------------------------------------------
// Responses from the server due to client change requests.
// --------------------------------------------------------
ioData.on(CHG_RESPONSE, function(data) {
  if (! app) return;
  console.log(data);
  app.ports.updateResponse.send(JSON.parse(data));
});

ioData.on(ADD_RESPONSE, function(data) {
  if (! app) return;
  app.ports.createResponse.send(JSON.parse(data));
});

ioData.on(DEL_RESPONSE, function(data) {
  if (! app) return;
  app.ports.deleteResponse.send(JSON.parse(data));
});

// --------------------------------------------------------
// Responses from the server for ADHOC requests.
// --------------------------------------------------------
ioData.on(ADHOC_RESPONSE, function(data) {
  if (! app) return;
  app.ports.adhocResponse.send(JSON.parse(data));
});

// --------------------------------------------------------
// Client data request to the server. Payload will include
// specifics regarding the request.
// --------------------------------------------------------

// ========================================================
// ========================================================
// The system namespace.
// ========================================================
// ========================================================
ioSystem.on(SYSTEM, function(data) {
  if (! app) return;

  // type is a reserved term in Elm, so we rename it before sending it in.
  if (data.type) {
    data.msgType = data.type;
    delete data.type;
  }

  // Elm does not like uppercase keys in records, so rename and remove
  // extraneous nesting while we are at it.
  if (data.data && data.data.SYSTEM_LOG) {
    data.systemLog = data.data.SYSTEM_LOG;
    delete data.data;
  }
  app.ports.systemMessages.send(data);
});


/* --------------------------------------------------------
 * setApp()
 *
 * Save the reference to the Elm client. Nearly everything
 * in this module requires this so this needs to be set by
 * the caller as soon as possbile after the Elm client is
 * created.
 * -------------------------------------------------------- */
var setApp = function(theApp) {
  app = theApp;

  app.ports.login.subscribe(function(data) {
    sendMsg(ADHOC, wrapAdHoc(ADHOC_LOGIN, data));
  });

  app.ports.medicationTypeUpdate.subscribe(function(data) {
    sendMsg(CHG, wrapData('medicationType', data));
  });

  app.ports.medicationTypeCreate.subscribe(function(data) {
    sendMsg(ADD, wrapData('medicationType', data));
  });

  app.ports.medicationTypeDelete.subscribe(function(data) {
    sendMsg(DEL, wrapData('medicationType', data));
  });

  app.ports.requestUserProfile.subscribe(function(uselessData) {
    sendMsg(ADHOC, wrapAdHoc(ADHOC_USER_PROFILE, void 0));
  });

  app.ports.selectQuery.subscribe(function(query) {
    sendMsg(SELECT, query);
  });

};

module.exports = {
  setApp: setApp
};
