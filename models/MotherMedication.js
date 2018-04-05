/*
 * -------------------------------------------------------------------------------
 * MotherMedication.js
 *
 * The model for the motherMedication table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , MotherMedication = {}
  , MotherMedications
  ;

/*
CREATE TABLE `motherMedication` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `motherMedicationType` int(11) NOT NULL,
  `medicationDate` datetime NOT NULL,
  `initials` varchar(50) DEFAULT NULL,
  `comments` varchar(100) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labor_id` (`labor_id`,`motherMedicationType`),
  KEY `motherMedicationType` (`motherMedicationType`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `motherMedication_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `motherMedication_ibfk_2` FOREIGN KEY (`motherMedicationType`) REFERENCES `motherMedicationType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `motherMedication_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

MotherMedication = Bookshelf.Model.extend({
  tableName: 'motherMedication'

  , permittedAttributes: ['id', 'motherMedicationType', 'medicationDate',
    'initials', 'comments', 'updatedBy', 'updatedAt', 'supervisor', 'labor_id']

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

  , motherMedicationType: function() {
      return this.hasOne(require('./MotherMedicationType').MotherMedicationType, 'motherMedicationType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

MotherMedications = Bookshelf.Collection.extend({
  model: MotherMedication
});

module.exports = {
  MotherMedication: MotherMedication
  , MotherMedications: MotherMedications
};


