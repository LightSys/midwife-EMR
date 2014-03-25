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
  `monthlyIncome` int(11) DEFAULT NULL,
  `address` varchar(150) NOT NULL,
  `barangay` varchar(50) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `postalCode` varchar(20) DEFAULT NULL,
  `gravidaNumber` tinyint(4) DEFAULT NULL,
  `lmp` date DEFAULT NULL,
  `warning` tinyint(1) DEFAULT '0',
  `edd` date DEFAULT NULL,
  `alternateEdd` date DEFAULT NULL,
  `useAlternateEdd` tinyint(1) DEFAULT '0',
  `doctorConsultDate` date DEFAULT NULL,
  `dentistConsultDate` date DEFAULT NULL,
  `mbBook` tinyint(1) DEFAULT NULL,
  `iodizedSalt` tinyint(1) DEFAULT NULL,
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
  `currentlyBirthCanalPain` tinyint(1) DEFAULT NULL,
  `currentlyNone` tinyint(1) DEFAULT NULL,
  `useIodizedSalt` tinyint(1) DEFAULT NULL,
  `canDrinkMedicine` tinyint(1) DEFAULT NULL,
  `planToBreastFeed` tinyint(1) DEFAULT NULL,
  `birthCompanion` varchar(30) DEFAULT NULL,
  `practiceFamilyPlanning` tinyint(1) DEFAULT NULL,
  `familyPlanningDetails` varchar(100) DEFAULT NULL,
  `familyHistoryTwins` tinyint(1) DEFAULT NULL,
  `familyHistoryHighBloodPressure` tinyint(1) DEFAULT NULL,
  `familyHistoryDiabetes` tinyint(1) DEFAULT NULL,
  `familyHistoryChestPains` tinyint(1) DEFAULT NULL,
  `familyHistoryTB` tinyint(1) DEFAULT NULL,
  `familyHistorySmoking` tinyint(1) DEFAULT NULL,
  `familyHistoryNone` tinyint(1) DEFAULT NULL,
  `historyFoodAllergy` tinyint(1) DEFAULT NULL,
  `historyMedicineAllergy` tinyint(1) DEFAULT NULL,
  `historyAsthma` tinyint(1) DEFAULT NULL,
  `historyChestPains` tinyint(1) DEFAULT NULL,
  `historyKidneyProblems` tinyint(1) DEFAULT NULL,
  `historyHepatitis` tinyint(1) DEFAULT NULL,
  `historyGoiter` tinyint(1) DEFAULT NULL,
  `historyHighBloodPressure` tinyint(1) DEFAULT NULL,
  `historyHospitalOperation` tinyint(1) DEFAULT NULL,
  `historyBloodTransfusion` tinyint(1) DEFAULT NULL,
  `historySmoking` tinyint(1) DEFAULT NULL,
  `historyDrinking` tinyint(1) DEFAULT NULL,
  `historyNone` tinyint(1) DEFAULT NULL,
  `partnerFirstname` varchar(70) DEFAULT NULL,
  `partnerLastname` varchar(70) DEFAULT NULL,
  `partnerAge` int(11) DEFAULT NULL,
  `partnerWork` varchar(70) DEFAULT NULL,
  `partnerEducation` varchar(70) DEFAULT NULL,
  `partnerMonthlyIncome` int(11) DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
*/

Pregnancy = Bookshelf.Model.extend({
  tableName: 'pregnancy'

  , permittedAttributes: ['id', 'firstname', 'lastname', 'maidenname', 'nickname',
      'religion', 'maritalStatus', 'telephone', 'work', 'education',
      'monthlyIncome', 'address', 'barangay', 'city', 'postalCode',
      'gravidaNumber', 'lmp', 'warning', 'edd', 'alternateEdd', 'useAlternateEdd',
      'doctorConsultDate', 'dentistConsultDate', 'mbBook', 'iodizedSalt',
      'whereDeliver', 'fetuses', 'monozygotic', 'pregnancyEndDate',
      'pregnancyEndResult', 'iugr', 'note', 'numberRequiredTetanus',
      'invertedNipples', 'hasUS', 'wantsUS', 'gravida', 'stillBirths',
      'abortions', 'living', 'para', 'term', 'preterm', 'philHealthMCP',
      'philHealthNCP', 'philHealthID', 'philHealthApproved', 'currentlyVomiting',
      'currentlyDizzy', 'currentlyFainting', 'currentlyBleeding',
      'currentlyUrinationPain', 'currentlyBlurryVision', 'currentlySwelling',
      'currentlyBirthCanalPain', 'currentlyNone', 'useIodizedSalt',
      'canDrinkMedicine', 'planToBreastFeed', 'birthCompanion',
      'practiceFamilyPlanning', 'familyPlanningDetails', 'familyHistoryTwins',
      'familyHistoryHighBloodPressure', 'familyHistoryDiabetes',
      'familyHistoryChestPains', 'familyHistoryTB', 'familyHistorySmoking',
      'familyHistoryNone', 'historyFoodAllergy', 'historyMedicineAllergy',
      'historyAsthma', 'historyChestPains', 'historyKidneyProblems',
      'historyHepatitis', 'historyGoiter', 'historyHighBloodPressure',
      'historyHospitalOperation', 'historyBloodTransfusion', 'historySmoking',
      'historyDrinking', 'historyNone', 'partnerFirstname', 'partnerLastname',
      'partnerAge', 'partnerWork', 'partnerEducation', 'partnerMonthlyIncome',
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
      if (! val.isLength(flds.firstname, 1)) msgs.push('Firstname must be specified.');
      if (! val.isLength(flds.lastname, 1)) msgs.push('Lastname must be specified.');

      if (msgs.length != 0) {
        reject(msgs.join(' '));
      } else {
        resolve(flds);
      }
    });
  }

  , checkMidwifeInterviewFields: function(flds) {
      return new Promise(function(resolve, reject) {
        var msgs = []
          ;
        if (flds.invertedNipples == '0' &&
            flds.hasUS == '0' &&
            flds.wantsUS == '0' &&
            flds.noneOfAbove == '0') msgs.push('Choose at least one checkbox.');

        if (msgs.length != 0) {
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

