/* 
 * -------------------------------------------------------------------------------
 * clientConsole.js
 *
 * Stores console messages from the L&D clients.
 * ------------------------------------------------------------------------------- 
 */


const _ = require('underscore')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , ClientConsole = require('../../models').ClientConsole
  ;


/* --------------------------------------------------------
 * saveClientConsole()
 *
 * Save a client console message and related information
 * into the clientConsole table.
 *
 * param       payload
 * param       userInfo
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
const saveClientConsole = (payload, userInfo, cb) => {
  var rec = new ClientConsole({
    user: userInfo.user.id
    , session_id: userInfo.sessionID
    , timestamp: payload.timestamp
    , severity: payload.severity
    , message: payload.message
  })
  .save()
  .then((rec) => {
    return cb(null);
  })
  .catch((err) => {
    return cb(err);
  });
};

module.exports = {
  saveClientConsole
};
