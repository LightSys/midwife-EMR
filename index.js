/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Mercy - maternal care and patient management.
 * -------------------------------------------------------------------------------
 */

var express = require('express')
  , http = require('http')
  , https = require('https')
  , url = require('url')
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
  , vaccination = require('./routes').vaccination
  , medication = require('./routes').medication
  , pregnancyHistory = require('./routes').pregnancyHistory
  , labs = require('./routes').labs
  , prenatalExam = require('./routes').prenatalExam
  , error = require('./routes').error
  , report = require('./routes').report
  , dewormingRpt = require('./routes').dewormingRpt
  , logInfo = require('./util').logInfo
  , logWarn = require('./util').logWarn
  , logError = require('./util').logError
  , common = []
  , attending = []
  , revision = 0
  , tmpRevision = 0
  , useSecureCookie = cfg.tls.key || false;
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
  , cookie: {maxAge: cfg.cookie.maxAge, secure: useSecureCookie}
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
    inRoles(['clerk','attending','supervisor']), pregnancy.generalAddForm);
app.post(cfg.path.pregnancyCreate, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.generalAddSave);
app.get(cfg.path.pregnancyEditForm, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.generalEditForm);
app.post(cfg.path.pregnancyUpdate, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.generalEditSave);
app.get(cfg.path.pregnancyHistory, common,
    inRoles(['supervisor']), pregnancy.history);

// Pregnancy Questionnaire
app.get(cfg.path.pregnancyQuesEdit, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.questionaireForm);
app.post(cfg.path.pregnancyQuesUpdate, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.questionaireSave);

// Pregnancy midwife interview
app.get(cfg.path.pregnancyMidwifeEdit, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.midwifeForm);
app.post(cfg.path.pregnancyMidwifeUpdate, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.midwifeSave);

// Pregnancy History
app.get(cfg.path.pregnancyHistoryAdd, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancyHistory.pregnancyHistoryAddForm);
app.post(cfg.path.pregnancyHistoryAdd, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancyHistory.pregnancyHistorySave);
app.get(cfg.path.pregnancyHistoryEdit, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancyHistory.pregnancyHistoryEditForm);
app.post(cfg.path.pregnancyHistoryEdit, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancyHistory.pregnancyHistorySave);
app.post(cfg.path.pregnancyHistoryDelete, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancyHistory.pregnancyHistoryDelete);

// Prenatal
app.get(cfg.path.pregnancyPrenatalEdit, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.prenatalForm);
app.post(cfg.path.pregnancyPrenatalUpdate, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.prenatalSave);

// Prenatal Exams
app.get(cfg.path.pregnancyPrenatalExamAdd, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), prenatalExam.prenatalExamAddForm);
app.post(cfg.path.pregnancyPrenatalExamAdd, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), prenatalExam.prenatalExamSave);
app.get(cfg.path.pregnancyPrenatalExamEdit, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), prenatalExam.prenatalExamEditForm);
app.post(cfg.path.pregnancyPrenatalExamEdit, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), prenatalExam.prenatalExamSave);
app.post(cfg.path.pregnancyPrenatalExamDelete, common, hasSuper,
    inRoles(['attending','supervisor']), prenatalExam.prenatalExamDelete);

// Labs main page
app.get(cfg.path.pregnancyLabsEditForm, common, hasSuper,
    inRoles(['attending','supervisor']), pregnancy.labsForm);

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

// Doctor and dentist consult dates
app.post(cfg.path.docDenConsult, common, hasSuper,
    inRoles(['attending', 'supervisor']), pregnancy.doctorDentistSave);

// Vaccinations
app.get(cfg.path.vaccinationAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), vaccination.vaccinationAddForm);
app.post(cfg.path.vaccinationAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), vaccination.vaccinationSave);
app.get(cfg.path.vaccinationEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), vaccination.vaccinationEditForm);
app.post(cfg.path.vaccinationEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), vaccination.vaccinationSave);
app.post(cfg.path.vaccinationDelete, common, hasSuper,
    inRoles(['attending', 'supervisor']), vaccination.vaccinationDelete);

// Medications and vitamins
app.get(cfg.path.medicationAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), medication.medicationAddForm);
app.post(cfg.path.medicationAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), medication.medicationSave);
app.get(cfg.path.medicationEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), medication.medicationEditForm);
app.post(cfg.path.medicationEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), medication.medicationSave);
app.post(cfg.path.medicationDelete, common, hasSuper,
    inRoles(['attending', 'supervisor']), medication.medicationDelete);



// AJAX Calls.
app.post(cfg.path.requiredTetanus, common, hasSuper,
    inRoles(['attending', 'supervisor']), vaccination.requiredTetanusSave);

// Reports
app.get(cfg.path.reportForm, common, hasSuper,
    inRoles(['supervisor', 'clerk']), report.form);
app.post(cfg.path.reportRun, common, hasSuper,
    inRoles(['supervisor', 'clerk']), report.run);

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
  if (cfg.tls.key) {
    // --------------------------------------------------------
    // Listen for HTTPS connections.
    // --------------------------------------------------------
    https.createServer(cfg.tls, app).listen(cfg.host.tlsPort);

    // --------------------------------------------------------
    // Catch all incoming HTTP connections and redirect to HTTPS.
    // --------------------------------------------------------
    http.createServer(function(req, res) {
      var httpsLoc = url.format({
            protocol: 'https', hostname: cfg.host.name, port: cfg.host.tlsPort
          })
        ;
      res.setHeader('Location', httpsLoc);
      res.statusCode = 302;
      res.end('Redirecting to ' + httpsLoc);
    }).listen(cfg.host.port);

  } else {
    // --------------------------------------------------------
    // HTTP only. This should not be used for production.
    // --------------------------------------------------------
    http.createServer(app).listen(cfg.host.port);
  }
}
if (cfg.tls.key) {
  logInfo('Server listening for HTTPS on port ' + cfg.host.tlsPort +
      ' and redirecting port ' + cfg.host.port);
} else {
  logInfo('Server listening in INSECURE mode on port ' + cfg.host.port);
}

// --------------------------------------------------------
// Exports app for the sake of testing.
// --------------------------------------------------------
module.exports = app;

