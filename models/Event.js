/*
 * -------------------------------------------------------------------------------
 * Event.js
 *
 * The model for certain events.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , _ = require('underscore')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Event = {}
  ;

/*
CREATE TABLE `event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eventType` int(11) NOT NULL,
  `eDateTime` datetime NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `sid` varchar(30) DEFAULT NULL,
  `pregnancy_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `eventType` (`eventType`),
  CONSTRAINT `event_ibfk_1` FOREIGN KEY (`eventType`) REFERENCES `eventType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

// --------------------------------------------------------
// Hard-coded events that relate to the eventType field
// in the events table (and the id field in the eventType
// table).
//
// TODO: fix hard-code by making sure the eventType inserted
// into the event table matches properly with the eventType
// table.
// --------------------------------------------------------
var LOGIN = 1
  , LOGOUT = 2
  , SUPER = 3
  , HISTORY = 4
  , PRENATAL_CHECKIN = 5
  , PRENATAL_CHECKOUT = 6
  , PRENATAL_CHART = 7
  ;

/* --------------------------------------------------------
 * recordEvent()
 *
 * Record the passed eventType in the event table and return
 * a promise.
 *
 * param       eventType - required event type
 * param       options - optional parameters
 * param       transaction - optional transaction to use
 * return      promise
 * -------------------------------------------------------- */
var recordEvent = function(eventType, options, transaction) {
  return new Promise(function(resolve, reject) {
    options.eDateTime = options.eDateTime || moment().format('YYYY-MM-DD HH:mm:ss');
    Event.forge(_.extend({eventType: eventType}, options))
      .save(null, {transacting: transaction})
      .then(function(evt) {
        resolve(evt);
      })
      .caught(function(err) {
        reject(err);
      });
  });
};

Event = Bookshelf.Model.extend({
  tableName: 'event'

  , permittedAttributes: ['id', 'eventType', 'eDateTime', 'note', 'sid',
      'pregnancy_id', 'user_id']

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


}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

  /* --------------------------------------------------------
   * loginEvent()
   * logoutEvent()
   * setSuperEvent()
   * historyEvent()
   * prenatalCheckInEvent()
   * prenatalCheckInEvent()
   * prenatalChartEvent()
   *
   * Records the appropriate event in the event table. Option
   * field names, which are all optional, are:
   *  note
   *  pregnancy_id
   *  user_id
   *  eDateTime
   *
   * param       options - an options object
   * param       transaction - an optional transaction object
   * return      promise
   * -------------------------------------------------------- */
  loginEvent: function(options, transaction) {
    return recordEvent(LOGIN, options, transaction);
  }
  , logoutEvent: function(options, transaction) {
      return recordEvent(LOGOUT, options, transaction);
    }
  , setSuperEvent: function(options, transaction) {
      return recordEvent(SUPER, options, transaction);
    }
  , historyEvent: function(options, transaction) {
      return recordEvent(HISTORY, options, transaction);
    }
  , prenatalCheckInEvent: function(options, transaction) {
      return recordEvent(PRENATAL_CHECKIN, options, transaction);
    }
  , prenatalCheckOutEvent: function(options, transaction) {
      return recordEvent(PRENATAL_CHECKOUT, options, transaction);
    }
  , prenatalChartEvent: function(options, transaction) {
      return recordEvent(PRENATAL_CHART, options, transaction);
    }

});

Events = Bookshelf.Collection.extend({
  model: Event
});

module.exports = {
  Event: Event
  , Events: Events
};

