/* 
 * -------------------------------------------------------------------------------
 * auth.js
 *
 * Helper functions for authentication, etc.
 * ------------------------------------------------------------------------------- 
 */


var someone = function(req, cb) {
  return cb(null, req.isAuthenticated());
};

var isAdmin = function(req, cb) {
  var admin = req.user.related('roles')
    .findWhere({name: 'administrator'});

  return cb(null, admin != undefined);
};

module.exports = {
  someone: someone
  , isAdmin: isAdmin
};

