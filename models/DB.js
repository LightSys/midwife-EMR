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
  , moment = require('moment')
  , _ = require('underscore')
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
      if (this.permittedAttributes) {
        this.attributes = this.pick(this.permittedAttributes);
      }
      // Set the updatedAt field to the current time whether creating
      // or updating.
      this.set('updatedAt', moment().format('YYYY-MM-DD HH:mm:ss'));
    }

    , logInsert: function(model, knex) {
        // Insert a record into the log table.
        var sql = Bookshelf.DB.Model.createSQL(model.tableName, model.get('id'), 'I');
        Bookshelf.DB.Model.runSQL(knex, sql);
    }

    , logUpdate: function(model, knex) {
        // Insert a record into the log table.
        var sql = Bookshelf.DB.Model.createSQL(model.tableName, model.get('id'), 'U');
        Bookshelf.DB.Model.runSQL(knex, sql);
    }

    , logDelete: function(model, knex) {
        // Insert a record into the log table.
        var sql = Bookshelf.DB.Model.createSQL(model.tableName, model.get('id'), 'D');
        Bookshelf.DB.Model.runSQL(knex, sql);
    }

  }, {
    // --------------------------------------------------------
    // Class Properties.
    // --------------------------------------------------------

    createSQL: function(tbl, id, op) {
      // Create the SQL to log changes to the database.
      var sql;
      if (op && _.indexOf(['I', 'U', 'D'], op) > -1) {
        sql = 'INSERT INTO ' + tbl +
          'Log SELECT ' + tbl + '.*, "' + op + '", NOW() FROM ' +
          tbl + ' WHERE id = ' + id
          ;
        return sql;
      }
      return new Error('op must be one of I, U, or D');
    }

    , runSQL: function(knex, sql) {
        knex.raw(sql)
          .then(function(resp) {
            if (resp[0].affectedRows != 1) {
              console.error(resp);
            }
          });
    }

  });

  return Bookshelf.DB;
};


module.exports = {init: init};

