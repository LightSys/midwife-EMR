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
  , Promise = require('bluebird')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
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
    }

      // Sets updatedBy and flags that field was set.
    , setUpdatedBy: function(id) {
        this.set('updatedBy', id);
        this.set('requiredUpdatedBy', true);
        return this;
      }

      // Sets the supervisor field and flags that the field was set.
    , setSupervisor: function(id) {
        this.set('supervisor', id);
        this.set('requiredSupervisor', true);
        return this;
      }

    , saving: function() {
        // Check flag fields to confirm that required fields were set. Flag
        // fields themselves are removed by the permittedAttributes check below.
        if (! this.noLogging) {
          if (! this.get('requiredUpdatedBy')) {
            throw new Error('updatedBy field not set for ' + this.tableName);
          }
          if (! this.get('requiredSupervisor')) {
            throw new Error('supervisor field not set for ' + this.tableName);
          }
        }

        // Only allow attributes that we know about.
        // Adapted from the Ghost project.
        if (this.permittedAttributes) {
          this.attributes = this.pick(this.permittedAttributes);
        }

        // Tables known to not set updatedAt so don't log when they don't.
        var noLoggingTables = ['event'];

        // Set the updatedAt field to the current time whether creating
        // or updating unless noLogging is set.
        if (! this.noLogging) {
          this.set('updatedAt', moment().format('YYYY-MM-DD HH:mm:ss'));
        } else {
          if (!_.contains(noLoggingTables, this.tableName)) {
            logInfo('updatedAt not set for ' + this.tableName);
          }
        }
      }

      /* --------------------------------------------------------
       * historyData()
       *
       * Return historical data for this record.
       *
       * param       id
       * return      a promise
       * -------------------------------------------------------- */
    , historyData: function(id) {
        var tableName = this.tableName
          ;
        return new Promise(function(resolve, reject) {
          var knex = Bookshelf.DB.knex
            ;
          knex(tableName + 'Log')
            .where({id: id})
            .orderBy('replacedAt', 'desc')
            .select()
            .then(function(list) {
              // --------------------------------------------------------
              // Fix the date so that it displays shorter.
              // --------------------------------------------------------
              _.each(list, function(item) {
                item.replacedAt = moment(item.replacedAt).format('YYYY-MM-DD HH:mm:ss');
              });
              resolve(list);
            })
            .caught(function(err) {
              logError(err);
              reject(err);
            });
        });
      }

  }, {
    // --------------------------------------------------------
    // Class Properties.
    // --------------------------------------------------------

  });

  return Bookshelf.DB;
};


module.exports = {init: init};

