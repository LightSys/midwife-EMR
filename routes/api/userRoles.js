/* 
 * -------------------------------------------------------------------------------
 * userRoles.js
 *
 * User and role management via a data api.
 * ------------------------------------------------------------------------------- 
 */

var cfg = require('../../config')
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , User = require('../../models').User
  , Users = require('../../models').Users
  , Role = require('../../models').Role
  , Roles = require('../../models').Roles
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , _ = require('underscore-contrib')
  ;


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
  var id1 = req.params.id;
  var op3 = req.params.op3;
  var id2 = req.params.id2
  switch (method) {
  case 'GET':
    // Get a list of the users in the system.
    return Users
      .forge()
      .fetch({withRelated: ['roles']})
      .then(function(list) {
        var userList = [];
        list.forEach(function(rec) {
          var r = _.omit(rec.toJSON(), 'password');
          userList.push(r);
        });
        return userList;
      })
      .then(function(userList) {
        // --------------------------------------------------------
        // The user records contain a roles array, yet the application
        // assumes that each user can only have one role. Simplify
        // by rewriting roles as as role, an object. Also, remove the
        // pivot information because it is not needed on the client.
        // --------------------------------------------------------
        var newList = userList.map(function(u) {
          u.role = u.roles[0];
          delete u.roles;
          delete u.role._pivot_user_id;
          delete u.role._pivot_role_id;
          return u;
        });
        return newList;
      })
      .then(function(userList) {
        return res.end(JSON.stringify(userList));
      });
  default:
    logInfo(method + ': ' + req.url)
  }
  return res.end(JSON.stringify({}));
}

module.exports = {
  user: user
};
