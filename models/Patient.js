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
CREATE TABLE IF NOT EXISTS `patient` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(70) NOT NULL,
  lastname VARCHAR(70) NOT NULL,
  nickname VARCHAR(70) NULL,
  dohID VARCHAR(10) NULL,
  dob DATE NULL,
  generalInfo VARCHAR(8192) NULL,
  gravida TINYINT NULL,
  stillBirths TINYINT NULL,
  abortions TINYINT NULL,
  living TINYINT NULL,
  para TINYINT NULL,
  term TINYINT NULL,
  preterm TINYINT NULL,
  ageOfMenarche TINYINT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NOT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);
*/

Patient = Bookshelf.Model.extend({
  tableName: 'patient'

  , permittedAttributes: ['id', 'firstname','lastname','nickname','dohID',
         'dob', 'generalInfo', 'gravida','stillBirths','abortions','living',
         'para','term','preterm','ageOfMenarche', 'updatedBy', 'updatedAt', 
         'supervisor']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  //, vaccination: function() {
      //return this.hasMany(Vaccination);
    //}
});

Patients = Bookshelf.Collection.extend({
  model: Patient
});

module.exports = {
  Patient: Patient
  , Patients: Patients
};

