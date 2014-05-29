/*
 * -------------------------------------------------------------------------------
 * config.js
 *
 * Configuration for the development environment.
 *
 * Usage:
 *
 * NODE_ENV=development node index.js
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  ;

var cfg = require('./config.global')
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
// --------------------------------------------------------
cfg.site.title = gettext('Mercy Maternity');
cfg.site.languagesMap = {
  'en-US': 'English - Unites States'
  , 'it-CH': 'Debugging language'
  , 'ceb': 'Cebuano'
};
cfg.site.languages = _.keys(cfg.site.languagesMap);
cfg.site.defaultLanguage = 'en-US';
cfg.site.debugLanguage = 'it-CH';
cfg.site.tmpDir = 'tmp';

// --------------------------------------------------------
// Search settings.
// --------------------------------------------------------
cfg.search = {};
cfg.search.rowsPerPage = 5;

// --------------------------------------------------------
// Host settings.
// --------------------------------------------------------
cfg.host.port = 3000

// --------------------------------------------------------
// Database settings.
// --------------------------------------------------------
cfg.database.host = 'localhost';
cfg.database.port = 3306;
cfg.database.db = 'mercy1';
cfg.database.dbUser = 'mercy1user';
cfg.database.dbPass = '7JVMeqXAiqTTXdvKCVFfaWmHe';
cfg.database.charset = 'utf8';

// --------------------------------------------------------
// Cache settings.
// --------------------------------------------------------
cfg.cache = {};
cfg.cache.userTTL = 1200;   // TTL is in seconds

// --------------------------------------------------------
// Session settings.
// --------------------------------------------------------
cfg.session.secret = 'ttq5BHqbA4Zhgk48BYL5tyjaz2XTcCAjMkmYEcmaKZd6rave2i';
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
cfg.cookie.secret = 'XDK8cZEAu8QEKE8Bu8abXFxaqjCkgG4HB2sJiXppfnHmnCfigf';
cfg.cookie.maxAge = 60 * 30 * 1000;    // 30 minutes


// --------------------------------------------------------
// Path settings: note that these should be set
// in config.global.js because they do not change depending
// upon the environment.
// --------------------------------------------------------


module.exports = cfg;


