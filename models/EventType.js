/*
 * -------------------------------------------------------------------------------
 * EventType.js
 *
 * The model for certain events.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , _ = require('underscore')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , EventType = {}
  ;

/*
CREATE TABLE `eventType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1
*/


EventType = Bookshelf.Model.extend({
  tableName: 'eventType'

  , permittedAttributes: ['id', 'name', 'description']

  , initialize: function() {
    this.on('saving', this.saving, this);
    }

    // --------------------------------------------------------
    // Flag for the super class to use to determine if the updatedAt
    // field should not be set automatically and the updatedBy and
    // supervisor fields should not be required either.
    // --------------------------------------------------------
  , noLogging: true

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------

  , event: function() {
      return this.hasMany(require('./Event').Event, 'eventType');
    }

  , priority: function() {
      return this.hasMany(require('./Priority').Priority, 'eType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------


});

EventTypes = Bookshelf.Collection.extend({
  model: EventType
});

module.exports = {
  EventType: EventType
  , EventTypes: EventTypes
};

