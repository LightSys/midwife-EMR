/*
 * -------------------------------------------------------------------------------
 * BabyMedicationType.js
 *
 * The model for the babyMedicationType table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , BabyMedicationType = {}
  , BabyMedicationTypes
  ;

/*
CREATE TABLE `babyMedicationType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `useLocation` tinyint(1) NOT NULL DEFAULT '0',
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `babyMedicationType_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
*/

BabyMedicationType = Bookshelf.Model.extend({
  tableName: 'babyMedicationType'

  , permittedAttributes: ['id', 'name', 'description', 'useLocation',
    'updatedBy', 'updatedAt', 'supervisor']

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

  , babyMedication: function() {
      return this.hasMany(require('./BabyMedication').BabyMedication, 'babyMedicationType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

BabyMedicationTypes = Bookshelf.Collection.extend({
  model: BabyMedicationType
});

module.exports = {
  BabyMedicationType: BabyMedicationType
  , BabyMedicationTypes: BabyMedicationTypes
};

