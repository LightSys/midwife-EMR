/* 
 * -------------------------------------------------------------------------------
 * home.js
 *
 * Routes for home and logging in.
 * ------------------------------------------------------------------------------- 
 */

var passport = require('passport')
  , Promise = require('bluebird')
  , loginRoute = '/login'
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , _ = require('underscore')
  , Event = require('../models').Event
  ;

var home = function(req, res) {
  res.render('content', {
    title: req.gettext('Home')
    , user: req.session.user
  });
};

var login = function(req, res) {
  var data = {
    title: req.gettext('Please log in')
    , message: req.session.messages
  };
  res.render('login', data);
};

var loginPost = function(req, res, next) {
  passport.authenticate('local', function(err, user, info) {
    if (err) {
      logError('err: %s', err);
      return next(err);
    }
    if (!user) {
      if (req.session) {
        req.session.messages =  [info.message];
      }
      return res.redirect(loginRoute);
    }
    req.logIn(user, function(err) {
      var note = 'sid: ' + req.sessionID
        ;
      if (err) { return next(err); }
      // --------------------------------------------------------
      // Store user information in the session sans sensitive info.
      // --------------------------------------------------------
      req.session.user = _.omit(user.toJSON(), 'password');;

      // --------------------------------------------------------
      // Record the event and redirect to the home page.
      // --------------------------------------------------------
      Event.loginEvent(user.get('id'), note).then(function() {
        return res.redirect('/');
      });
    });
  })(req, res, next);
};

var logout = function(req, res) {
  var note = 'sid: ' + req.sessionID
    ;
  if (req.session.user && req.session.user.id) {
    Event.logoutEvent(req.session.user.id, note).then(function() {
      req.session.destroy(function(err) {
        res.redirect(loginRoute);
      });
    });
  } else {
    res.redirect(loginRoute);
  }
};



module.exports = {
  home: home
  , login: login
  , loginPost: loginPost
  , logout: logout
};


