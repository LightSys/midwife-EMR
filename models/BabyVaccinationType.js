/*
 * -------------------------------------------------------------------------------
 * BabyVaccinationType.js
 *
 * The model for the babyVaccinationType table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , BabyVaccinationType = {}
  , BabyVaccinationTypes
  ;

/*
CREATE TABLE `babyVaccinationType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `useLocation` tinyint(1) NOT NULL DEFAULT '0',
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `babyVaccinationType_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
*/

BabyVaccinationType = Bookshelf.Model.extend({
  tableName: 'babyVaccinationType'

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

  , babyVaccination: function() {
      return this.hasMany(require('./BabyVaccination').BabyVaccination, 'babyVaccinationType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

BabyVaccinationTypes = Bookshelf.Collection.extend({
  model: BabyVaccinationType
});

module.exports = {
  BabyVaccinationType: BabyVaccinationType
  , BabyVaccinationTypes: BabyVaccinationTypes
};


