/*
 * -------------------------------------------------------------------------------
 * Priority.js
 *
 * The model for priority data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , _ = require('underscore')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Priority = {}
  ;

/*
CREATE TABLE `priority` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eType` int(11) NOT NULL,
  `priority` int(11) NOT NULL,
  `barcode` int(11) NOT NULL,
  `assigned` datetime DEFAULT NULL,
  `pregnancy_id` int(11) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `priority` (`priority`,`eType`),
  UNIQUE KEY `barcode` (`barcode`),
  KEY `eType` (`eType`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `priority_ibfk_1` FOREIGN KEY (`eType`) REFERENCES `eventType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `priority_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `priority_ibfk_3` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=latin1
*/


/* --------------------------------------------------------
 * getAvailablePriorityBarcodes()
 *
 * Get a list of all of the priority barcodes that are unassigned
 * to pregnancies for the given event type. Returns a promise.
 *
 * param       eType
 * return      list
 * -------------------------------------------------------- */
var getAvailablePriorityBarcodes = function(eType) {
  return new Promise(function(resolve, reject) {
    new Priorities().query(function(qb) {
        qb.where('eType', '=', eType);
        qb.whereNull('pregnancy_id');
        return qb;
      })
      .fetch()
      .then(function(list) {
        if (list === null) return resolve([]);
        resolve(list.pluck('barcode'));
      })
      .caught(function(err) {
        reject(err);
      });
  });
};

/* --------------------------------------------------------
 * getAssignedPriorityBarcodes()
 *
 * Get a list of all of the priority barcodes are are already
 * assigned to pregnancies for the given event type. Returns
 * a promise.
 *
 * param       eType
 * return      list
 * -------------------------------------------------------- */
var getAssignedPriorityBarcodes = function(eType) {
  var et = eType
    ;
  return new Promise(function(resolve, reject) {
    new Priorities().query(function(qb) {
        qb.whereNotNull('pregnancy_id');
        qb.andWhere('eType', '=', et);
      })
      .fetch()
      .then(function(list) {
        resolve(list.pluck('barcode'));
      })
      .caught(function(err) {
        reject(err);
      });
  });
};

Priority = Bookshelf.Model.extend({
  tableName: 'priority'

  , permittedAttributes: ['id', 'eType', 'priority', 'barcode', 'assigned'
      , 'pregnancy_id', 'updatedBy', 'updatedAt', 'supervisor']

  , initialize: function() {
    this.on('saving', this.saving, this);
    }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------

  , pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }

  , eventType: function() {
      return this.belongsTo(require('./EventType').EventType, 'eType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

  getAvailablePriorityBarcodes: getAvailablePriorityBarcodes
  , getAssignedPriorityBarcodes: getAssignedPriorityBarcodes

});

Priorities = Bookshelf.Collection.extend({
  model: Priority
});

module.exports = {
  Priority: Priority
  , Priorities: Priorities
};

