/* 
 * -------------------------------------------------------------------------------
 * DB.js
 *
 * Creates the database connection. This only needs to be referenced once at the
 * beginning of the application. After that other modules may get a database
 * connection/Bookshelf object like this:
 *
 * // This is called once in the application.
 * var Bookshelf = require('bookshelf').init();
 *
 * ------------------------------------------------------------------------------- 
 */

var Bookshelf = require('bookshelf')
  ;

/* --------------------------------------------------------
 * init()
 *
 * Exposes Bookshelf.DB as the Bookshelf interface for all
 * other modules. This is called whenever a Bookshelf 
 * object is needed.
 *
 * Usage:
 * var Bookshelf = require('bookshelf').DB;
 *
 * param       dbSettings - object with connection settings
 * return      Bookshelf.DB - Bookshelf connection pool
 * -------------------------------------------------------- */
Bookshelf.DB = {};
var init = function(dbSettings) {
  Bookshelf.DB = Bookshelf.initialize({
    client: 'mysql'
    , connection: {
      host: dbSettings.host
      , port: dbSettings.port
      , user: dbSettings.dbUser
      , password: dbSettings.dbPass
      , database: dbSettings.db
      , charset: dbSettings.charset
    }
  });

  // --------------------------------------------------------
  // Define our base Model that all classes extend from.
  // --------------------------------------------------------
  Bookshelf.DB.Model = Bookshelf.DB.Model.extend({
    // --------------------------------------------------------
    // Object Properties.
    // --------------------------------------------------------

    initialize: function() {
      this.on('saving', this.saving, this);
    },

    saving: function() {
      // Only allow attributes that we know about.
      // Adapted from the Ghost project.
      console.log('BASE: saving()');
      if (this.permittedAttributes) {
        this.attributes = this.pick(this.permittedAttributes);
      }
    }

  }, {
    // --------------------------------------------------------
    // Class Properties.
    // --------------------------------------------------------

  });

  return Bookshelf.DB;
};


module.exports = {init: init};

