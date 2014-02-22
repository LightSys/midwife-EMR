/*
 * -------------------------------------------------------------------------------
 * auth.js
 *
 * Helper functions for authentication, etc.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , cfg = require('./config')
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
 *  Also provides isAuthenticated() and is('someRoleName')
 *  functions on the req.session.roleInfo object.
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
        , roleNames: []
        , is: function(roleName) {
            if (! req.session.roleInfo) return false;
            return _.contains(req.session.roleInfo.roleNames, roleName);
        }
      }
      ;

    if (req.session && ! req.session.roleInfo) {
      if (req.user && req.user.related) {
        roleInfo.roleNames = _.pluck(req.user.related('roles').toJSON(), 'name');
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
 *     called so that the roles have already been placed
 *     in the request object.
 *
 * param        roles - an array of role names
 * return       function
 * -------------------------------------------------------- */
var inRoles = function(roles) {
  return function(req, res, next) {
    if (_.intersection(req.session.roleInfo.roleNames, roles).length > 0) return next();
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
 *
 * param       req
 * param       res
 * param       next
 * return      undefined
 * -------------------------------------------------------- */
function auth(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  res.redirect(cfg.path.login);
}


module.exports = {
  inRoles: inRoles
  , setRoleInfo: setRoleInfo
  , auth: auth
};

