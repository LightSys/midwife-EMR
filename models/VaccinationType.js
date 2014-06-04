/* 
 * -------------------------------------------------------------------------------
 * VaccinationType.js
 *
 * The model for types of vaccinations.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , VaccinationType = {}
  ;

/*
CREATE TABLE `vaccinationType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `vaccinationType_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `vaccinationType_ibfk_2` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
*/

VaccinationType = Bookshelf.Model.extend({
  tableName: 'vaccinationType'

  , permittedAttributes: ['id', 'name', 'description', 'updatedBy', 'updatedAt',
      'supervisor']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , vaccination: function() {
      return this.hasOne(require('./Vaccination').Vaccination, 'vaccinationType');
    }

});

VaccinationTypes = Bookshelf.Collection.extend({
  model: VaccinationType
});

module.exports = {
  VaccinationType: VaccinationType
  , VaccinationTypes: VaccinationTypes
};



