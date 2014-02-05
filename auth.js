/* 
 * -------------------------------------------------------------------------------
 * auth.js
 *
 * Helper functions for authentication, etc.
 * ------------------------------------------------------------------------------- 
 */


/* --------------------------------------------------------
 * someone()
 *
 * Someone is anyone who is already authenticated. This is
 * opposed to anyone (from the Roz module) that is literally
 * anyone.
 *
 * param       req
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var someone = function(req, cb) {
  return cb(null, req.isAuthenticated());
};

/* --------------------------------------------------------
 * isAdmin()
 *
 * Someone who is a member of the admin role.
 *
 * param       req
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var isAdmin = function(req, cb) {
  someone(req, function(err, isSomeone) {
    if (! isSomeone) return cb(null, false);
    var admin = req.user.related('roles')
      .findWhere({name: 'administrator'});
    return cb(null, admin != undefined);
  });
};

var isStudent = function(req, cb) {
  someone(req, function(err, isSomeone) {
    if (! isSomeone) return cb(null, false);
    var student = req.user.related('roles')
      .findWhere({name: 'student'});
    return cb(null, student != undefined);
  });
};


module.exports = {
  someone: someone
  , isAdmin: isAdmin
  , isStudent: isStudent
};

