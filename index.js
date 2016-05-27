/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Mercy - maternal care and patient management.
 * -------------------------------------------------------------------------------
 */

var express = require('express')
  , bodyParser = require('body-parser')
  , cookieParser = require('cookie-parser')
  , session = require('express-session')
  , errorHandler = require('errorhandler')
  , methodOverride = require('method-override')
  , favicon = require('serve-favicon')
  , csurf = require('csurf')
  , csrfProtection = csurf({cookie: true})
  , http = require('http')
  , https = require('https')
  , url = require('url')
  , device = require('express-device')
  , passport = require('passport')
  , LocalStrategy = require('passport-local').Strategy
  , cons = require('consolidate')
  , flash = require('express-flash')
  , app = express()
  , SocketIO = require('socket.io')
  , comm = require('./comm')
  , inRoles = require('./auth').inRoles
  , setRoleInfo = require('./auth').setRoleInfo(app)    // requires the app object
  , clearRoleInfo = require('./auth').clearRoleInfo(app)    // requires the app object
  , auth = require('./auth').auth
  , spaAuth = require('./auth').spaAuth
  , SessionStore = require('express-mysql-session')(session)
  , MySQL = require('mysql')                            // for conn pool for sessions
  , i18n = require('i18n-abide')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('./config')
  , path = require('path')
  , fs = require('fs')
  , User = require('./models').User
  , search = require('./routes').search
  , home = require('./routes').home
  , users = require('./routes').users
  , roles = require('./routes').roles
  , pregnancy = require('./routes').pregnancy
  , referral = require('./routes').referral
  , pregnote = require('./routes').pregnote
  , teaching = require('./routes').teaching
  , vaccination = require('./routes').vaccination
  , medication = require('./routes').medication
  , api = require('./routes/api')
  , apiSearch = require('./routes/api/search').search
  , getPregnancy = require('./routes/api/pregnancy').getPregnancy
  , apiCheckInOut = require('./routes/api/checkInOut').checkInOut
  , pregnancyHistory = require('./routes').pregnancyHistory
  , labs = require('./routes').labs
  , prenatalExam = require('./routes').prenatalExam
  , checkInOut = require('./routes').checkInOut
  , error = require('./routes').error
  , report = require('./routes').report
  , dewormingRpt = require('./routes').dewormingRpt
  , priorityList = require('./routes').priorityList
  , invWork = require('./routes').invWork
  , logInfo = require('./util').logInfo
  , logWarn = require('./util').logWarn
  , logError = require('./util').logError
  , common = []
  , spaCommon = []
  , attending = []
  , revision = 0
  , tmpRevision = 0
  , useSecureCookie = cfg.tls.key || false
  , server      // https server
  , workerPort = cfg.host.tlsPort
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
app.use(favicon(__dirname + '/static/favicon.ico'));
app.use(express.static('bower_components'));
app.use(express.static('static'));
app.use(bodyParser.json());
app.use(methodOverride());
app.use(cookieParser(cfg.cookie.secret));

cfg.session.pool = MySQL.createPool({
  user: cfg.database.dbUser
  , password: cfg.database.dbPass
  , host: cfg.database.host
  , port: cfg.database.port
  , database: cfg.database.db
  , schema: {
      tablename: 'session'
      , columnNames: {
          session_id: 'sid'
          , expires: 'expires'
          , data: 'session'
      }
    }
});
var sessionStore = new SessionStore(cfg.session.config);
// --------------------------------------------------------
// sessionMiddleware() allows the same authentication to
// be used in Express as in Socket.io.
// --------------------------------------------------------
var sessionMiddleware = session({
  secret: cfg.session.secret
  , cookie: {maxAge: cfg.cookie.maxAge, secure: useSecureCookie}
  , rolling: true   // Allows session to remain active as long as it is being used.
  , resave: true
  , saveUninitialized: false
  , store: sessionStore
});
app.use(sessionMiddleware);

app.use(bodyParser.urlencoded({extended: false}));
app.use(device.capture());
app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

// --------------------------------------------------------
// Deliver these JS libraries to the templating system.
// --------------------------------------------------------
app.locals.libs = {};
app.locals.libs.mmt = moment;   // Moment's global reference is deprecated.
app.locals.libs._ = _;          // Underscore

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

/* --------------------------------------------------------
 * hasSuper()
 *
 * Forces the user in the attending role to choose a supervisor
 * before continuing. Also populates the supervisor variable
 * for use in the templates.
 * -------------------------------------------------------- */
var hasSuper = function(req, res, next) {
  var superName
    ;
  if (req.session.roleInfo.roleName === 'attending') {
    if (req.session.supervisor) {
      // --------------------------------------------------------
      // Store the supervisor in app.locals for the templates.
      // Not all supervisors have their displayName field
      // populated so fall back to first and last if necessary.
      // --------------------------------------------------------
      superName = req.session.supervisor.displayName;
      if (! superName) {
        superName = req.session.supervisor.firstname + ' ' + req.session.supervisor.lastname;
      }
      app.locals.supervisor = superName;
      next();
    } else {
      res.redirect(cfg.path.setSuper);
    }
  } else {
    next();
  }
};

/* --------------------------------------------------------
 * logDevice()
 *
 * Logs the device the client is using to the console.
 * -------------------------------------------------------- */
var logDevice = function(req, res, next) {
  //console.dir(req.device);
  next();
};

/* --------------------------------------------------------
 * logRoute()
 *
 * Logs a bit about the route being accessed by the user.
 * This does not imply that the route has been approved yet.
 * -------------------------------------------------------- */
var logRoute = function(req, res, next) {
  var msg = ''
    ;
  if (req.session && req.session.user && req.session.user.username) {
    msg += req.session.user.username + ': ';
  }
  msg += '[' + req.method + '] ' + req.url;
  logInfo(msg);
  next();
};

/* --------------------------------------------------------
 * Records in the session the jumpTo URL per the value of
 * the jumpTo field passed in the request body. The value
 * of the field corresponds to a lookup in the configuration
 * to ascertain the proper URL for the key passed. The
 * pregnancy id is ascertained by checking the session for
 * the current pregnancy id and replaced if there is a
 * placeholder for it.
 * -------------------------------------------------------- */
app.use(function(req, res, next) {
  var url
    ;
  if (req.method === 'POST' &&
      req.body &&
      req.body.jumpTo) {
    if (_.has(cfg.jumpTo, req.body.jumpTo)) {
      url = cfg.jumpTo[req.body.jumpTo];
      if (req.session.currentPregnancyId && /:id/.test(url)) {
        url = url.replace(/:id/, req.session.currentPregnancyId);
      }
      req.session.jumpTo = url;
      logInfo(req.session.user.username + ': <JumpTo> ' + url);
    }
  }
  next();
});

/* --------------------------------------------------------
 * Make the current path available to the templates so that
 * it can be used to dynamically create an url for entering
 * history mode.
 * -------------------------------------------------------- */
app.use(function(req, res, next) {
  var currUrl
    ;
  if (req.method === 'GET' &&
      req.url.search(/^\/pregnancy\//) !== -1) {
    app.locals.currUrl = req.url;
  }
  next();
});

// --------------------------------------------------------
// Debugging, etc.
// --------------------------------------------------------
app.use(function(req, res, next) {
  if (cfg.site.debug) {
    console.log('============================');
    console.log(req.method + ': ' + req.url);
    console.log(req.headers);
    console.log('-----');
    console.log(req.body);
    console.log('============================');
    console.log('isAuthenticated(): ' + req.isAuthenticated());
    console.log('============================');
  }
  next();
});

// --------------------------------------------------------
// Protect against cross site request forgeries.
// --------------------------------------------------------
app.use(csrfProtection);
app.use(function(req, res, next) {
  app.locals.token = req.csrfToken();
  next();
});

// --------------------------------------------------------
// Make the application revision available to the templates.
// --------------------------------------------------------
if (fs.existsSync('./VERSION')) {
  tmpRevision = fs.readFileSync('./VERSION', {encoding: 'utf8'});
  tmpRevision = tmpRevision.trim();
  logInfo('Version: ' + tmpRevision);
  app.use(function(req, res, next) {
    app.locals.applicationRevision = tmpRevision? tmpRevision: '';
    next();
  });
} else {
  app.locals.applicationRevision = void(0);
}

// --------------------------------------------------------
// express-device functionality: render different views
// according to device type.
// --------------------------------------------------------
device.enableViewRouting(app);

// --------------------------------------------------------
// Development configuration
// --------------------------------------------------------
if (app.get('env') === 'development') {
  logInfo('DEVELOPMENT mode');
}

// --------------------------------------------------------
// Production configuration
// --------------------------------------------------------
if (app.get('env') === 'production') {
  logInfo('PRODUCTION mode');
}

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
common.push(logRoute, logDevice, auth, setRoleInfo, i18nLocals);

spaCommon.push(logRoute, logDevice, spaAuth, setRoleInfo, i18nLocals);

// --------------------------------------------------------
// Login and logout
// --------------------------------------------------------
app.get(cfg.path.login, logRoute, setRoleInfo, home.login);
app.post(cfg.path.login, logRoute, setRoleInfo, home.loginPost);
app.get(cfg.path.logout, logRoute, clearRoleInfo, home.logout);

// --------------------------------------------------------
// Home
// --------------------------------------------------------
app.get(cfg.path.home, common, hasSuper, api.doSpa, home.home);

// --------------------------------------------------------
// Search
// --------------------------------------------------------
app.get(cfg.path.search, common, hasSuper,
    inRoles(['clerk', 'supervisor', 'attending', 'guard']), search.view);
app.post(cfg.path.search, common, hasSuper,
    inRoles(['clerk', 'supervisor', 'attending', 'guard']), search.execute);

// --------------------------------------------------------
// Users
// --------------------------------------------------------
app.get(cfg.path.userList, common, inRoles(['administrator']), api.doSpa, users.list);
app.all(cfg.path.userLoad, users.load);  // parameter handling
app.get(cfg.path.userNewForm, common, inRoles(['administrator']), api.doSpa, users.addForm);
app.post(cfg.path.userCreate, common, inRoles(['administrator']), api.doSpa, users.create);
app.get(cfg.path.userEditForm, common, inRoles(['administrator']), api.doSpa, users.editForm);
app.post(cfg.path.userUpdate, common, inRoles(['administrator']), api.doSpa, users.update);

// --------------------------------------------------------
// Roles
// --------------------------------------------------------
app.get(cfg.path.roleList, common, inRoles(['administrator']), api.doSpa, roles.list);
app.all(cfg.path.roleLoad, roles.load);  // parameter handling
app.get(cfg.path.roleNewForm, common, inRoles(['administrator']), api.doSpa, roles.addForm);
app.post(cfg.path.roleCreate, common, inRoles(['administrator']), api.doSpa, roles.create);
app.get(cfg.path.roleEditForm, common, inRoles(['administrator']), api.doSpa, roles.editForm);
app.post(cfg.path.roleUpdate, common, inRoles(['administrator']), api.doSpa, roles.update);

// --------------------------------------------------------
// Role assignment to users
// --------------------------------------------------------
app.all(cfg.path.userLoad2, users.load);  // parameter handling

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
app.get(cfg.path.pregnancyNewCurrPatForm, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.generalAddForm);
app.post(cfg.path.pregnancyCreate, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.generalAddSave);
app.get(cfg.path.pregnancyEditForm, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.generalEditForm);
app.post(cfg.path.pregnancyUpdate, common, hasSuper,
    inRoles(['clerk','attending','supervisor']), pregnancy.generalEditSave);
app.post(cfg.path.pregnancyDelete, common, hasSuper,
    inRoles(['supervisor']), pregnancy.pregnancyDelete);

// Pregnancy Questionnaire
app.get(cfg.path.pregnancyQuesEdit, common, hasSuper,
    inRoles(['clerk', 'attending','supervisor']), pregnancy.questionaireForm);
app.post(cfg.path.pregnancyQuesUpdate, common, hasSuper,
    inRoles(['clerk', 'attending','supervisor']), pregnancy.questionaireSave);

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
    inRoles(['clerk', 'attending','supervisor']), pregnancy.prenatalSave);

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
app.get(cfg.path.pregnancyPrenatalExamLatest, common, hasSuper,
    inRoles(['attending','supervisor']), prenatalExam.prenatalExamLatest);

// Labs main page
app.get(cfg.path.pregnancyLabsEditForm, common, hasSuper,
    inRoles(['attending','supervisor', 'clerk']), pregnancy.labsForm);

// Lab Tests
app.post(cfg.path.labTestAddForm, common, hasSuper,
    inRoles(['attending', 'supervisor', 'clerk']), labs.labTestAddForm);
app.post(cfg.path.labTestAdd, common, hasSuper,
    inRoles(['attending', 'supervisor', 'clerk']), labs.labTestSave);
app.get(cfg.path.labTestEdit, common, hasSuper,
    inRoles(['attending', 'supervisor', 'clerk']), labs.labTestEditForm);
app.post(cfg.path.labTestEdit, common, hasSuper,
    inRoles(['attending', 'supervisor', 'clerk']), labs.labTestSave);
app.post(cfg.path.labTestDelete, common, hasSuper,
    inRoles(['attending', 'supervisor', 'clerk']), labs.labDelete);

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

// Progress Notes
app.get(cfg.path.pregnoteAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), pregnote.pregnoteAddForm);
app.post(cfg.path.pregnoteAdd, common, hasSuper,
    inRoles(['attending', 'supervisor']), pregnote.pregnoteSave);
app.get(cfg.path.pregnoteEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), pregnote.pregnoteEditForm);
app.post(cfg.path.pregnoteEdit, common, hasSuper,
    inRoles(['attending', 'supervisor']), pregnote.pregnoteSave);
app.post(cfg.path.pregnoteDelete, common, hasSuper,
    inRoles(['attending', 'supervisor']), pregnote.pregnoteDelete);

// Health Teachings
app.get(cfg.path.teachingAdd, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), teaching.teachingAddForm);
app.post(cfg.path.teachingAdd, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), teaching.teachingSave);
app.get(cfg.path.teachingEdit, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), teaching.teachingEditForm);
app.post(cfg.path.teachingEdit, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), teaching.teachingSave);
app.post(cfg.path.teachingDelete, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), teaching.teachingDelete);

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

// Checkin and checkout routes for the guard
app.get(cfg.path.checkInOut, common, inRoles(['guard']), checkInOut.checkInOut);
app.post(cfg.path.checkIn, common, inRoles(['guard']), checkInOut.checkInOutSave);
app.post(cfg.path.checkOut, common, inRoles(['guard']), checkInOut.checkInOutSave);
app.get(cfg.path.newCheckIn, common, inRoles(['guard']), checkInOut.checkInOut);
app.post(cfg.path.newCheckIn, common, inRoles(['guard']), checkInOut.checkInOutSave);
app.get(cfg.path.simpleCheckOut, common,
    inRoles(['guard', 'attending', 'clerk', 'supervisor']), checkInOut.simpleCheckOutForm);
app.post(cfg.path.simpleCheckOut, common,
    inRoles(['guard', 'attending', 'clerk', 'supervisor']), checkInOut.simpleCheckOut);

// Priority List
app.post(cfg.path.priorityListLoad, priorityList.load);  // parameter handling for AJAX save only
app.get(cfg.path.priorityList, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), priorityList.page);  // GET page
app.post(cfg.path.priorityList, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), priorityList.data);  // POST AJAX for data
app.post(cfg.path.priorityListSave, common, hasSuper,
    inRoles(['attending', 'clerk', 'supervisor']), priorityList.save);  // POST AJAX for save


// AJAX Calls.
app.post(cfg.path.requiredTetanus, common, hasSuper,
    inRoles(['attending', 'supervisor']), vaccination.requiredTetanusSave);

// Reports
app.get(cfg.path.reportForm, common, hasSuper,
    inRoles(['supervisor', 'clerk']), report.form);
app.post(cfg.path.reportRun, common, hasSuper,
    inRoles(['supervisor', 'clerk']), report.run);
app.get(cfg.path.reportSummary, common, hasSuper,
    inRoles(['supervisor', 'clerk', 'attending']), report.summary);

// Invoice Worksheet
app.get(cfg.path.invoiceWorksheet, common,
    inRoles(['supervisor', 'clerk', 'attending']), invWork.invoiceWorksheet);

// ========================================================
// ========================================================
// SPA related routes and data calls below.
// ========================================================
// ========================================================

// SPA pages: the initial full page load of a SPA portion of the app.
app.get(cfg.path.spaLoad, api.params);    // parameter handling
app.get(cfg.path.spa, common,
    inRoles(['administrator', 'supervisor', 'clerk', 'attending']), api.spa.main);

// History API
app.all(cfg.path.apiLoad, api.params);    // parameter handling
app.get(cfg.path.apiHistory, common,
    inRoles(['supervisor']), api.history.get);

// User/Role Management
app.all(cfg.path.apiUser, spaCommon, inRoles(['administrator']), api.userRoles.user);

// User Profile
app.all(cfg.path.apiProfile, spaCommon,
    inRoles(['administrator', 'clerk', 'guard', 'supervisor', 'attending']),
    api.userRoles.profile);
app.all(cfg.path.apiProfilePassword, spaCommon,
    inRoles(['administrator', 'clerk', 'guard', 'supervisor', 'attending']),
    api.userRoles.profile);

// Searches
app.get(cfg.path.apiSearch, spaCommon,
    inRoles(['clerk', 'guard', 'supervisor', 'attending']), apiSearch);

// Pregnancy
app.get(cfg.path.apiPregnancy, spaCommon,
    inRoles(['clerk', 'guard', 'supervisor', 'attending']), getPregnancy);

// Checkin and Checkout
app.post(cfg.path.apiCheckInOut, spaCommon,
    inRoles(['clerk', 'guard', 'supervisor', 'attending']), apiCheckInOut);

// --------------------------------------------------------
// Error handling.
// --------------------------------------------------------
app.use(error.notFoundApiError);
app.use(error.notFoundError);
app.use(error.logException);
app.use(error.displayError);
app.use(error.exitError);
if (app.get('env') === 'development') {
  app.use(errorHandler());
}

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
  app.listen(cfg.host.port, cfg.host.name);
} else {
  // --------------------------------------------------------
  // Determine which port this instance will listen on. In a
  // cluster of workers, due to the need to use sticky sessions
  // for the sake of Socket.io, we have the workers listen on
  // separate ports if there are more than one worker. See
  // http://socket.io/docs/using-multiple-nodes/ for details.
  //
  // Note that if cfg.cpu.workers is greater than 1, then a
  // reverse proxy like Nginx must be configured that implements
  // sticky sessions or else only one worker will be used.
  // --------------------------------------------------------
  if (process.env.WORKER_ID) {
    if (cfg.tls.key) {
      workerPort = Number(cfg.host.tlsPort) + Number(process.env.WORKER_ID);
    } else {
      workerPort = Number(cfg.host.port) + Number(process.env.WORKER_ID);
    }
  }
  if (cfg.tls.key) {
    // --------------------------------------------------------
    // Listen for HTTPS connections.
    // --------------------------------------------------------
    server = https.createServer(cfg.tls, app);
    server.listen(workerPort, cfg.host.name);

    // --------------------------------------------------------
    // Catch all incoming HTTP connections and redirect to HTTPS.
    // We don't redirect to the workerPort because if we are
    // running more than one worker in a cluster, the reverse
    // proxy should be implementing some form of sticky connections
    // which should choose the correct worker port, if the
    // remoteAddress has already been assigned to one.
    // --------------------------------------------------------
    http.createServer(function(req, res) {
      var httpsLoc = url.format({
            protocol: 'https', hostname: cfg.host.name, port: cfg.host.tlsPort
          })
        ;
      res.setHeader('Location', httpsLoc);
      res.statusCode = 302;
      res.end('Redirecting to ' + httpsLoc);
    }).listen(cfg.host.port, cfg.host.name);

  } else {
    // --------------------------------------------------------
    // HTTP only. This should not be used for production.
    // --------------------------------------------------------
    server = http.createServer(app);
    server.listen(workerPort, cfg.host.name);
  }

  // ========================================================
  // ========================================================
  // Initialize the communication module for this worker.
  // ========================================================
  // ========================================================
  comm.init(SocketIO(server), sessionMiddleware);
}


if (cfg.tls.key) {
  logInfo('Server listening for HTTPS on port ' + workerPort +
      ' and redirecting port ' + cfg.host.port);
} else {
  logInfo('Server listening in INSECURE mode on port ' + workerPort);
}

// --------------------------------------------------------
// Exports app for the sake of testing.
// --------------------------------------------------------
module.exports = app;

