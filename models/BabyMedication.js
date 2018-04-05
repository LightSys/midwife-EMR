/*
 * -------------------------------------------------------------------------------
 * BabyMedication.js
 *
 * The model for the babyMedicationtable.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , BabyMedication = {}
  , BabyMedications
  ;

/*
CREATE TABLE `babyMedication` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `babyMedicationType` int(11) NOT NULL,
  `medicationDate` datetime NOT NULL,
  `location` varchar(50) DEFAULT NULL,
  `initials` varchar(50) DEFAULT NULL,
  `comments` varchar(100) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `baby_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `baby_id` (`baby_id`),
  KEY `babyMedicationType` (`babyMedicationType`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `babyMedication_ibfk_1` FOREIGN KEY (`baby_id`) REFERENCES `baby` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `babyMedication_ibfk_2` FOREIGN KEY (`babyMedicationType`) REFERENCES `babyMedicationType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `babyMedication_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

BabyMedication = Bookshelf.Model.extend({
  tableName: 'babyMedication'

  , permittedAttributes: ['id', 'babyMedicationType', 'medicationDate', 'location',
    'initials', 'comments', 'updatedBy', 'updatedAt', 'supervisor', 'baby_id']

  , initialize: function() {
    this.on('saving', this.saving, this);
    }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  //
  // Note: avoid circular references by using require() inline.
  // https://github.com/tgriesser/bookshelf/issues/105
  // --------------------------------------------------------

  , babyMedicationType: function() {
      return this.hasOne(require('./BabyMedicationType').BabyMedicationType, 'babyMedicationType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

BabyMedications = Bookshelf.Collection.extend({
  model: BabyMedication
});

module.exports = {
  BabyMedication: BabyMedication
  , BabyMedications: BabyMedications
};

