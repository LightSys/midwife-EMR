/*
 * -------------------------------------------------------------------------------
 * MotherMedicationType.js
 *
 * The model for the motherMedicationType table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , MotherMedicationType = {}
  , MotherMedicationTypes
  ;

/*
CREATE TABLE `motherMedicationType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `motherMedicationType_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
*/

MotherMedicationType = Bookshelf.Model.extend({
  tableName: 'motherMedicationType'

  , permittedAttributes: ['id', 'name', 'description', 'updatedBy',
    'updatedAt', 'supervisor']

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

  , motherMedication: function() {
      return this.hasMany(require('./MotherMedication').MotherMedication, 'motherMedicationType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

MotherMedicationTypes = Bookshelf.Collection.extend({
  model: MotherMedicationType
});

module.exports = {
  MotherMedicationType: MotherMedicationType
  , MotherMedicationTypes: MotherMedicationTypes
};


