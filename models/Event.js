/*
 * -------------------------------------------------------------------------------
 * Event.js
 *
 * The model for certain events.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
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
  `at` datetime NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `eventType` (`eventType`),
  CONSTRAINT `event_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `event_ibfk_2` FOREIGN KEY (`eventType`) REFERENCES `eventType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
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
  ;

/* --------------------------------------------------------
 * recordEvent()
 *
 * Record the passed eventType in the event table and return
 * a promise.
 *
 * param       userId - integer id of the user the event concerns
 * param       note - optional String
 * return      promise
 * -------------------------------------------------------- */
var recordEvent = function(userId, note, eventType) {
  return new Promise(function(resolve, reject) {
    var n = note || ''
      , at = moment().format('YYYY-MM-DD HH:mm:ss')
      ;
    Event.forge({eventType: eventType, user_id: userId, at: at, note: n})
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

  , permittedAttributes: ['id', 'eventType', 'at', 'note', 'user_id']

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
   *
   * Records the appropriate event in the event table.
   *
   * param       userId - integer id of the user the event concerns
   * param       note - optional String
   * return      promise
   * -------------------------------------------------------- */
  loginEvent: function(userId, note) {return recordEvent(userId, note, LOGIN);}
  , logoutEvent: function(userId, note) {return recordEvent(userId, note, LOGOUT);}
  , setSuperEvent: function(userId, note) {return recordEvent(userId, note, SUPER);}
  , historyEvent: function(userId, note) {return recordEvent(userId, note, HISTORY);}

});

Events = Bookshelf.Collection.extend({
  model: Event
});

module.exports = {
  Event: Event
  , Events: Events
};

