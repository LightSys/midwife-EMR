/* 
 * -------------------------------------------------------------------------------
 * Medication.js
 *
 * The model for medication and vitamin data.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Medication = {}
  ;

/*
CREATE TABLE `medication` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `medicationType` int(11) NOT NULL,
  `numberDispensed` int(11) DEFAULT NULL,
  `note` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `pregnancy_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pregnancy_id` (`pregnancy_id`),
  KEY `medicationType` (`medicationType`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `medication_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `medication_ibfk_2` FOREIGN KEY (`medicationType`) REFERENCES `medicationType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `medication_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `medication_ibfk_4` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

Medication = Bookshelf.Model.extend({
  tableName: 'medication'

  , permittedAttributes: ['id', 'date', 'medicationType', 'numberDispensed', 'note',
      'updatedBy', 'updatedAt', 'supervisor', 'pregnancy_id']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }
  , medicationType: function() {
      return this.belongsTo(require('./MedicationType').MedicationType, 'medicationType');
    }

});

Medications = Bookshelf.Collection.extend({
  model: Medication
});

module.exports = {
  Medication: Medication
  , Medications: Medications
};



