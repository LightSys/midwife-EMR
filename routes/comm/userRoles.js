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
  , DATA_ADD = require('../../commUtils').getConstants('DATA_ADD')
  , DATA_CHANGE = require('../../commUtils').getConstants('DATA_CHANGE')
  , DATA_DELETE = require('../../commUtils').getConstants('DATA_DELETE')
  , sendData = require('../../commUtils').sendData
  , assertModule = require('./userRoles_assert')
  , DO_ASSERT = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
  ;


var addUser = function(data, userInfo, cb) {
  var rec = data;
  var omitFlds = ['id', 'pendingId'];
  var existingUser = User.forge({username: rec.username});
  var user;

  // --------------------------------------------------------
  // Make sure the user does not already exist.
  // --------------------------------------------------------
  existingUser.fetch().then(function(user) {
    if (user) {
      return cb('Username is already taken.', false);
    }

    // --------------------------------------------------------
    // Insure there is a password specified.
    // --------------------------------------------------------
    if (rec.password.length < 8) {
      return cb('Password must be at least 8 characters long.', false);
    }

    // --------------------------------------------------------
    // Save the new user and return details to caller.
    // --------------------------------------------------------
    user = new User(_.omit(rec, omitFlds));
    user.hashPassword(rec.password, function(err, success) {
      if (err || ! success) {
        return cb(err, false);
      } else {
        user
          .setUpdatedBy(userInfo.user.id)
          .setSupervisor(userInfo.supervisorId)
          .save({}, {method: 'insert'})
          .then(function(user2) {
            cb(null, true, user2);

            // --------------------------------------------------------
            // Notify all clients of the change.
            // --------------------------------------------------------
            var notify = {
              table: 'user',
              id: user2.id,
              updatedBy: userInfo.user.id,
              sessionID: userInfo.sessionID
            };
            return sendData(DATA_ADD, JSON.stringify(notify));
          })
          .caught(function(err) {
            return cb(err, false);
          });
      }
    });
  });
};


// --------------------------------------------------------
// Note: we only delete a user when the user has not changed
// any other records in the database. We use the database
// deletion constraints to catch this.
// --------------------------------------------------------
var delUser = function(data, userInfo, cb) {
  var rec = _.omit(data, ['stateId']);
  new User({id: rec.id})
    .destroy()
    .then(function(deletedRec) {
      cb(null, true);

      // --------------------------------------------------------
      // Notify all clients of the change.
      // --------------------------------------------------------
      var notify = {
        table: 'user',
        id: rec.id,
        updatedBy: userInfo.user.id,
        sessionID: userInfo.sessionID
      };
      return sendData(DATA_DELETE, JSON.stringify(notify));
    })
    .caught(function(err) {
      return cb(err);
    });
};


var updateUser = function(data, userInfo, cb) {
  var rec = data;
  var omitFlds = ['stateId', 'password'];
  var user = new User({id: rec.id});

  if (rec.password.length >= 8) {
    user.fetch()
      .then(function(user) {
        user.hashPassword(rec.password, function(err, success) {
          if (err || ! success) {
            return cb(err, false);
          } else {
            user
              .setUpdatedBy(userInfo.user.id)
              .setSupervisor(userInfo.supervisorId)
              .save(_.omit(rec, omitFlds))
              .then(function(rec2) {
                cb(null, true, rec2.id);

                // --------------------------------------------------------
                // Notify all clients of the change.
                // --------------------------------------------------------
                var notify = {
                  table: 'user',
                  id: rec2.id,
                  updatedBy: userInfo.user.id,
                  sessionID: userInfo.sessionID
                };
                return sendData(DATA_CHANGE, JSON.stringify(notify));
              })
              .caught(function(err) {
                return cb(err, false);
              });
          }
        });
      });
  } else {
    user.fetch().then(function(user) {
      if (user) {
        user
          .setUpdatedBy(userInfo.user.id)
          .setSupervisor(userInfo.supervisorId)
          .save(_.omit(rec, omitFlds))
          .then(function(rec2) {
            cb(null, true, rec2.id);

            // --------------------------------------------------------
            // Notify all clients of the change.
            // --------------------------------------------------------
            var notify = {
              table: 'user',
              id: rec2.id,
              updatedBy: userInfo.user.id,
              sessionID: userInfo.sessionID
            };
            return sendData(DATA_CHANGE, JSON.stringify(notify));
          })
          .caught(function(err) {
            return cb(err, false);
          });
        } else {
          return cb('User not found.', false);
        }
    });
  }
};


var getUserProfile = function(id, cb) {
  if (DO_ASSERT) assertModule.getUserProfile(id, cb);
  var columns = ['id', 'username', 'firstname', 'lastname', 'email', 'lang',
      'shortName', 'displayName', 'role_id'];
  var user = new User({id: id});
  user
    .fetch({columns: columns, withRelated: ['role']})
    .then(function(userObj) {
      if (userObj) {
        // Massage the data into the format the Elm client is expecting.
        var profile = userObj.toJSON();
        profile.userId = profile.id;
        delete profile.id;
        profile.roleName = profile.role.name;
        delete profile.role;
        return cb(null, true, profile);
      } else {
        return cb('User not found.', false);
      }
    })
    .caught(function(err) {
      return cb(err, false);
    });
};


/* --------------------------------------------------------
 * updateUserProfile()
 *
 * Allows the user to update certain fields which are a
 * part of their user profile. Currently all of the allowed
 * fields are within the user table.
 *
 * Note that the Elm client sends the id as userId.
 * -------------------------------------------------------- */
var updateUserProfile = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateUserProfile(data, userInfo, cb);
  var rec = _.omit(data, ['role_id', 'username']);
  rec.id = rec.userId;
  delete rec.userId;
  var omitFlds = ['password'];
  var user = new User({id: rec.id});

  // --------------------------------------------------------
  // Sanity check that the current user is the same as the
  // user information being sought to update.
  // --------------------------------------------------------
  if (rec.id !== userInfo.user.id) {
    return cb("Error: you can only update your own user profile.", false);
  }

  if (rec.password.length >= 8) {
    user.fetch()
      .then(function(user) {
        if (user) {
          user.hashPassword(rec.password, function(err, success) {
            if (err || ! success) {
              return cb(err, false);
            } else {
              user
                .setUpdatedBy(userInfo.user.id)
                .setSupervisor(userInfo.supervisorId)
                .save(_.omit(rec, omitFlds), "", {}, {method:"update", patch:true})
                .then(function(rec2) {
                  cb(null, true, rec2.id);

                  // --------------------------------------------------------
                  // Notify all clients of the change.
                  // --------------------------------------------------------
                  var notify = {
                    table: 'user',
                    id: rec2.id,
                    updatedBy: userInfo.user.id,
                    sessionID: userInfo.sessionID
                  };
                  return sendData(DATA_CHANGE, JSON.stringify(notify));
                })
                .caught(function(err) {
                  return cb(err, false);
                });
            }
          });
        } else {
          return cb('User not found.', false);
        }
      });
  } else {
    user.fetch().then(function(user) {
      if (user) {
        user
          .setUpdatedBy(userInfo.user.id)
          .setSupervisor(userInfo.supervisorId)
          .save(_.omit(rec, omitFlds), "", {}, {method:"update", patch:true})
          .then(function(rec2) {
            cb(null, true, rec2.id);

            // --------------------------------------------------------
            // Notify all clients of the change.
            // --------------------------------------------------------
            var notify = {
              table: 'user',
              id: rec2.id,
              updatedBy: userInfo.user.id,
              sessionID: userInfo.sessionID
            };
            return sendData(DATA_CHANGE, JSON.stringify(notify));
          })
          .caught(function(err) {
            return cb(err, false);
          });
        } else {
          return cb('User not found.', false);
        }
    });
  }
};


/* --------------------------------------------------------
 * saveUser()
 *
 * RETIRED
 *
 * NOTE: this was developed for the React/Redux client and
 * has not yet been repurposed for other uses.
 *
 * Adds or updates a user. Can be used by an administrator
 * to create or update a user or a user to update their
 * own profile.
 *
 * param       payload  - the payload of the action object
 * param       userInfo - the user info of the user doing the saving
 * param       cb       - the callback, returns new user object
 * return      undefined
 * -------------------------------------------------------- */
var saveUser = function(payload, userInfo, cb) {
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
    , userObj = payload.user? payload.user: void 0;
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
        .setSupervisor(userInfo.supervisorId)
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
  addUser,
  delUser,
  getUserProfile,
  updateUser,
  updateUserProfile,
  saveUser  // retired
}
