/* 
 * -------------------------------------------------------------------------------
 * Vaccination.js
 *
 * The model for vaccination data.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Vaccination = {}
  ;

/*
CREATE TABLE `vaccination` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vaccinationType` int(11) NOT NULL,
  `vacDate` date DEFAULT NULL,
  `vacMonth` tinyint(4) DEFAULT NULL,
  `vacYEAR` int(11) DEFAULT NULL,
  `administeredInternally` tinyint(1) NOT NULL,
  `note` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `pregnancy_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pregnancy_id` (`pregnancy_id`),
  KEY `vaccinationType` (`vaccinationType`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `vaccination_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `vaccination_ibfk_2` FOREIGN KEY (`vaccinationType`) REFERENCES `vaccinationType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `vaccination_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `vaccination_ibfk_4` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

Vaccination = Bookshelf.Model.extend({
  tableName: 'vaccination'

  , permittedAttributes: ['id', 'vaccinationType', 'vacDate', 'vacMonth', 'vacYear',
      'administeredInternally', 'note', 'updatedBy', 'updatedAt', 'supervisor',
      'pregnancy_id']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }
  , vaccinationType: function() {
      return this.belongsTo(require('./VaccinationType').VaccinationType, 'vaccinationType');
    }

});

Vaccinations = Bookshelf.Collection.extend({
  model: Vaccination
});

module.exports = {
  Vaccination: Vaccination
  , Vaccinations: Vaccinations
};



