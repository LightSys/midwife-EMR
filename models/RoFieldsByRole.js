/*
 * -------------------------------------------------------------------------------
 * RoFieldsByRole.js
 *
 * Stores fields that are restricted to read-only based upon the user's role.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , Promise = require('bluebird')
  , _ = require('underscore')
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , NodeCache = require('node-cache')
  , cfg = require('../config')
  , fieldsCache = new NodeCache({stdTTL: cfg.cache.longTTL, checkperiod: Math.round(cfg.cache.longTTL/10)})
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , RoFieldsByRole = {}
  ;

/*
CREATE TABLE `roFieldsByRole` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roleName` varchar(30) NOT NULL,
  `tableName` varchar(30) NOT NULL,
  `fieldName` varchar(30) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roleName` (`roleName`,`tableName`,`fieldName`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1
*/

RoFieldsByRole = Bookshelf.Model.extend({
  tableName: 'roFieldsByRole'

  , permittedAttributes: ['id', 'roleName', 'tableName', 'fieldName']

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

  /* --------------------------------------------------------
   * getTableFieldsByRole()
   *
   * Return an object with elements of fieldnames that should
   * be read-only for the specified role and table combination.
   *
   * Caches results according to cfg.cache.longTTL settings.
   *
   * param      role
   * param      table
   * return     A promise
   * -------------------------------------------------------- */
  getTableFieldsByRole: function(role, table) {
    return new Promise(function(resolve, reject) {
      var knex = Bookshelf.knex
        , key = 'roFieldsByRole-' + role + '-' + table
        ;
      fieldsCache.get(key, function(err, map) {
        if (err) return reject(err);
        if (map && _.size(map) > 0) {
          logInfo('Resolving ' + key + ' using cache.');
          return resolve(map[key]);
        }

        logInfo('RoFieldsByRole.getTableFieldsByRole() - Refreshing ro fields map cache.');
        knex('roFieldsByRole')
          .where('roleName', '=', role)
          .andWhere('tableName', '=', table)
          .orderBy('id', 'asc')
          .select(['fieldName'])
          .then(function(list) {
            var map = {};
            _.each(list, function(obj) {
              // list is in form [{fieldName: '...'}, {fieldName: '...'}]
              map[obj.fieldName] = true;
            });
            fieldsCache.set(key, map);
            resolve(map);
          })
          .caught(function(err) {
            logError(err);
            reject(err);
          });
      });
    });
  }


});

RoFieldsByRoles = Bookshelf.Collection.extend({
  model: RoFieldsByRole
});

module.exports = {
  RoFieldsByRole: RoFieldsByRole
  , RoFieldsByRoles: RoFieldsByRoles
};



