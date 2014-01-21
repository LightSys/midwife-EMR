/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Mercy - maternal care and patient management.
 * -------------------------------------------------------------------------------
 */

var express = require('express')
  , passport = require('passport')
  , LocalStrategy = require('passport-local').Strategy
  , cons = require('consolidate')
  , app = express()
  , SessionStore = require('connect-mysql')(express)
  , i18n = require('i18n-abide')
  , _ = require('underscore')
  , cfg = require('./config')
  , path = require('path')
  , User = require('./models').User
  , search = require('./routes').search
  , home = require('./routes').home
  , users = require('./routes').users
  , common = []
  ;

// --------------------------------------------------------
// These next three calls are per the example application at:
// https://github.com/jaredhanson/passport-local/blob/master/examples/express3-no-connect-flash/app.js
// --------------------------------------------------------
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function (err, user) {
    done(err, user);
  });
});

passport.use(new LocalStrategy(
  function(username, password, done) {
    //Find the user by username.  If there is no user with the given
    //username, or the password is not correct, set the user to `false` to
    //indicate failure and set a flash message.  Otherwise, return the
    //authenticated `user`.
    User.findByUsername(username, function(err, user) {
      if (err) { return done(err); }
      if (!user) { return done(null, false, { message: 'Unknown user ' + username }); }
      user.checkPassword(password, function(err, same) {
        if (err) return done(err);
        if (same) {
          return done(null, user);
        } else {
          return done(null, false, {message: 'Invalid password'});
        }
      });
    });
  }
));

// --------------------------------------------------------
// All configurations.
// --------------------------------------------------------
app.engine('jade', cons.jade);
app.set('view engine', 'jade');
app.set('views', path.join(__dirname,'views'));
app.use(express.static('bower_components'));
app.use(express.static('static'));
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(express.cookieParser(cfg.cookie.secret));
app.use(express.session({
  secret: cfg.session.secret
  , cookie: {maxAge: cfg.cookie.maxAge}
  , store: new SessionStore(cfg.session)
}));
app.use(express.bodyParser());
app.use(passport.initialize());
app.use(passport.session());

// --------------------------------------------------------
// Localization.
// --------------------------------------------------------
app.use(i18n.abide({
  supported_languages: ['en-US', 'it-CH']
  , default_lang: 'en-US'
  , debug_lang: 'it-CH'
  , translation_directory: 'static/i18n'
}));

// --------------------------------------------------------
// This is a hack because i18n-abide does not work natively
// outside the context of a request. Therefore, we force
// it into the context of a request in order to localize
// all of the site wide variables for our templates. See
// config.js in the site section.
//
// Note: any additions to cfg.site in config.js need to be
// added to this function.
// --------------------------------------------------------
var i18nLocals = function(req, res, next) {
  app.locals.siteTitle = req.gettext(cfg.site.title);
  next();
};

// --------------------------------------------------------
// Protect against cross site request forgeries.
// See: http://dailyjs.com/2012/09/13/express-3-csrf-tutorial/
// --------------------------------------------------------
app.use(express.csrf());
function csrf(req, res, next) {
  res.locals.token = req.csrfToken();
  next();
}

app.use(app.router);

// --------------------------------------------------------
// Development configuration
// --------------------------------------------------------
app.configure('development', function() {
  console.log('DEVELOPMENT mode');
  app.use(express.errorHandler());
});

// --------------------------------------------------------
// Production configuration
// --------------------------------------------------------
app.configure('production', function() {
  console.log('PRODUCTION mode');
});

// ========================================================
// ========================================================
// Routes
// ========================================================
// ========================================================

// --------------------------------------------------------
// Group of methods that are commonly needed for 
// many requests.
// --------------------------------------------------------
common.push(auth, i18nLocals);

// --------------------------------------------------------
// Login and logout
// --------------------------------------------------------
app.get(cfg.path.login, csrf, home.login);
app.post(cfg.path.login, home.loginPost);
app.get(cfg.path.logout, common, home.logout);

// --------------------------------------------------------
// Home
// --------------------------------------------------------
app.get(cfg.path.home, common, home.home);

// --------------------------------------------------------
// Search
// --------------------------------------------------------
app.get(cfg.path.search, common, csrf, search.view);
app.post(cfg.path.search, common, csrf, search.execute);

// --------------------------------------------------------
// Users
// --------------------------------------------------------
app.get(cfg.path.userList, common, users.list);
app.all(cfg.path.userLoad, users.load);  // parameter handling
app.get(cfg.path.userNewForm, common, csrf, users.addForm);
app.post(cfg.path.userCreate, common, csrf, users.create);
app.get(cfg.path.userEditForm, common, csrf, users.editForm);
app.post(cfg.path.userUpdate, common, csrf, users.update);

// --------------------------------------------------------
// Start the server.
// --------------------------------------------------------
app.listen(cfg.host.port);
console.log('Server listening on port ' + cfg.host.port);

/* --------------------------------------------------------
 * auth()
 *
 * param       req
 * param       res
 * param       next
 * return      undefined
 * -------------------------------------------------------- */
function auth(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  console.log('Redirecting to login');
  res.redirect(cfg.path.login);
}

