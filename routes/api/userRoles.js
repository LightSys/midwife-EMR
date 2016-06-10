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
  , errToResponse = require('./utils').errToResponse
  , sendData = require('../../comm').sendData
  , DATA_CHANGE = require('../../comm').DATA_CHANGE
  ;

var resetPassword = function(req, res) {
  var user
    , isProfileUpdate = this && this.isProfileUpdate? true: false
    , supervisor
    ;

  // --------------------------------------------------------
  // Sanity checks.
  // TODO: move the password checks to the User model.
  // --------------------------------------------------------
  if (! req.body || ! req.body.id) {
    // Something is not right...abort.
    return resError(res, 400, 'userRoles.resetPassword(): body not supplied during POST.');
  }
  if (isProfileUpdate && req.body.id != req.session.user.id) {
    return resError(res, 400, 'userRoles.resetPassword(): id passed in body does not match id in session.');
  }
  if (! req.body.password) {
    return resError(res, 400, 'userRoles.resetPassword(): password not passed.');
  }
  if (! req.body.password.length >= 8) {
    return resError(res, 400, 'userRoles.resetPassword(): password is not long enough.');
  }

  user = new User({id: req.body.id});
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
 * saveUser()
 *
 * Save the user to the database. Can be called by an
 * administrator for any user or for any user for their
 * own profile.
 *
 * Note: to restrict the function to profile only use, set
 * isProfileUpdate to true in the context that the function
 * runs within.
 *
 * E.g.
 * (saveUser.bind({isProfileUpdate: true}))(req, res);
 * -------------------------------------------------------- */
var saveUser = function(req, res) {
  var user
    , processPW = false
    , fldsToOmit = ['password', 'password2','_csrf', 'role']  // role is the withRelated join from the GET.
    , defaultFlds = {
        isCurrentTeacher: '0'
        , status: '0'
      }
    , isProfileUpdate = this && this.isProfileUpdate? true: false
    , workingBody
    , supervisor
    , isNewUser = false
    ;

  if (hasRole(req, 'attending')) {
    supervisor = req.session.supervisor.id;
  }

  if (isProfileUpdate) {
    // User's cannot change their own usernames.
    fldsToOmit.push('username');
  }

  // --------------------------------------------------------
  // Sanity checks.
  // --------------------------------------------------------
  if (! req.body) {
    // Something is not right...abort.
    return resError(res, 400, 'userRoles.user(): body not supplied during POST.');
  }
  if (! isProfileUpdate && req.body.id != req.parameters.id1) {
    return resError(res, 400, 'userRoles.user(): id passed in url does not match id in body.');
  }

  if (! _.has(req.body, 'id')) {
    isNewUser = true;
  }

  workingBody = req.body;
  tf2Num(workingBody, ['status', 'isCurrentTeacher']);
  User.checkFields(workingBody, false, processPW, function(err, result) {
    var editObj
      , user
      ;
    if (result.success) {
      // --------------------------------------------------------
      // Set field defaults which allows unsettings checkboxes.
      // --------------------------------------------------------
      editObj = _.extend(defaultFlds, {updatedBy: req.session.user.id}, _.omit(workingBody, fldsToOmit));
      user = new User(editObj);
      if (hasRole(req, 'attending')) {
        supervisor = req.session.supervisor.id;
      }
      return user
        .setUpdatedBy(req.session.user.id)
        .setSupervisor(supervisor)
        .save(null, {method: isNewUser? 'insert': 'update'})
        .then(function(model) {
          res.end(JSON.stringify(
            statusObject(req, true, 'User was ' + isNewUser? 'added': 'updated',
              model.toJSON()
            ))
          );

          // --------------------------------------------------------
          // Notify all clients of the change.
          // --------------------------------------------------------
          var data = {
            table: 'user',
            id: model.get('id'),
            updatedBy: req.session.user.id,
            sessionID: req.sessionID
          };
          sendData(DATA_CHANGE, JSON.stringify(data));
        })
        .catch(function(err) {
          logError('--- Caught error ---');
          logError(err);
          var errRes = errToResponse(err);
          res.statusCode = errRes.statusCode;
          res.end(JSON.stringify(statusObject(req, false, errRes.msg)));
        });
    } else {
      res.statusCode = 400;
      return res.end(JSON.stringify(statusObject(req, false, result.messages.join(', '))));
    }
  });
};

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
  if (hasRole(req, 'attending')) {
    supervisor = req.session.supervisor.id;
  }
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

    // Save the user record.
    saveUser(req, res);

    break;

  default:
    logInfo('Unexpected route: ' + method + ': ' + req.url)
  }
}

/* --------------------------------------------------------
 * profile()
 *
 * Return the current user's user information (their profile)
 * and allow the user to update most of their information as
 * well as change their password.
 * -------------------------------------------------------- */
var profile = function(req, res) {
  var method = req.method
    , url = req.url
    , userRec
    , userId = req.session.user.id
    ;

  if (hasRole(req, 'attending')) {
    supervisor = req.session.supervisor.id;
  }
  switch (method) {
  case 'GET':
    return User
      .forge({id: userId})
      .fetch()
      .then(function(rec) {
        userRec = _.omit(rec.toJSON(), 'password');
        return userRec;
      })
      .then(function(userRec) {
        return res.end(JSON.stringify(userRec));
      });
    break;

  case 'POST':
    // TODO: Refactor this.
    if (url === cfg.path.apiProfilePassword) {
      return (resetPassword.bind({isProfileUpdate: true}))(req, res);
    }

    (saveUser.bind({isProfileUpdate: true}))(req, res);
    break;

  default:
    logInfo('Unexpected route: ' + method + ': ' + req.url)
  }

}

module.exports = {
  user: user,
  profile: profile
};
