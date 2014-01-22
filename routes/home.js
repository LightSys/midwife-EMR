/* 
 * -------------------------------------------------------------------------------
 * home.js
 *
 * Routes for home and logging in.
 * ------------------------------------------------------------------------------- 
 */

var passport = require('passport')
  , loginRoute = '/login'
  , _ = require('underscore')
  ;

var home = function(req, res) {
  console.log('home');
  console.dir(req);
  res.render('content', {
    title: req.gettext('Testing')
    , user: req.session.user
  });
};

var login = function(req, res) {
  console.log('login');
  var data = {
    title: req.gettext('Please log in')
    , message: req.session.messages
  };
  res.render('login', data);
};

var loginPost = function(req, res, next) {
  console.log('loginPost');
  passport.authenticate('local', function(err, user, info) {
    if (err) {
      console.log('err: %s', err);
      return next(err);
    }
    if (!user) {
      if (req.session) {
        req.session.messages =  [info.message];
      }
      return res.redirect(loginRoute);
    }
    req.logIn(user, function(err) {
      if (err) { return next(err); }
      // --------------------------------------------------------
      // Store user information in the session sans sensitive info.
      // --------------------------------------------------------
      req.session.user = _.omit(user.toJSON(), 'password');;
      return res.redirect('/');
    });
  })(req, res, next);
};

var logout = function(req, res) {
  console.log('logout');
  req.session.destroy(function(err) {
    res.redirect(loginRoute);
  });
};



module.exports = {
  home: home
  , login: login
  , loginPost: loginPost
  , logout: logout
};


