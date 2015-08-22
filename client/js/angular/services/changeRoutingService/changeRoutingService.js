;(function(angular) {

  'use strict';

  angular.module('changeRoutingServiceModule', [])
    .factory('changeRoutingService', [
      '$cacheFactory',
      function($cacheFactory) {

      // --------------------------------------------------------
      // Mapping between changed fields in a certain table and
      // the UI-Router state in which that change should be
      // displayed.
      //
      // NOTE: customField below works as long as there is only
      // one customField or as long as all customFields are
      // situated on the pregnancy.general page. Otherwise, this
      // needs to be refactored.
      // --------------------------------------------------------
      var fieldStateMap = {
        'pregnote': {
          'DEFAULT': 'pregnancy.labs'
        },
        'customField': {
          'DEFAULT': 'pregnancy.general'
        },
        'healthTeaching': {
          'DEFAULT': 'pregnancy.labs'
        },
        'labTestResult': {
          'DEFAULT': 'pregnancy.labs'
        },
        'medication': {
          'DEFAULT': 'pregnancy.labs'
        },
        'prenatalExam': {
          'DEFAULT': 'pregnancy.prenatalExam'
        },
        'referral': {
          'DEFAULT': 'pregnancy.labs'
        },
        'risk': {
          'DEFAULT': 'pregnancy.prenatal'
        },
        'schedule': {
          'DEFAULT': 'pregnancy.general'
        },
        'vaccination': {
          'DEFAULT': 'pregnancy.labs'
        },
        'patient': {
          'ageOfMenarche': 'pregnancy.midwife',
          'DEFAULT': 'pregnancy.general'
        },
        'pregnancy': {
          'firstname': 'pregnancy.general',
          'lastname': 'pregnancy.general',
          'maidenname': 'pregnancy.general',
          'nickname': 'pregnancy.general',
          'religion': 'pregnancy.general',
          'maritalStatus': 'pregnancy.general',
          'telephone': 'pregnancy.general',
          'work': 'pregnancy.general',
          'education': 'pregnancy.general',
          'clientIncome': 'pregnancy.general',
          'clientIncomePeriod': 'pregnancy.general',
          'address1': 'pregnancy.general',
          'address2': 'pregnancy.general',
          'address3': 'pregnancy.general',
          'address4': 'pregnancy.general',
          'city': 'pregnancy.general',
          'state': 'pregnancy.general',
          'postalCode': 'pregnancy.general',
          'country': 'pregnancy.general',
          'gravidaNumber': 'pregnancy.prenatal',
          'lmp': 'pregnancy.prenatal',
          'sureLMP': 'pregnancy.prenatal',
          'warning': 'pregnancy.prenatal',              // ???
          'riskNote': 'pregnancy.prenatal',
          'alternateEdd': 'pregnancy.prenatal',
          'useAlternateEdd': 'pregnancy.prenatal',
          'doctorConsultDate': 'pregnancy.labs',
          'dentistConsultDate': 'pregnancy.labs',
          'mbBook': 'pregnancy.general',
          'whereDeliver': 'pregnancy.midwife',
          'fetuses': 'pregnancy.midwife',               // ???
          'monozygotic': 'pregnancy.midwife',           // ???
          'pregnancyEndDate': 'pregnancy.prenatal',
          'pregnancyEndResult': 'pregnancy.prenatal',
          'iugr': 'pregnancy.prenatal',                 // ???
          'note': 'pregnancy.midwife',
          'numberRequiredTetanus': 'pregnancy.labs',
          'invertedNipples': 'pregnancy.midwife',
          'hasUS': 'pregnancy.midwife',
          'wantsUS': 'pregnancy.midwife',
          'gravida': 'pregnancy.midwife',
          'stillBirths': 'pregnancy.midwife',
          'abortions': 'pregnancy.midwife',
          'living': 'pregnancy.midwife',
          'para': 'pregnancy.midwife',
          'term': 'pregnancy.midwife',
          'preterm': 'pregnancy.midwife',
          'philHealthMCP': 'pregnancy.prenatal',
          'philHealthNCP': 'pregnancy.prenatal',
          'philHealthID': 'pregnancy.prenatal',
          'philHealthApproved': 'pregnancy.prenatal',
          'transferOfCare': 'pregnancy.prenatal',
          'transferOfCareNote': 'pregnancy.prenatal',
          'currentlyVomiting': 'pregnancy.questionnaire',
          'currentlyDizzy': 'pregnancy.questionnaire',
          'currentlyFainting': 'pregnancy.questionnaire',
          'currentlyBleeding': 'pregnancy.questionnaire',
          'currentlyUrinationPain': 'pregnancy.questionnaire',
          'currentlyBlurryVision': 'pregnancy.questionnaire',
          'currentlySwelling': 'pregnancy.questionnaire',
          'currentlyVaginalPain': 'pregnancy.questionnaire',
          'currentlyVaginalItching': 'pregnancy.questionnaire',
          'currentlyNone': 'pregnancy.questionnaire',
          'useIodizedSalt': 'pregnancy.questionnaire',
          'takingMedication': 'pregnancy.questionnaire',
          'planToBreastFeed': 'pregnancy.questionnaire',
          'birthCompanion': 'pregnancy.questionnaire',
          'practiceFamilyPlanning': 'pregnancy.questionnaire',
          'practiceFamilyPlanningDetails': 'pregnancy.questionnaire',
          'familyHistoryTwins': 'pregnancy.questionnaire',
          'familyHistoryHighBloodPressure': 'pregnancy.questionnaire',
          'familyHistoryDiabetes': 'pregnancy.questionnaire',
          'familyHistoryHeartProblems': 'pregnancy.questionnaire',
          'familyHistoryTB': 'pregnancy.questionnaire',
          'familyHistorySmoking': 'pregnancy.questionnaire',
          'familyHistoryNone': 'pregnancy.questionnaire',
          'historyFoodAllergy': 'pregnancy.questionnaire',
          'historyMedicineAllergy': 'pregnancy.questionnaire',
          'historyAsthma': 'pregnancy.questionnaire',
          'historyHeartProblems': 'pregnancy.questionnaire',
          'historyKidneyProblems': 'pregnancy.questionnaire',
          'historyHepatitis': 'pregnancy.questionnaire',
          'historyGoiter': 'pregnancy.questionnaire',
          'historyHighBloodPressure': 'pregnancy.questionnaire',
          'historyHospitalOperation': 'pregnancy.questionnaire',
          'historyBloodTransfusion': 'pregnancy.questionnaire',
          'historySmoking': 'pregnancy.questionnaire',
          'historyDrinking': 'pregnancy.questionnaire',
          'historyNone': 'pregnancy.questionnaire',
          'questionnaireNote': 'pregnancy.questionnaire',
          'partnerFirstname': 'pregnancy.general',
          'partnerLastname': 'pregnancy.general',
          'partnerAge': 'pregnancy.general',
          'partnerWork': 'pregnancy.general',
          'partnerEducation': 'pregnancy.general',
          'partnerIncome': 'pregnancy.general',
          'partnerIncomePeriod': 'pregnancy.general',
          'DEFAULT': 'pregnancy.general'
        }
      };

      var stateSourceMap = {
        'pregnancy.prenatal': 'pregnancy',
        'pregnancy.labs': 'pregnancy',
        'pregnancy.questionnaire': 'pregnancy',
        'pregnancy.midwife': 'pregnancy',
        'pregnancy.general': 'pregnancy',
        'pregnancy.prenatalExam': 'prenatalExam'
      };

      /* --------------------------------------------------------
       * getState()
       *
       * Return the UI-Router state used to display the change
       * represented by the changed object passed, which consists
       * of the table(s) and fields changed in a particular record.
       *
       * param       changes
       * return      state
       * -------------------------------------------------------- */
      var getState = function(changes) {
        var changed = {};
        var state;
        var defaultState = 'pregnancy.general';

        // Eliminate data sources with no changes.
        _.each(changes, function(val, key) {
          if (val && _.size(val) > 0) {
            changed[key] = val;
          }
        });

        // --------------------------------------------------------
        // Find the first match by field, skip the rest.
        // --------------------------------------------------------
        _.each(changed, function(records, table) {
          _.each(records, function(recObj, recId) {
            if (! state && fieldStateMap[table]) {
              _.each(recObj.fields, function(f) {
                if (! state && fieldStateMap[table][f]) {
                  state = fieldStateMap[table][f];
                }
              });
              // If field not found for this table, check for default
              // for the table.
              if (! state && fieldStateMap[table]['DEFAULT']) {
                state = fieldStateMap[table]['DEFAULT'];
              }
            }
          });
        });

        // --------------------------------------------------------
        // No match! Log the same and return the default state.
        // --------------------------------------------------------
        if (! state) {
          console.log('Warning: no state found for following changelog.');
          console.dir(changes);
        }
        return state || defaultState;
      };


      /* --------------------------------------------------------
       * getSource()
       *
       * Return the data source that matches the UI-Router state
       * passed. This can be used by the caller to determine which
       * change records pertain to a specific state.
       *
       * param       state
       * return      Fields object
       * -------------------------------------------------------- */
      var getSource = function(state) {
        return stateSourceMap[state] || '';
      };

      return {
        getState: getState,
        getSource: getSource
      };
    }]);

})(angular);
