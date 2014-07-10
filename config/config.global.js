/*
 * -------------------------------------------------------------------------------
 * config.js
 *
 * Global configuration which is meant to be loaded first and then overridden as
 * appropriate by the environment specific configuration files.
 *
 * Note: always create the required elements in the cfg object in this file, e.g.
 *
 *    cfg.database = {};
 *    cfg.path = {};
 *
 * then establish default values that are overridden depending upon the environment.
 * -------------------------------------------------------------------------------
 */

var fs = require('fs')
  , _ = require('underscore')
  ;

var cfg = {}
    // Allows i18n-abide's extract-pot script to pick up these
    // variables and put them into the pot file.
  , gettext = function(param) {return param;}
  ;

// --------------------------------------------------------
// Site settings.
//
// Note: any attribute that needs localization with the
// templates needs to be added to the i18nLocals() function
// in index.js.
//
// Note: tmpDir is assumed to be secure and site installations
// should insure that this is the case.
// --------------------------------------------------------
cfg.site = {};
cfg.site.title = gettext('Your Site Name');
cfg.site.languagesMap = {'en-US': 'English - Unites States', 'it-CH': 'Debugging language'};
cfg.site.languages = _.keys(cfg.site.languagesMap);
cfg.site.defaultLanguage = 'en-US';
cfg.site.debugLanguage = 'it-CH';
cfg.site.tmpDir = 'tmp';

// --------------------------------------------------------
// Search settings.
// --------------------------------------------------------
cfg.search = {};
cfg.search.rowsPerPage = 3;

// --------------------------------------------------------
// Host settings.
// --------------------------------------------------------
cfg.host = {};
cfg.host.name = 'localhost';    // must be set for TLS use.
cfg.host.port = 4000
cfg.host.tlsPort = 443;

// --------------------------------------------------------
// TLS settings.
// Note that this section follows the Node API here.
// http://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener
// --------------------------------------------------------
cfg.tls = {};
cfg.tls.key = false;          // set to false to disable TLS
cfg.tls.cert = false;
cfg.tls.passphrase = false;
cfg.tls.ciphers = 'AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH';
cfg.tls.handshakeTimeout = 120;
cfg.tls.honorCipherOrder = true;

// --------------------------------------------------------
// Database settings.
// --------------------------------------------------------
cfg.database = {};
cfg.database.host = 'localhost';
cfg.database.port = 3306;
cfg.database.db = 'yourDBname';
cfg.database.dbUser = 'yourDBuser';
cfg.database.dbPass = 'yourDBpassword';
cfg.database.charset = 'utf8';

// --------------------------------------------------------
// Cache settings.
// --------------------------------------------------------
cfg.cache = {};
cfg.cache.userTTL = 600;   // TTL is in seconds

// --------------------------------------------------------
// Data settings.
// --------------------------------------------------------
cfg.data = {};
cfg.data.selectRefreshInterval = 10 * 60 * 1000;

// --------------------------------------------------------
// Error settings.
// --------------------------------------------------------
cfg.error = {};
// Time to wait after fatal error before killing process to
// allow rendering of the error page to the client.
cfg.error.errorTimeout = 1500;

// --------------------------------------------------------
// Session settings.
// --------------------------------------------------------
cfg.session = {};
cfg.session.secret = 'yourSESSIONsecret';
cfg.session.pool = true;
cfg.session.table = 'session';
cfg.session.cleanup = true;
cfg.session.config = {
  user: cfg.database.dbUser
  , password: cfg.database.dbPass
  , database: cfg.database.db
};

// --------------------------------------------------------
// Cookie settings.
// --------------------------------------------------------
cfg.cookie = {};
cfg.cookie.secret = 'yourCOOKIEsecret';
cfg.cookie.maxAge = 60 * 60 * 24 * 1000;    // 1 day

// --------------------------------------------------------
// Path settings.
// Using our own near-REST adaptation based upon
// http://microformats.org/wiki/rest/urls
//
// Res = resource, e.g. user or patient
// Rel = related to resource, e.g. roles or labs
// :id = the resource id, e.g. user 4
// :rid = the related to resource id, e.g. role 12
// special = some custom action
//
// Description             Path                     Method
// ------------------------------------------------ ------
// List                    /Res                     GET
// Form to create new      /Res/new                 GET
// Create new record       /Res                     POST
// Read/show a record      /Res/:id                 GET
// Form to edit record     /Res/:id/edit            GET
// Update record           /Res/:id/update          POST
// Delete a record         /Res/:id/delete          POST
// List related to record  /Res/:id/Rel             GET
// Form to create relation /Res/:id/Rel/new         GET
// Create new relation     /Res/:id/Rel             POST
// Read/show relation      /Res/:id/Rel/:rid        GET
// Form to edit relation   /Res/:id/Rel/:rid/edit   GET
// Update relation         /Res/:id/Rel/:rid/update POST
// Delete relation         /Res/:id/Rel/:rid/delete POST
// Custom action for Res   /Res/:id/special         POST
//
// --------------------------------------------------------
cfg.path = {};
cfg.path.home = '/';
cfg.path.login = '/login';
cfg.path.logout = '/logout';
cfg.path.search = '/search';

cfg.path.userList = '/user';
cfg.path.userNewForm = '/user/new';
cfg.path.userCreate = '/user';
cfg.path.userShow = '/user/:id';
cfg.path.userEditForm = '/user/:id/edit';
cfg.path.userUpdate = '/user/:id/update';
cfg.path.userLoad = '/user/:id/:op?';      // for parameter handling

cfg.path.roleList = '/role';
cfg.path.roleNewForm = '/role/new';
cfg.path.roleCreate = '/role';
cfg.path.roleShow = '/role/:id';
cfg.path.roleEditForm = '/role/:id/edit';
cfg.path.roleUpdate = '/role/:id/update';
cfg.path.roleLoad = '/role/:id/:op?';      // for parameter handling

cfg.path.userLoad2 = '/user/:id/role/:op?';   // parameter handling
cfg.path.changeRoles = '/user/:id/role/changeroles';

cfg.path.profile = '/profile';          // GET for form, POST to save

cfg.path.setSuper = '/setsuper';        // GET for form, POST to save

cfg.path.pregnancyList = '/pregnancy';                // GET
cfg.path.pregnancyNewForm = '/pregnancy/new';         // GET
cfg.path.pregnancyCreate = '/pregnancy';              // POST
cfg.path.pregnancyEditForm = '/pregnancy/:id/edit';   // GET
cfg.path.pregnancyUpdate = '/pregnancy/:id/update';   // POST
cfg.path.pregnancyLoad = '/pregnancy/:id/:op?/:id2?/:op2?';       // parameter handling
cfg.path.pregnancyHistory = '/pregnancy/:id/history'; // GET
cfg.path.pregnancyQuesEdit = '/pregnancy/:id/quesEdit';   // GET
cfg.path.pregnancyQuesUpdate = '/pregnancy/:id/quesUpdate';   // POST
cfg.path.pregnancyMidwifeEdit = '/pregnancy/:id/midwifeinterview'; // GET
cfg.path.pregnancyMidwifeUpdate = '/pregnancy/:id/midwifeinterview'; // POST
// Pregnancy History
cfg.path.pregnancyHistoryAdd = '/pregnancy/:id/preghistory'; // GET/POST
cfg.path.pregnancyHistoryEdit = '/pregnancy/:id/preghistory/:id2'; // GET/POST
cfg.path.pregnancyHistoryDelete = '/pregnancy/:id/preghistory/:id2/delete'; // POST

cfg.path.pregnancyPrenatalEdit = '/pregnancy/:id/prenatal'; // GET
cfg.path.pregnancyPrenatalUpdate = '/pregnancy/:id/prenatal'; // POST
// Prenatal exams
cfg.path.pregnancyPrenatalExamAdd = '/pregnancy/:id/prenatalexam'; // GET/POST
cfg.path.pregnancyPrenatalExamEdit = '/pregnancy/:id/prenatalexam/:id2'; // GET/POST
cfg.path.pregnancyPrenatalExamDelete = '/pregnancy/:id/prenatalexam/:id2/delete'; // POST
// TODO: Are both of these routes used?
cfg.path.pregnancyLabsEditForm = '/pregnancy/:id/labs';     // GET
cfg.path.pregnancyLabsEdit = '/pregnancy/:id/labs';         // POST
// Lab Test Results
cfg.path.labTestAddForm = '/pregnancy/:id/labtestaddform';      // POST - a submitted form specifying the suite
cfg.path.labTestAdd = '/pregnancy/:id/labtest';              // POST - a submitted form with new test results
cfg.path.labTestEdit = '/pregnancy/:id/labtest/:id2';       // GET/POST
cfg.path.labTestDelete = '/pregnancy/:id/labtest/:id2/delete';   // POST
// Referrals
cfg.path.referralAdd = '/pregnancy/:id/referral';       // GET/POST - create/save new referral
cfg.path.referralEdit = '/pregnancy/:id/referral/:id2'; // GET/POST - edit/save referral
cfg.path.referralDelete = '/pregnancy/:id/referral/:id2/delete'; // POST - delete referral
// Doctor/Dentist Consult dates
cfg.path.docDenConsult = '/pregnancy/:id/doctordentist';  // POST
// Vaccinations
cfg.path.vaccinationAdd = '/pregnancy/:id/vaccination';         // GET/POST
cfg.path.vaccinationEdit = '/pregnancy/:id/vaccination/:id2';   // GET/POST
cfg.path.vaccinationDelete = '/pregnancy/:id/vaccination/:id2/delete';  // POST
// Medications
cfg.path.medicationAdd = '/pregnancy/:id/medication';         // GET/POST
cfg.path.medicationEdit = '/pregnancy/:id/medication/:id2';   // GET/POST
cfg.path.medicationDelete = '/pregnancy/:id/medication/:id2/delete';  // POST
// Checkin/Checkout
cfg.path.checkInOut = '/pregnancy/:id/checkinout';  // GET
cfg.path.checkIn = '/pregnancy/:id/checkin';        // POST
cfg.path.checkOut = '/pregnancy/:id/checkout';      // POST
cfg.path.newCheckIn = '/checkin';                   // GET/POST
cfg.path.simpleCheckOut = '/checkout';                 // GET/POST

// AJAX calls
cfg.path.requiredTetanus = '/pregnancy/:id/requiredtetanus';    // POST

// Reports
cfg.path.reportForm = '/report/form';                 // GET
cfg.path.reportRun = '/report/run';                   // POST

// Priority list
cfg.path.priorityListLoad = '/priorityList/:id/:op';  // parameter handling
cfg.path.priorityList = '/priorityList';         // GET/POST page and AJAX data
cfg.path.priorityListSave = '/priorityList/:id/save';      // POST to save data



module.exports = cfg;


