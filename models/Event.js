/*
 * -------------------------------------------------------------------------------
 * Event.js
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
 * return      promise
 * -------------------------------------------------------- */
var recordEvent = function(eventType, options) {
  return new Promise(function(resolve, reject) {
    options.eDateTime = moment().format('YYYY-MM-DD HH:mm:ss')
    Event.forge(_.extend({eventType: eventType}, options))
      .save()
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
   * field names are:
   *  note
   *  sid
   *  pregnancyId
   *  userId
   *
   * param       options - an options object
   * return      promise
   * -------------------------------------------------------- */
  loginEvent: function(options) {return recordEvent(LOGIN, options);}
  , logoutEvent: function(options) {return recordEvent(LOGOUT, options);}
  , setSuperEvent: function(options) {return recordEvent(SUPER, options);}
  , historyEvent: function(options) {return recordEvent(HISTORY, options);}
  , prenatalCheckInEvent: function(options) {
      return recordEvent(PRENATAL_CHECKIN, options);
    }
  , prenatalCheckOutEvent: function(options) {
      return recordEvent(PRENATAL_CHECKOUT, options);
    }
  , prenatalChartEvent: function(options) {
      return recordEvent(PRENATAL_CHART, options);
    }

});

Events = Bookshelf.Collection.extend({
  model: Event
});

module.exports = {
  Event: Event
  , Events: Events
};

