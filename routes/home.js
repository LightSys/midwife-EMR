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
    , revision: req.session.appRevisions
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
      var options = {}
        ;
      if (err) { return next(err); }
      // --------------------------------------------------------
      // Store user information in the session sans sensitive info.
      // --------------------------------------------------------
      req.session.user = _.omit(user.toJSON(), 'password');;

      // --------------------------------------------------------
      // Record the event and redirect to the home page.
      // --------------------------------------------------------
      options.sid = req.sessionID;
      options.user_id = user.get('id');
      Event.loginEvent(options).then(function() {
        var pendingUrl = req.session.pendingUrl
          ;
        if (pendingUrl) {
          delete req.session.pendingUrl;
          req.session.save();
          res.redirect(pendingUrl);
        } else {
          return res.redirect('/');
        }
      });
    });
  })(req, res, next);
};

var logout = function(req, res) {
  var options = {}
    ;
  if (req.session.user && req.session.user.id) {
    options.sid = req.sessionID;
    options.user_id = req.session.user.id;
    Event.logoutEvent(options).then(function() {
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


