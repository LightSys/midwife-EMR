/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * All routing modules are exported here.
 * -------------------------------------------------------------------------------
 */
var cfg = require('../../config')
  , adminMenuLeft = []
  , adminMenuRight = []
  ;


adminMenuLeft.push({label: 'Home', url: '/'});
adminMenuLeft.push({label: 'Users', url: '/users'});
adminMenuLeft.push({label: 'Logout', url: '/logout'});

adminMenuRight.push({label: 'version 0.7.2', url: '#version'});  // Meant to be disabled on client.
adminMenuRight.push({label: 'Profile', url: '/profile'});

/* --------------------------------------------------------
 * params()
 *
 * Parameter processing for all API calls. Parses the path
 * and populates the req object with information for
 * downstream processing in req.parameters.
 * -------------------------------------------------------- */
var params = function(req, res, next) {
  req.parameters = {};
  if (req.params.op1) req.parameters.op1 = req.params.op1;
  if (req.params.op2) req.parameters.op2 = req.params.op2;
  if (req.params.op3) req.parameters.op3 = req.params.op3;
  if (req.params.id1) req.parameters.id1 = req.params.id1;
  if (req.params.id2) req.parameters.id2 = req.params.id2;
  return next();
};

/* --------------------------------------------------------
 * doSpa()
 *
 * Determine if the request should load a SPA response or
 * not based upon the role the user has. This affords a
 * transition of the application from full page loads to
 * SPA in stages.
 * -------------------------------------------------------- */
var doSpa = function(req, res, next) {
  var data;
  var connSid;

  // --------------------------------------------------------
  // Get the connection.sid cookie so that the client can
  // use the data API.
  //
  // NOTE: passing cookies to the client might not be
  // necessary when {credentials: 'same-origin'} is used in
  // the header of the client's call to the server.
  // TODO: remove if not needed.
  // --------------------------------------------------------
  res.req.headers.cookie.split(';').forEach(function(c) {
    var cookie = c.trim();
    if (/^connect\.sid/.test(cookie)) {
      connSid = cookie.split('=', 2)[1];
    }
  });

  if (req.session.user && req.session.user.role) {
    if (req.session.user.role.name === 'administrator') {
      data = {
        cfg: {
          siteTitle: cfg.site.title
          , siteTitleLong: cfg.site.titleLong
        },
        menuLeft: adminMenuLeft,
        menuRight: adminMenuRight,
        cookies: {
          '_csrf': req.csrfToken(),
          'connect.sid': connSid
        },
        isAuthenticated: req.isAuthenticated()
      };
      console.log(data);
      return res.render('main', {cfg: data});
    }
  }
  return next();
}

module.exports = {
  params: params
  , history: require('./history')
  , userRoles: require('./userRoles')
  , spa: require('./spa')
  , doSpa: doSpa
};
