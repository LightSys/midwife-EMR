/*
 * -------------------------------------------------------------------------------
 * Patient.js
 *
 * The model for patient data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Patient = {}
  ;

/*
CREATE TABLE `patient` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dohID` varchar(10) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `generalInfo` varchar(8192) DEFAULT NULL,
  `ageOfMenarche` tinyint(4) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `patient_ibfk_2` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

Patient = Bookshelf.Model.extend({
  tableName: 'patient'

  , permittedAttributes: ['id', 'dohID', 'dob', 'generalInfo', 'ageOfMenarche',
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

  , pregnancies: function() {
      return this.hasMany(require('./Pregnancy').Pregnancy, 'patient_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

  /* --------------------------------------------------------
   * checkFields()
   *
   * Check the validity of the passed fields and return a
   * promise whether they are sufficient or not.
   *
   * param       flds - object containing field keys and values
   * return      undefined
   * -------------------------------------------------------- */
  checkFields: function(flds) {
    return new Promise(function(resolve, reject) {
      var msgs = []
        ;
      if (! val.isDate(flds.dob)) msgs.push('Date of birth must be specified.');

      if (msgs.length !== 0) {
        reject(msgs.join(' '));
      } else {
        resolve(flds);
      }
    });
  }

});

Patients = Bookshelf.Collection.extend({
  model: Patient
});

module.exports = {
  Patient: Patient
  , Patients: Patients
};

