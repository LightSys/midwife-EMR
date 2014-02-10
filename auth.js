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
 * isInRole()
 *
 * Determines whether the request passed belongs to a user
 * that is in the role specified.
 *
 * param       req
 * param       roleName
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var isInRole = function(req, roleName, cb) {
  someone(req, function(err, isSomeone) {
    if (! isSomeone) return cb(null, false);
    var role = req.user.related('roles')
      .findWhere({name: roleName});
    return cb(null, role != undefined);
  });
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
  isInRole(req, 'administrator', function(err, isInRole) {
    if (err) return cb(err);
    return cb(null, isInRole);
  });
};

/* --------------------------------------------------------
 * isGuard()
 *
 * Someone who is a member of the guard role.
 *
 * param       req
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var isGuard = function(req, cb) {
  isInRole(req, 'guard', function(err, isInRole) {
    if (err) return cb(err);
    return cb(null, isInRole);
  });
};

/* --------------------------------------------------------
 * isStudent()
 *
 * Someone who is a member of the student role.
 *
 * param       req
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var isStudent = function(req, cb) {
  isInRole(req, 'student', function(err, isInRole) {
    if (err) return cb(err);
    return cb(null, isInRole);
  });
};

/* --------------------------------------------------------
 * isClerk()
 *
 * Someone who is a member of the clerk role.
 *
 * param       req
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var isClerk = function(req, cb) {
  isInRole(req, 'clerk', function(err, isInRole) {
    if (err) return cb(err);
    return cb(null, isInRole);
  });
};

/* --------------------------------------------------------
 * isSupervisor()
 *
 * Someone who is a member of the supervisor role.
 *
 * param       req
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var isSupervisor = function(req, cb) {
  isInRole(req, 'supervisor', function(err, isInRole) {
    if (err) return cb(err);
    return cb(null, isInRole);
  });
};


module.exports = {
  someone: someone
  , isAdmin: isAdmin
  , isGuard: isGuard
  , isClerk: isClerk
  , isStudent: isStudent
  , isSupervisor: isSupervisor
};

