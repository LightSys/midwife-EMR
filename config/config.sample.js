/*
 * -------------------------------------------------------------------------------
 * config.js
 *
 * Sample configuration file. Make a copy as a starting point for your configuration.
 * 
 * cp config.sample.js config.development.js
 *
 * Usage:
 *
 * NODE_ENV=development node index.js
 * -------------------------------------------------------------------------------
 */

var fs = require('fs')
  , _ = require('underscore')
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
cfg.site.title = gettext('Your Site Name');
cfg.site.languagesMap = {
  'en-US': 'English - Unites States'
  , 'it-CH': 'Debugging language'
};
cfg.site.languages = _.keys(cfg.site.languagesMap);
cfg.site.defaultLanguage = 'en-US';
cfg.site.debugLanguage = 'it-CH';
cfg.site.tmpDir = 'tmp';

// --------------------------------------------------------
// Search settings.
// --------------------------------------------------------
cfg.search = {};
cfg.search.rowsPerPage = 20;

// --------------------------------------------------------
// Host settings.
// --------------------------------------------------------
cfg.host.port = 8000;
cfg.host.name = 'example.com';    // must be set for TLS use.
cfg.host.tlsPort = 443;

// --------------------------------------------------------
// TLS settings.
// Note that this section follows the Node API here.
// http://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener
// --------------------------------------------------------
cfg.tls.key = fs.readFileSync('cert/example.com.key.pem');  // Set to false to disable TLS.
cfg.tls.cert = fs.readFileSync('cert/example.com.crt.pem');
cfg.tls.passphrase = '';
cfg.tls.ciphers = 'AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH';
cfg.tls.handshakeTimeout = 600;
cfg.tls.honorCipherOrder = true;

// --------------------------------------------------------
// Database settings.
// --------------------------------------------------------
cfg.database.host = 'localhost';
cfg.database.port = 3306;
cfg.database.charset = 'utf8';
cfg.database.db = 'YourDatabaseName';
cfg.database.dbUser = 'YourDatabaseUser';
cfg.database.dbPass = 'SomePasswordHere';

// --------------------------------------------------------
// Cache settings.
// --------------------------------------------------------
cfg.cache = {};
cfg.cache.userTTL = 1200;   // TTL is in seconds

// --------------------------------------------------------
// Session settings.
// --------------------------------------------------------
cfg.session.secret = 'SomethingSpecial';
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
cfg.cookie.secret = 'SomethingElseSpecial';
cfg.cookie.maxAge = 60 * 30 * 1000;    // 30 minutes


module.exports = cfg;


