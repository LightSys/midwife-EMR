/*
 * -------------------------------------------------------------------------------
 * Pregnancy.js
 *
 * The model for pregnancy data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , Promise = require('bluebird')
  , moment = require('moment')
  , _ = require('underscore')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Pregnancy = {}
  ;

/*
CREATE TABLE `pregnancy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(70) NOT NULL,
  `lastname` varchar(70) NOT NULL,
  `maidenname` varchar(70) DEFAULT NULL,
  `nickname` varchar(70) DEFAULT NULL,
  `religion` varchar(50) DEFAULT NULL,
  `maritalStatus` varchar(50) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `work` varchar(50) DEFAULT NULL,
  `education` varchar(70) DEFAULT NULL,
  `clientIncome` int(11) DEFAULT NULL,
  `clientIncomePeriod` varchar(15) DEFAULT NULL,
  `address1` varchar(150) DEFAULT NULL,
  `address2` varchar(150) DEFAULT NULL,
  `address3` varchar(150) DEFAULT NULL,
  `address4` varchar(150) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(150) DEFAULT NULL,
  `postalCode` varchar(50) DEFAULT NULL,
  `country` varchar(150) DEFAULT NULL,
  `gravidaNumber` tinyint(4) DEFAULT NULL,
  `lmp` date DEFAULT NULL,
  `sureLMP` tinyint(1) DEFAULT '0',
  `warning` tinyint(1) DEFAULT '0',
  `riskNote` varchar(250) DEFAULT NULL,
  `alternateEdd` date DEFAULT NULL,
  `useAlternateEdd` tinyint(1) DEFAULT '0',
  `doctorConsultDate` date DEFAULT NULL,
  `dentistConsultDate` date DEFAULT NULL,
  `mbBook` tinyint(1) DEFAULT NULL,
  `whereDeliver` varchar(100) DEFAULT NULL,
  `fetuses` tinyint(4) DEFAULT NULL,
  `monozygotic` tinyint(4) DEFAULT NULL,
  `pregnancyEndDate` date DEFAULT NULL,
  `pregnancyEndResult` varchar(100) DEFAULT NULL,
  `iugr` tinyint(1) DEFAULT NULL,
  `note` varchar(2000) DEFAULT NULL,
  `numberRequiredTetanus` tinyint(4) DEFAULT NULL,
  `invertedNipples` tinyint(1) DEFAULT NULL,
  `hasUS` tinyint(1) DEFAULT NULL,
  `wantsUS` tinyint(1) DEFAULT NULL,
  `gravida` tinyint(4) DEFAULT NULL,
  `stillBirths` tinyint(4) DEFAULT NULL,
  `abortions` tinyint(4) DEFAULT NULL,
  `living` tinyint(4) DEFAULT NULL,
  `para` tinyint(4) DEFAULT NULL,
  `term` tinyint(4) DEFAULT NULL,
  `preterm` tinyint(4) DEFAULT NULL,
  `philHealthMCP` tinyint(1) DEFAULT '0',
  `philHealthNCP` tinyint(1) DEFAULT '0',
  `philHealthID` varchar(12) DEFAULT NULL,
  `philHealthApproved` tinyint(1) DEFAULT '0',
  `currentlyVomiting` tinyint(1) DEFAULT NULL,
  `currentlyDizzy` tinyint(1) DEFAULT NULL,
  `currentlyFainting` tinyint(1) DEFAULT NULL,
  `currentlyBleeding` tinyint(1) DEFAULT NULL,
  `currentlyUrinationPain` tinyint(1) DEFAULT NULL,
  `currentlyBlurryVision` tinyint(1) DEFAULT NULL,
  `currentlySwelling` tinyint(1) DEFAULT NULL,
  `currentlyVaginalPain` tinyint(1) DEFAULT NULL,
  `currentlyVaginalItching` tinyint(1) DEFAULT NULL,
  `currentlyNone` tinyint(1) DEFAULT NULL,
  `useIodizedSalt` char(1) DEFAULT '',
  `takingMedication` char(1) NOT NULL DEFAULT '',
  `planToBreastFeed` char(1) NOT NULL DEFAULT '',
  `birthCompanion` varchar(30) DEFAULT NULL,
  `practiceFamilyPlanning` tinyint(1) DEFAULT NULL,
  `practiceFamilyPlanningDetails` varchar(100) DEFAULT NULL,
  `familyHistoryTwins` tinyint(1) DEFAULT NULL,
  `familyHistoryHighBloodPressure` tinyint(1) DEFAULT NULL,
  `familyHistoryDiabetes` tinyint(1) DEFAULT NULL,
  `familyHistoryHeartProblems` tinyint(1) DEFAULT NULL,
  `familyHistoryTB` tinyint(1) DEFAULT NULL,
  `familyHistorySmoking` tinyint(1) DEFAULT NULL,
  `familyHistoryNone` tinyint(1) DEFAULT NULL,
  `historyFoodAllergy` tinyint(1) DEFAULT NULL,
  `historyMedicineAllergy` tinyint(1) DEFAULT NULL,
  `historyAsthma` tinyint(1) DEFAULT NULL,
  `historyHeartProblems` tinyint(1) DEFAULT NULL,
  `historyKidneyProblems` tinyint(1) DEFAULT NULL,
  `historyHepatitis` tinyint(1) DEFAULT NULL,
  `historyGoiter` tinyint(1) DEFAULT NULL,
  `historyHighBloodPressure` tinyint(1) DEFAULT NULL,
  `historyHospitalOperation` tinyint(1) DEFAULT NULL,
  `historyBloodTransfusion` tinyint(1) DEFAULT NULL,
  `historySmoking` tinyint(1) DEFAULT NULL,
  `historyDrinking` tinyint(1) DEFAULT NULL,
  `historyNone` tinyint(1) DEFAULT NULL,
  `questionnaireNote` varchar(300) DEFAULT NULL,
  `partnerFirstname` varchar(70) DEFAULT NULL,
  `partnerLastname` varchar(70) DEFAULT NULL,
  `partnerAge` int(11) DEFAULT NULL,
  `partnerWork` varchar(70) DEFAULT NULL,
  `partnerEducation` varchar(70) DEFAULT NULL,
  `partnerIncome` int(11) DEFAULT NULL,
  `partnerIncomePeriod` varchar(15) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `patient_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `pregnancy_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pregnancy_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pregnancy_ibfk_3` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10116 DEFAULT CHARSET=latin1
*/

Pregnancy = Bookshelf.Model.extend({
  tableName: 'pregnancy'

  , virtuals: {
      // --------------------------------------------------------
      // Calculate an estimated due date based upon the last
      // menstrual period date. It is always 280 days later.
      // --------------------------------------------------------
      edd: function() {
        var lmp = this.get('lmp');
        if (_.isDate(lmp)) return moment(lmp).add(280, 'days').toDate();
        return '';
      }
      // --------------------------------------------------------
      // Calculate "flags" for pregnancy by finding lines in note
      // field that begin with double asterisks.
      // --------------------------------------------------------
      , flags: function() {
          var flags = [];
          var note = this.get('note');
          if (! note || note.length === 0) return flags;
          _.each(note.match(/\*\*.*$/gm), function(f, idx) {
            flags.push(f.replace(/\*\*/g, ''));
          });
          return flags;
        }
    }

  , permittedAttributes: ['id', 'firstname', 'lastname', 'maidenname', 'nickname',
      'religion', 'maritalStatus', 'telephone', 'work', 'education',
      'clientIncome', 'clientIncomePeriod', 'address1', 'address2', 'address3',
      'address4', 'city', 'state', 'postalCode', 'country', 'gravidaNumber', 'lmp',
      'sureLMP', 'warning', 'riskNote', 'alternateEdd', 'useAlternateEdd',
      'doctorConsultDate', 'dentistConsultDate', 'mbBook', 'whereDeliver',
      'fetuses', 'monozygotic', 'pregnancyEndDate', 'pregnancyEndResult', 'iugr',
      'note', 'numberRequiredTetanus', 'invertedNipples', 'hasUS', 'wantsUS',
      'gravida', 'stillBirths', 'abortions', 'living', 'para', 'term', 'preterm',
      'philHealthMCP', 'philHealthNCP', 'philHealthID', 'philHealthApproved',
      'currentlyVomiting', 'currentlyDizzy', 'currentlyFainting',
      'currentlyBleeding', 'currentlyUrinationPain', 'currentlyBlurryVision',
      'currentlySwelling', 'currentlyVaginalPain', 'currentlyVaginalItching',
      'currentlyNone', 'useIodizedSalt', 'takingMedication', 'planToBreastFeed',
      'birthCompanion', 'practiceFamilyPlanning', 'practiceFamilyPlanningDetails',
      'familyHistoryTwins', 'familyHistoryHighBloodPressure',
      'familyHistoryDiabetes', 'familyHistoryHeartProblems', 'familyHistoryTB',
      'familyHistorySmoking', 'familyHistoryNone', 'historyFoodAllergy',
      'historyMedicineAllergy', 'historyAsthma', 'historyHeartProblems',
      'historyKidneyProblems', 'historyHepatitis', 'historyGoiter',
      'historyHighBloodPressure', 'historyHospitalOperation',
      'historyBloodTransfusion', 'historySmoking', 'historyDrinking', 'historyNone',
      'questionnaireNote', 'partnerFirstname', 'partnerLastname', 'partnerAge',
      'partnerWork', 'partnerEducation', 'partnerIncome', 'partnerIncomePeriod',
      'updatedBy', 'updatedAt', 'supervisor', 'patient_id']

  , initialize: function() {
    this.on('saving', this.saving, this);
    }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------

  , patient: function() {
      return this.belongsTo(require('./Patient').Patient, 'patient_id');
    }

  , pregnancyHistory: function() {
      return this.hasMany(require('./PregnancyHistory').PregnancyHistory, 'pregnancy_id');
    }

  , prenatalExam: function() {
      return this.hasMany(require('./PrenatalExam').PrenatalExam, 'pregnancy_id');
    }

  , labTestResult: function() {
      return this.hasMany(require('./LabTestResult').LabTestResult, 'labTest_id');
    }

  , vaccination: function() {
      return this.hasMany(require('./Vaccination').Vaccination, 'pregnancy_id');
    }

  , schedule: function() {
      return this.hasMany(require('./Schedule').Schedule, 'pregnancy_id');
    }

  , priority: function() {
      return this.hasMany(require('./Priority').Priority, 'pregnancy_id');
    }

  , risk: function() {
      return this.hasMany(require('./Risk').Risk, 'pregnancy_id');
    }

  , customField: function() {
      return this.hasMany(require('./CustomField').CustomField, 'pregnancy_id');
    }

  , teaching: function() {
      return this.hasMany(require('./Teaching').Teaching, 'pregnancy_id');
    }

  , medication: function() {
      return this.hasMany(require('./Medication').Medication, 'pregnancy_id');
    }

  , referral: function() {
      return this.hasMany(require('./Referral').Referral, 'pregnancy_id');
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
   * return      promise
   * -------------------------------------------------------- */
  checkFields: function(flds) {
    return new Promise(function(resolve, reject) {
      var msgs = []
        ;
      if (! val.isLength(flds.firstname, 1)) msgs.push('Firstname must be specified.');
      if (! val.isLength(flds.lastname, 1)) msgs.push('Lastname must be specified.');

      if (msgs.length !== 0) {
        reject(msgs.join(' '));
      } else {
        resolve(flds);
      }
    });
  }

    /* --------------------------------------------------------
     * checkMidwifeInterviewFields()
     *
     * Check the validity of the passed fields and return a
     * promise whether they are sufficient or not.
     *
     * param      flds - object containing field keys and values
     * return     promise
     * -------------------------------------------------------- */
  , checkMidwifeInterviewFields: function(flds) {
      return new Promise(function(resolve, reject) {
        var msgs = []
          ;
        if (flds.invertedNipples == '0' &&
            flds.hasUS == '0' &&
            flds.wantsUS == '0' &&
            flds.noneOfAbove == '0') msgs.push('Choose at least one checkbox.');

        if (msgs.length !== 0) {
          reject(msgs.join(' '));
        } else {
          resolve(flds);
        }
      });
    }


});

Pregnancies = Bookshelf.Collection.extend({
  model: Pregnancy
});

module.exports = {
  Pregnancy: Pregnancy
  , Pregnancies: Pregnancies
};

