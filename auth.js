/*
 * -------------------------------------------------------------------------------
 * auth.js
 *
 * Helper functions for authentication, etc.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , cfg = require('./config')
  , logInfo = require('./util').logInfo
  ;

/* --------------------------------------------------------
 * setRoleInfo()
 *
 * A partial function that is initialized with the Express
 * app object when included. The returned function sets the
 * role information in app.locals so that it is available
 * in all templates rendered.
 *
 * Usage:
 *  var setRoleInfo = require('auth').setRoleInfo(app);
 *
 *  Then include setRoleInfo in the routes:
 *
 *  app.get(somePath, setRoleInfo, otherFunction, handler);
 *
 *  Provides the isAuthenticated boolean on the session object.
 *
 *  Also provides hasRole('someRoleName') on the roleInfo
 *  object that is exposed to the templates. This is not on the
 *  session object. Instead, use the auth.hasRole() function.
 *
 * param       req
 * param       res
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var setRoleInfo = function(app) {
  return function(req, res, next) {
    var roleInfo = {
        isAuthenticated: req.isAuthenticated()
        , roleName: undefined
          // Note that hasRole() will not be saved to the session so is available
          // in app.locals only, which means the templates. Use auth.hasRole()
          // for other uses.
        , hasRole: function(roleName) {
            if (! req.session.roleInfo) return false;
            return req.session.roleInfo.roleName === roleName;
        }
      }
      ;

    if (req.session && ! req.session.roleInfo) {
      if (req.user && req.user.related) {
        roleInfo.roleName = req.user.related('role').toJSON().name;
        req.session.roleInfo = roleInfo;
        req.session.save();
      }
    }

    // --------------------------------------------------------
    // app.locals is for the templates and req.session is for
    // hasSuper() and other processing.
    // --------------------------------------------------------
    app.locals.roleInfo = roleInfo;
    next();
  };
};

/* --------------------------------------------------------
 * clearRoleInfo()
 *
 * Remove the roleInfo information from the app.locals that
 * is used in the templates. This makes sense to do when the
 * user is logging out.
 *
 * param       app - the application object
 * return      function to be used in an Express route.
 * -------------------------------------------------------- */
var clearRoleInfo = function(app) {
  return function(req, res, next) {
    delete app.locals.roleInfo;
    next();
  };
};

/* --------------------------------------------------------
 * hasRole()
 *
 * Returns true if the passed role matches the role that the
 * user is a member of.
 *
 * param       req
 * param       role
 * return      boolean
 * -------------------------------------------------------- */
var hasRole = function(req, role) {
  if (! req.session || ! req.session.roleInfo) return false;
  return req.session.roleInfo.roleName === role
};

/* --------------------------------------------------------
 * inRoles()
 *
 * Partial function that expects an array of role names to
 * be passed, any of which would satisfy the authorization
 * requirements if the user is in that role. Returns a
 * function that can be used in Express routing statements.
 * Returned function returns an error if the user is not
 * authorized per the roles passed.
 *
 * Assumptions:
 *  1. That the user is already logged in.
 *  2. That the function setRoleInfo() has already been
 *     called so that the role has already been placed
 *     in the request object.
 *
 * param        roles - an array of role names
 * return       function
 * -------------------------------------------------------- */
var inRoles = function(roles) {
  return function(req, res, next) {
    if (_.contains(roles, req.session.roleInfo.roleName)) return next();
    var unauth = new Error(req.gettext('You are not authorized for this page.'));
    unauth.details = 'User: ' + req.session.user.id + ', path: ' + req.path + ', method: ' + req.method;
    unauth.status = 403;
    return next(unauth);
  };
};

/* --------------------------------------------------------
 * auth()
 *
 * Is the user already authenticated?
 * -------------------------------------------------------- */
function auth(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  if (req.session) {
    req.session.pendingUrl = req.url;
    req.session.save();
  }
  res.redirect(cfg.path.login);
}

/* --------------------------------------------------------
 * spaAuth()
 *
 * Like auth(), but returns a 401 if the user is not
 * authenticated.
 * -------------------------------------------------------- */
function spaAuth(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  res.statusCode = 401;
  res.end();
  logInfo('Unauthorized: [' + req.method + '] ' + req.url);
}

module.exports = {
  inRoles: inRoles
  , setRoleInfo: setRoleInfo
  , clearRoleInfo: clearRoleInfo
  , auth: auth
  , spaAuth: spaAuth
  , hasRole: hasRole
};

