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
  , flash = require('express-flash')
  , app = express()
  , inRoles = require('auth').inRoles
  , setRoleInfo = require('auth').setRoleInfo(app)    // requires the app object
  , auth = require('auth').auth
  , SessionStore = require('connect-mysql')(express)
  , i18n = require('i18n-abide')
  , _ = require('underscore')
  , cfg = require('./config')
  , path = require('path')
  , User = require('./models').User
  , search = require('./routes').search
  , home = require('./routes').home
  , users = require('./routes').users
  , roles = require('./routes').roles
  , pregnancy = require('./routes').pregnancy
  , error = require('./routes').error
  , common = []
  , student = []
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
      if (!user) { return done(null, false, { message: 'Unknown user ' + username }); }
      if (user.get('status') != 1) {
        return done(null, false, {
          message: username + ' is not an active account.'
        });
      }
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
app.use(flash());

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

var hasSuper = function(req, res, next) {
  if (_.contains(req.session.roleInfo.roleNames, 'student')) {
    if (req.session.supervisor) {
      // --------------------------------------------------------
      // Store the supervisor in app.locals for the templates.
      // --------------------------------------------------------
      app.locals.supervisor = req.session.supervisor.lastname + ', ' +
        req.session.supervisor.firstname;
      next();
    } else {
      res.redirect(cfg.path.setSuper);
    }
  } else {
    next();
  }
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
// Error handling.
// TODO: should these be located here or below the routes?
// --------------------------------------------------------
app.use(error.notFoundError);
app.use(error.logError);
app.use(error.displayError);
//app.use(error.exitError);


// --------------------------------------------------------
// Development configuration
// --------------------------------------------------------
app.configure('development', function() {
  console.log('DEVELOPMENT mode');
  app.use(express.logger('dev'));
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
//
// Note that the auth method placed before the inRoles()
// authentication requirements in many of the routes allows
// the request to get redirected to the login page rather
// than just being denied if the user is not yet logged in.
// ========================================================
// ========================================================

// --------------------------------------------------------
// Group of methods that are commonly needed for
// many requests.
// common: populates the request with info for protected routes.
// student: routes a student can use without a supervisor set.
// --------------------------------------------------------
common.push(auth, setRoleInfo, i18nLocals);

// --------------------------------------------------------
// Login and logout
// --------------------------------------------------------
app.get(cfg.path.login, setRoleInfo, csrf, home.login);
app.post(cfg.path.login, setRoleInfo, csrf, home.loginPost);
app.get(cfg.path.logout, setRoleInfo, csrf, home.logout);

// --------------------------------------------------------
// Home
// --------------------------------------------------------
app.get(cfg.path.home, common, hasSuper, home.home);

// --------------------------------------------------------
// Search
// --------------------------------------------------------
app.get(cfg.path.search, common, hasSuper, csrf, search.view);
app.post(cfg.path.search, common, hasSuper, csrf, search.execute);

// --------------------------------------------------------
// Users
// --------------------------------------------------------
app.get(cfg.path.userList, common, inRoles(['administrator']), users.list);
app.all(cfg.path.userLoad, users.load);  // parameter handling
app.get(cfg.path.userNewForm, common, inRoles(['administrator']), csrf, users.addForm);
app.post(cfg.path.userCreate, common, inRoles(['administrator']), csrf, users.create);
app.get(cfg.path.userEditForm, common, inRoles(['administrator']), csrf, users.editForm);
app.post(cfg.path.userUpdate, common, inRoles(['administrator']), csrf, users.update);

// --------------------------------------------------------
// Roles
// --------------------------------------------------------
app.get(cfg.path.roleList, common, inRoles(['administrator']), roles.list);
app.all(cfg.path.roleLoad, roles.load);  // parameter handling
app.get(cfg.path.roleNewForm, common, inRoles(['administrator']), csrf, roles.addForm);
app.post(cfg.path.roleCreate, common, inRoles(['administrator']), csrf, roles.create);
app.get(cfg.path.roleEditForm, common, inRoles(['administrator']), csrf, roles.editForm);
app.post(cfg.path.roleUpdate, common, inRoles(['administrator']), csrf, roles.update);

// --------------------------------------------------------
// Role assignment to users
// --------------------------------------------------------
app.all(cfg.path.userLoad2, users.load);  // parameter handling
app.post(cfg.path.changeRoles, common, inRoles(['administrator']), csrf, users.changeRoles);

// --------------------------------------------------------
// Profile
// --------------------------------------------------------
app.get(cfg.path.profile, auth, csrf, users.editProfile);
app.post(cfg.path.profile, auth, csrf, users.saveProfile);

// --------------------------------------------------------
// Set the supervisor if a student.
// --------------------------------------------------------
app.get(cfg.path.setSuper, common, inRoles(['student']), csrf, users.editSupervisor);
app.post(cfg.path.setSuper, common, inRoles(['student']), csrf, users.saveSupervisor);

// --------------------------------------------------------
// Pregnancy management
// --------------------------------------------------------
app.all(cfg.path.pregnancyLoad, pregnancy.load);  // parameter handling
app.get(cfg.path.pregnancyNewForm, common, hasSuper,
    inRoles(['clerk','student','supervisor']),
    csrf, pregnancy.addForm);
app.post(cfg.path.pregnancyCreate, common, hasSuper,
    inRoles(['clerk','student','supervisor']),
    csrf, pregnancy.create);
app.get(cfg.path.pregnancyEditForm, common, hasSuper,
    inRoles(['clerk','student','supervisor']),
    csrf, pregnancy.editForm);
app.post(cfg.path.pregnancyUpdate, common, hasSuper,
    inRoles(['clerk','student','supervisor']),
    csrf, pregnancy.update);



// --------------------------------------------------------
// Start the server.
// --------------------------------------------------------
if (process.env.NODE_ENV == 'test') {
  console.log('TEST mode');
  app.listen(cfg.host.port);
} else {
  app.listen(cfg.host.port);
}
console.log('Server listening on port ' + cfg.host.port);

// --------------------------------------------------------
// Exports app for the sake of testing.
// --------------------------------------------------------
module.exports = app;

