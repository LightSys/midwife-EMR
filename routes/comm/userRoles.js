/*
 * -------------------------------------------------------------------------------
 * userRoles.js
 *
 * Manages the communication details for user/role management via sockets.
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
  , tf2Num = require('../api/utils').tf2Num
  ;

/* --------------------------------------------------------
 * saveUser()
 *
 * Adds or updates a user. Can be used by an administrator
 * to create or update a user or a user to update their
 * own profile.
 *
 * param       userObj  - the user object that is being saved
 * param       userInfo - the user info of the user doing the saving
 * param       cb       - the callback, returns new user object
 * return      undefined
 * -------------------------------------------------------- */
var saveUser = function(userObj, userInfo, cb) {
  var processPW = false
    , fldsToOmit = ['password', 'password2','_csrf', 'role']  // role is the withRelated join from the GET.
    , defaultFlds = {
        isCurrentTeacher: '0'
        , status: '0'
      }
    , isProfileUpdate = this && this.isProfileUpdate? true: false
    , workingBody
    , isNewUser = false
    , hasRole = function(role) {
        // Shadow the outer hasRole.
        if (! userInfo && userInfo.roleInfo && userInfo.roleInfo.roleName) return false;
        return userInfo.roleInfo.roleName === role
      }
    , errMsg
    ;

  if (isProfileUpdate) {
    // User's cannot change their own usernames.
    fldsToOmit.push('username');
  }

  // --------------------------------------------------------
  // Sanity checks.
  // --------------------------------------------------------
  if (! userObj) {
    return cb('User not supplied.');
  }
  if (isProfileUpdate && ! userObj.id) {
    return cb('User id not passed.');
  }

  if (! _.has(userObj, 'id')) {
    isNewUser = true;
  }

  workingBody = _.extend({}, userObj);
  tf2Num(workingBody, ['status', 'isCurrentTeacher']);
  User.checkFields(workingBody, false, processPW, function(err, result) {
    var editObj
      , userRec
      ;
    if (result.success) {
      // --------------------------------------------------------
      // Set field defaults which allows unsettings checkboxes.
      // --------------------------------------------------------
      editObj = _.extend(defaultFlds, {updatedBy: userInfo.user.id}, _.omit(workingBody, fldsToOmit));
      userRec = new User(editObj);
      return userRec
        .setUpdatedBy(userInfo.user.id)
        .setSupervisor(userInfo.user.supervisor)
        .save(null, {method: isNewUser? 'insert': 'update'})
        .then(function(model) {
          cb(null, model.toJSON());
        })
        .catch(function(err) {
          logError('--- Caught error during DB update ---');
          logError(err);
          return cb(err);
        });
    } else {
      errMsg = result.messages.join(', ');
      logError('--- Caught error during user sanity check ---');
      logError(errMsg);
      return cb(errMsg);
    }
  });
};



module.exports = {
  saveUser: saveUser
}
