/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Mercy - maternal care and patient management.
 * -------------------------------------------------------------------------------
 */

var express = require('express')
  , device = require('express-device')
  , passport = require('passport')
  , LocalStrategy = require('passport-local').Strategy
  , cons = require('consolidate')
  , flash = require('express-flash')
  , app = express()
  , inRoles = require('./auth').inRoles
  , setRoleInfo = require('./auth').setRoleInfo(app)    // requires the app object
  , auth = require('./auth').auth
  , SessionStore = require('connect-mysql')(express)
  , i18n = require('i18n-abide')
  , _ = require('underscore')
  , moment = require('moment')
  , gitHistory = require('git-history')
  , cfg = require('./config')
  , path = require('path')
  , User = require('./models').User
  , search = require('./routes').search
  , home = require('./routes').home
  , users = require('./routes').users
  , roles = require('./routes').roles
  , pregnancy = require('./routes').pregnancy
  , referral = require('./routes').referral
  , labs = require('./routes').labs
  , error = require('./routes').error
  , logInfo = require('./util').logInfo
  , logWarn = require('./util').logWarn
  , logError = require('./util').logError
  , common = []
  , attending = []
  , revision = 0
  , tmpRevision = 0
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
app.use(device.capture());
app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

// --------------------------------------------------------
// Deliver these JS libraries to the templating system.
// --------------------------------------------------------
app.locals({
  libs: {
    mmt: moment     // Moment's global reference is deprecated.
    , _: _          // Underscore
  }
});

// --------------------------------------------------------
// Localization.
// --------------------------------------------------------
app.use(function(req, res, next) {
  if (req.session && req.session.user) {
    var lang = req.session.user.lang || cfg.site.defaultLanguage;
    req.headers['accept-language'] = lang;
  }
  next();
});

app.use(i18n.abide({
  supported_languages: cfg.site.languages
  , default_lang: cfg.site.defaultLanguage
  , debug_lang: cfg.site.debugLanguage
  , translation_directory: 'i18n'
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
  if (_.contains(req.session.roleInfo.roleNames, 'attending')) {
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

var logDevice = function(req, res, next) {
  //console.dir(req.device);
  next();
};

// --------------------------------------------------------
// Protect against cross site request forgeries.
// --------------------------------------------------------
app.use(express.csrf());
app.use(function(req, res, next) {
  app.locals.token = req.csrfToken();
  next();
});

// --------------------------------------------------------
// Get the git revision as the number of commits then save 
// to app locals for use in the templates.
// --------------------------------------------------------
gitHistory().on('data', function(commit) {
  tmpRevision++;
});
gitHistory().on('end', function() {
  revision = tmpRevision;
});
app.use(function(req, res, next) {
  if (revision != 0) app.locals.applicationRevision = revision;
  next();
});

// --------------------------------------------------------
// express-device functionality: render different views
// according to device type.
// --------------------------------------------------------
app.enableViewRouting();

app.use(app.router);

// --------------------------------------------------------
// Error handling.
// TODO: should these be located here or below the routes?
// --------------------------------------------------------
app.use(error.notFoundError);
app.use(error.logException);
app.use(error.displayError);
app.use(error.exitError);

// --------------------------------------------------------
// Development configuration
// --------------------------------------------------------
app.configure('development', function() {
  logInfo('DEVELOPMENT mode');
  app.use(express.logger('dev'));
  app.use(express.errorHandler());
});
// --------------------------------------------------------
// Production configuration
// --------------------------------------------------------
app.configure('production', function() {
  logInfo('PRODUCTION mode');
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
// attending: routes a attending can use without a supervisor set.
// --------------------------------------------------------
common.push(logDevice, auth, setRoleInfo, i18nLocals);

// --------------------------------------------------------
// Login and logout
// --------------------------------------------------------
app.get(cfg.path.login, setRoleInfo, home.login);
app.post(cfg.path.login, setRoleInfo, home.loginPost);
app.get(cfg.path.logout, setRoleInfo, home.logout);

// --------------------------------------------------------
// Home
// --------------------------------------------------------
app.get(cfg.path.home, common, hasSuper, home.home);

// --------------------------------------------------------
// Search
// --------------------------------------------------------
app.get(cfg.path.search, common, hasSuper, search.view);
app.post(cfg.path.search, common, hasSuper, search.execute);

// --------------------------------------------------------
// Users
// --------------------------------------------------------
app.get(cfg.path.userList, common, inRoles(['administrator']), users.list);
app.all(cfg.path.userLoad, users.load);  // parameter handling
app.get(cfg.path.userNewForm, common, inRoles(['administrator']), users.addForm);
app.post(cfg.path.userCreate, common, inRoles(['administrator']), users.create);
app.get(cfg.path.userEditForm, common, inRoles(['administrator']), users.editForm);
app.post(cfg.path.userUpdate, common, inRoles(['administrator']), users.update);

// --------------------------------------------------------
// Roles
// --------------------------------------------------------
app.get(cfg.path.roleList, common, inRoles(['administrator']), roles.list);
app.all(cfg.path.roleLoad, roles.load);  // parameter handling
app.get(cfg.path.roleNewForm, common, inRoles(['administrator']), roles.addForm);
app.post(cfg.path.roleCreate, common, inRoles(['administrator']), roles.create);
app.get(cfg.path.roleEditForm, common, inRoles(['administrator']), roles.editForm);
app.post(cfg.path.roleUpdate, common, inRoles(['administrator']), roles.update);

// --------------------------------------------------------
// Role assignment to users
// --------------------------------------------------------
app.all(cfg.path.userLoad2, users.load);  // parameter handling
app.post(cfg.path.changeRoles, common, inRoles(['administrator']), users.changeRoles);

// --------------------------------------------------------
// Profile
// --------------------------------------------------------
app.get(cfg.path.profile, common, users.editProfile);
app.post(cfg.path.profile, common, users.saveProfile);

// --------------------------------------------------------
// Set the supervisor if a attending.
// --------------------------------------------------------
app.get(cfg.path.setSuper, common, inRoles(['attending']), users.editSupervisor);
app.post(cfg.path.setSuper, common, inRoles(['attending']), users.saveSupervisor);

// --------------------------------------------------------
// Pregnancy management
// --------------------------------------------------------
app.all(cfg.path.pregnancyLoad, pregnancy.load);  // parameter handling
app.get(cfg.path.pregnancyNewForm, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.addForm);
app.post(cfg.path.pregnancyCreate, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.create);
app.get(cfg.path.pregnancyEditForm, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.editForm);
app.post(cfg.path.pregnancyUpdate, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.update);
app.get(cfg.path.pregnancyHistory, common,
    inRoles(['supervisor']), pregnancy.history);

// Pregnancy Questionnaire
app.get(cfg.path.pregnancyQuesEdit, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.quesEdit);
app.post(cfg.path.pregnancyQuesUpdate, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.quesUpdate);

// Pregnancy midwife interview
app.get(cfg.path.pregnancyMidwifeEdit, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.midwifeEdit);
app.post(cfg.path.pregnancyMidwifeUpdate, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.midwifeUpdate);
app.get(cfg.path.pregnancyHistoryAddForm, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.pregnancyHistoryAddForm);
app.post(cfg.path.pregnancyHistoryAdd, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.pregnancyHistoryAdd);
app.get(cfg.path.pregnancyHistoryEditForm, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.pregnancyHistoryEditForm);
app.post(cfg.path.pregnancyHistoryEdit, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.pregnancyHistoryEdit);
app.post(cfg.path.pregnancyHistoryDelete, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.pregnancyHistoryDelete);

// Prenatal
app.get(cfg.path.pregnancyPrenatalEdit, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.prenatalEdit);
app.post(cfg.path.pregnancyPrenatalUpdate, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.prenatalUpdate);
app.get(cfg.path.pregnancyPrenatalExamAddForm, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.prenatalExamAddForm);
app.post(cfg.path.pregnancyPrenatalExamAdd, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.prenatalExamAdd);
app.get(cfg.path.pregnancyPrenatalExamEditForm, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.prenatalExamEditForm);
app.post(cfg.path.pregnancyPrenatalExamEdit, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.prenatalExamEdit);
app.post(cfg.path.pregnancyPrenatalExamDelete, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.prenatalExamDelete);

// Labs main page
app.get(cfg.path.pregnancyLabsEditForm, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.labsEdit);

// Lab Tests
app.post(cfg.path.labTestAddForm, common, hasSuper,
    inRoles(['attending', 'supervisor']), labs.labTestAddForm);
app.post(cfg.path.labTestAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), labs.labTestSave);
app.get(cfg.path.labTestEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), labs.labTestEditForm);
app.post(cfg.path.labTestEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), labs.labTestSave);
app.post(cfg.path.labTestDelete, common, hasSuper,
    inRoles(['attending', 'supervisor']), labs.labDelete);

// Referrals
app.get(cfg.path.referralAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), referral.referralAddForm);
app.post(cfg.path.referralAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), referral.referralSave);
app.get(cfg.path.referralEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), referral.referralEditForm);
app.post(cfg.path.referralEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), referral.referralSave);
app.post(cfg.path.referralDelete, common, hasSuper,
    inRoles(['attending', 'supervisor']), referral.referralDelete);


// --------------------------------------------------------
// The last resort.
// --------------------------------------------------------
process.on('uncaughtException', function(err) {
  logError('uncaughtException: ', err.message);
  logError(err.stack);
  process.exit(1);
});


// --------------------------------------------------------
// Start the server.
// --------------------------------------------------------
if (process.env.NODE_ENV == 'test') {
  logInfo('TEST mode');
  app.listen(cfg.host.port);
} else {
  app.listen(cfg.host.port);
}
logInfo('Server listening on port ' + cfg.host.port);

// --------------------------------------------------------
// Exports app for the sake of testing.
// --------------------------------------------------------
module.exports = app;

