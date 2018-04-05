/*
 * -------------------------------------------------------------------------------
 * BabyVaccination.js
 *
 * The model for the babyVaccinationtable.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , BabyVaccination = {}
  , BabyVaccinations
  ;

/*
CREATE TABLE `babyVaccination` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `babyVaccinationType` int(11) NOT NULL,
  `vaccinationDate` datetime NOT NULL,
  `location` varchar(50) DEFAULT NULL,
  `initials` varchar(50) DEFAULT NULL,
  `comments` varchar(100) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `baby_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `baby_id` (`baby_id`,`babyVaccinationType`),
  KEY `babyVaccinationType` (`babyVaccinationType`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `babyVaccination_ibfk_1` FOREIGN KEY (`baby_id`) REFERENCES `baby` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `babyVaccination_ibfk_2` FOREIGN KEY (`babyVaccinationType`) REFERENCES `babyVaccinationType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `babyVaccination_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

BabyVaccination = Bookshelf.Model.extend({
  tableName: 'babyVaccination'

  , permittedAttributes: ['id', 'babyVaccinationType', 'vaccinationDate', 'location',
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

  , babyVaccinationType: function() {
      return this.hasOne(require('./BabyVaccinationType').BabyVaccinationType, 'babyVaccinationType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

BabyVaccinations = Bookshelf.Collection.extend({
  model: BabyVaccination
});

module.exports = {
  BabyVaccination: BabyVaccination
  , BabyVaccinations: BabyVaccinations
};


