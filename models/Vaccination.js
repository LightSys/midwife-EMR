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
CREATE TABLE `vaccinations` (
  `administeredInternally` tinyint(1) DEFAULT '1',
  `administeredBy` varchar(255) DEFAULT NULL,
  `administerDate` datetime DEFAULT NULL,
  `approxAdministerYear` int(11) DEFAULT NULL,
  `approxAdministerMonth` enum('','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') DEFAULT '',
  `nextDoseDate` datetime DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `vaccine_id` int(11) DEFAULT NULL,
  `patient_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `vaccinations_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=173 DEFAULT CHARSET=latin1
*/

Vaccination = Bookshelf.Model.extend({
  tableName: 'vaccinations'

  , permittedAttributes: ['administeredInternally','administeredBy','administerDate',
            'approxAdministerYear','approxAdministerMonth','nextDoseDate','id',
            'createdAt','updatedAt','vaccine_id','patient_id']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , patient: function() {
      return this.belongsTo(Patient);
    }
  , vaccine: function() {
      return this.hasOne(Vaccine);
    }

});

Vaccinations = Bookshelf.Collection.extend({
  model: Vaccination
});

module.exports = {
  Vaccination: Vaccination
  , Vaccinations: Vaccinations
};



