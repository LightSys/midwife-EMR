/*
 * -------------------------------------------------------------------------------
 * userRoles.js
 *
 * User and role management via a data api.
 * -------------------------------------------------------------------------------
 */

var Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , _ = require('underscore-contrib')
  , cfg = require('../../config')
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , User = require('../../models').User
  , Users = require('../../models').Users
  , Role = require('../../models').Role
  , Roles = require('../../models').Roles
  , hasRole = require('../../auth').hasRole
  , resError = require('./utils').resError
  , tf2Num = require('./utils').tf2Num
  , statusObject = require('./utils').statusObject
  , sendData = require('../../comm').sendData
  , DATA_CHANGE = require('../../comm').DATA_CHANGE
  ;

var resetPassword = function(req, res) {
  var id1 = req.parameters.id1;
  var op3 = req.parameters.op3;
  var id2 = req.parameters.id2
  var user;
  var supervisor;

  // --------------------------------------------------------
  // Sanity checks.
  // TODO: move the password checks to the User model.
  // --------------------------------------------------------
  if (! req.body || ! req.body.id || req.body.id != id1) {
    // Something is not right...abort.
    return resError(res, 400, 'userRoles.resetPassword(): body not supplied during POST.');
  }
  if (! req.body.password) {
    return resError(res, 400, 'userRoles.resetPassword(): password not passed.');
  }
  if (! req.body.password.length >= 8) {
    return resError(res, 400, 'userRoles.resetPassword(): password is not long enough.');
  }

  user = new User({id: id1});
  return user.hashPassword(req.body.password, function(er2, success) {
    if (er2) return resError(res, 400, er2);
    user
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save(null, {method: 'update'})
      .then(function(model) {
        res.end(JSON.stringify(statusObject(req, true, 'Password was changed', {})));
        // --------------------------------------------------------
        // Note that we don't notify clients of this change.
        // --------------------------------------------------------
      });
  });

}

/* --------------------------------------------------------
 * user()
 *
 * Manages user related data requests and changes.
 *
 * cfg.path.apiLoad = '/api/:op1/:op2/:id1/:op3?/:id2?';
 * Assumes that op1 = 'data' and op2 = 'user'.
 * -------------------------------------------------------- */
var user = function(req, res) {
  var method = req.method;
  var id1 = req.parameters.id1;
  var op3 = req.parameters.op3;
  var id2 = req.parameters.id2
  var supervisor;
  logInfo('userRoles.user(): [' + method + '] ' + req.url);
  if (hasRole(req, 'attending')) {
    supervisor = req.session.supervisor.id;
  }
  logInfo('id1: ' + id1 + ', op3: ' + op3 + ', id2: ' + id2);
  switch (method) {
  case 'GET':
    // Get a list of the users in the system.
    return Users
      .forge()
      .fetch({withRelated: ['role']})
      .then(function(list) {
        var userList = [];
        list.forEach(function(rec) {
          var r = _.omit(rec.toJSON(), 'password');
          userList.push(r);
        });
        return userList;
      })
      .then(function(userList) {
        return res.end(JSON.stringify(userList));
      });
    break;
  case 'POST':
    // TODO: Refactor this.
    if (op3 === 'passwordreset') return resetPassword(req, res);

    // --------------------------------------------------------
    // We post because the client may not send password, therefore
    // the whole record is not sent and therefore this might not
    // be an idempotent operation (which is what PUT is for).
    //
    // Use a closure to keep some of our variables from being polluters.
    // --------------------------------------------------------
    ;(function() {
      var user
        , processPW = false
        , fldsToOmit = ['password2','_csrf', 'role']  // role is the withRelated join from the GET.
        , defaultFlds = {
            isCurrentTeacher: '0'
            , status: '0'
          }
        , workingBody
        ;

      // --------------------------------------------------------
      // Sanity checks.
      // --------------------------------------------------------
      if (! req.body || ! req.body.id || req.body.id != id1) {
        // Something is not right...abort.
        return resError(res, 400, 'userRoles.user(): body not supplied during POST.');
      }
      if (req.body.password && req.body.password2 &&
          req.body.password.length > 0 && req.body.password2.length > 0) {
        processPW = true;
      }
      workingBody = req.body;
      tf2Num(workingBody, ['status', 'isCurrentTeacher']);
      User.checkFields(workingBody, false, processPW, function(err, result) {
        var editObj
          , user
          ;
        if (result.success) {
          if (! processPW) {
            // If the password is not specified, do not replace it with an
            // empty string in the database.
            fldsToOmit.push('password');
          }

          // --------------------------------------------------------
          // Set field defaults which allows unsettings checkboxes.
          // --------------------------------------------------------
          editObj = _.extend(defaultFlds, {updatedBy: req.session.user.id}, _.omit(workingBody, fldsToOmit));
          user = new User(editObj);
          if (hasRole(req, 'attending')) {
            supervisor = req.session.supervisor.id;
          }
          if (processPW) {
            return user.hashPassword(editObj.password, function(er2, success) {
              if (er2) return resError(res, 400, er2);
              user
                .setUpdatedBy(req.session.user.id)
                .setSupervisor(supervisor)
                .save(null, {method: 'update'})
                .then(function(model) {
                  res.end(JSON.stringify(
                    statusObject(req, true, 'User was updated',
                      {}
                    ))
                  );

                  // --------------------------------------------------------
                  // Notify all clients of the change.
                  // --------------------------------------------------------
                  var data = {
                    table: 'user',
                    id: editObj.id,
                    updatedBy: req.session.user.id
                  };
                  sendData(DATA_CHANGE, JSON.stringify(data));
                });
            });
          } else {
            return user
              .setUpdatedBy(req.session.user.id)
              .setSupervisor(supervisor)
              .save(null, {method: 'update'})
              .then(function(model) {
                res.end(JSON.stringify(
                  statusObject(req, true, 'User was updated',
                    {}
                  ))
                );

                // --------------------------------------------------------
                // Notify all clients of the change.
                // --------------------------------------------------------
                var data = {
                  table: 'user',
                  id: editObj.id,
                  updatedBy: req.session.user.id,
                  sessionID: req.sessionID
                };
                sendData(DATA_CHANGE, JSON.stringify(data));
              });
          }
        } else {
          // TODO: send data message to user explaining error???
          return resError(res, 400, result.messages.join(', '));
        }
      });
    })();
    break;
  default:
    logInfo(method + ': ' + req.url)
  }
}

module.exports = {
  user: user
};
