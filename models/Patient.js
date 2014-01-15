/* 
 * -------------------------------------------------------------------------------
 * Patient.js
 *
 * The model for patient data.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Patient = {}
  ;

/*
CREATE TABLE `patients` (
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `nickname` varchar(255) DEFAULT NULL,
  `mmcID` varchar(255) DEFAULT NULL,
  `dob` datetime DEFAULT NULL,
  `bloodType` varchar(255) DEFAULT NULL,
  `criticalInfo` text,
  `generalInfo` text,
  `menarche` int(11) DEFAULT NULL,
  `mammography` tinyint(1) DEFAULT NULL,
  `breastSelfExam` tinyint(1) DEFAULT NULL,
  `papTest` tinyint(1) DEFAULT NULL,
  `colposcopy` tinyint(1) DEFAULT NULL,
  `gravida` int(11) DEFAULT NULL,
  `stillBirths` int(11) DEFAULT NULL,
  `abortions` int(11) DEFAULT NULL,
  `living` int(11) DEFAULT NULL,
  `para` int(11) DEFAULT NULL,
  `term` int(11) DEFAULT NULL,
  `preterm` int(11) DEFAULT NULL,
  `philHealth` tinyint(1) DEFAULT NULL,
  `philHealthMCP` tinyint(1) DEFAULT NULL,
  `philHealthNCP` tinyint(1) DEFAULT NULL,
  `philHealthID` varchar(255) DEFAULT NULL,
  `gramStain` tinyint(1) DEFAULT NULL,
  `breastExamTaught` tinyint(1) DEFAULT NULL,
  `maritalStatus` enum('unspecified','Live-in','Single','Married','Concubinage','Widowed','Divorced','Separated') DEFAULT 'unspecified',
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=862 DEFAULT CHARSET=latin1
*/

Patient = Bookshelf.Model.extend({
  tableName: 'patients'

  , permittedAttributes: ['firstname','lastname','nickname','mmcID','bloodType',
         'criticalInfo','generalInfo','menarche','mammography','breastSelfExam',
         'papTest','colposcopy','gravida','stillBirths','abortions','living',
         'para','term','preterm','philHealth','philHealthMCP','philHealthNCP',
         'philHealthID','gramStain','breastExamTaught','maritalStatus','id',
         'createdAt','updatedAt']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , vaccination: function() {
      return this.hasMany(Vaccination);
    }
});

Patients = Bookshelf.Collection.extend({
  model: Patient
});

module.exports = {
  Patient: Patient
  , Patients: Patients
};

