;(function(angular) {

  'use strict';

  angular.module('changeRoutingServiceModule', [])
    .factory('changeRoutingService', [
      'loggingService',
      function(log) {

        var DETAIL_ID_KEY_FIELD = 'detIdKey';
        var DETAIL_ID_VAL_FIELD = 'detIdVal';

        // --------------------------------------------------------
        // Mapping between changed fields in a certain table and
        // the UI-Router state in which that change should be
        // displayed.
        //
        // NOTE: customField below works as long as there is only
        // one customField or as long as all customFields are
        // situated on the pregnancy.general page. Otherwise, this
        // needs to be refactored.
        //
        // NOTE2: only use DEFAULT when all of the fields of the
        // table are mapped to the same state. If only some of the
        // fields are mapped to the same state, each field must be
        // specifically listed and DEFAULT should not be used because
        // it will cause the historyService.findBySourceInfo()
        // method to incorrectly select a change record.
        // --------------------------------------------------------
        var fieldStateMap = {
          'pregnancyHistory': {
            'DEFAULT': 'pregnancy.pregnancyHistory',
            'STATE_DETAIL_ID_NAME': 'phid'
          },
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
            'DEFAULT': 'pregnancy.prenatalExam',
            'STATE_DETAIL_ID_NAME': 'peid'
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
            'dohID': 'pregnancy.general',
            'dob': 'pregnancy.general',
            'generalInfo': 'pregnancy.general'
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
            'gravidaNumber': 'pregnancy.midwife',        // field is not actually used.
            'lmp': 'pregnancy.prenatal',
            'sureLMP': 'pregnancy.prenatal',
            'warning': 'pregnancy.prenatal',              // ???
            'riskNote': 'pregnancy.prenatal',
            'alternateEdd': 'pregnancy.prenatal',
            'useAlternateEdd': 'pregnancy.prenatal',
            'doctorConsultDate': 'pregnancy.labs',
            'dentistConsultDate': 'pregnancy.labs',
            'mbBook': 'pregnancy.general',
            'whereDeliver': 'pregnancy.questionnaire',
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
            'partnerIncomePeriod': 'pregnancy.general'
          }
        };

        // --------------------------------------------------------
        // Generate the inverse of the fieldStateMap for lookups from
        // state to source/fields.
        //
        // E.g.
        // {
        //   'pregnancy.general': {
        //     'pregnancy': ['firstname','lastname', ...],
        //     'patient': ['dohID','dob']
        //     ...
        //   },
        //   'pregnancy.labs': {
        //     'pregnancy': ['doctorConsultDate', ...],
        //     'labTestResult': ['DEFAULT'],
        //     ...
        //   },
        // }
        // --------------------------------------------------------
        var stateSourceFieldMap = (function() {
          var result = {};
          _.each(_.keys(fieldStateMap), function(source) {
            var obj = fieldStateMap[source];
            _.each(_.keys(obj), function(fld) {
              var state = obj[fld];
              if (! _.has(result, state)) result[state] = {};
              if (! _.has(result[state], source)) result[state][source] = [];
              if (fld) result[state][source].push(fld);
            });
          });
          return result;
        })();

        // --------------------------------------------------------
        // TODO: retire this.
        // --------------------------------------------------------
        var stateSourceMap = {
          'pregnancy.prenatal': 'pregnancy',
          'pregnancy.labs': 'pregnancy',
          'pregnancy.questionnaire': 'pregnancy',
          'pregnancy.midwife': 'pregnancy',
          'pregnancy.general': 'pregnancy',
          'pregnancy.prenatalExam': 'prenatalExam',
          'pregnancy.pregnancyHistory': 'pregnancyHistory'
        };

        /* --------------------------------------------------------
        * getState()
        *
        * Return the UI-Router state used to display the change
        * represented by the changed object passed, which consists
        * of the table(s) and fields changed in a particular record.
        *
        * Returned object has at least one field named state and
        * optionally two other fields named detIdKey and detIdVal.
        *
        * param       changes
        * return      state as an object
        * -------------------------------------------------------- */
        var getState = function(changes) {
          var changed = {};
          var state = {};
          var defaultState = {stateName: 'pregnancy.general'};

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
              if (! state.stateName && fieldStateMap[table]) {
                // --------------------------------------------------------
                // Find the state to use based upon a matching change field.
                // --------------------------------------------------------
                _.each(recObj.fields, function(f) {
                  if (! state.stateName && fieldStateMap[table][f]) {
                    state.stateName = fieldStateMap[table][f];
                  }
                });
                // --------------------------------------------------------
                // If field not found for this table, check for default
                // for the table.
                // --------------------------------------------------------
                if (! state.stateName && fieldStateMap[table]['DEFAULT']) {
                  state.stateName = fieldStateMap[table]['DEFAULT'];
                }
                // --------------------------------------------------------
                // Finally, if there is suposed to be a detail id passed
                // with the state, include it here.
                // --------------------------------------------------------
                if (fieldStateMap[table].STATE_DETAIL_ID_NAME) {
                  state.detIdKey = fieldStateMap[table].STATE_DETAIL_ID_NAME;
                  state.detIdVal = recId;
                }
              }
            });
          });

          // --------------------------------------------------------
          // No match! Log the same and return the default state.
          // --------------------------------------------------------
          if (! state.stateName) {
            log.log('Warning: no state found for following changelog.');
            log.dir(changes);
          }
          return state || defaultState;
        };

        /* --------------------------------------------------------
         * getStateDetKey()
         *
         * Returns the detail key field name from the state object
         * returned by the getState() method.
         *
         * param       stateObj as returned by getState().
         * return      field name
         * -------------------------------------------------------- */
        var getStateDetKey = function(stateObj) {
          return stateObj[DETAIL_ID_KEY_FIELD] || '';
        };

        /* --------------------------------------------------------
         * getStateDetVal()
         *
         * Returns the detail key field value from the state object
         * returned by the getState() method.
         *
         * param       stateObj as returned by getState()
         * return      field value
         * -------------------------------------------------------- */
        var getStateDetVal = function(stateObj) {
          return stateObj[DETAIL_ID_VAL_FIELD] || '';
        };

        /* --------------------------------------------------------
         * getSourceFieldInfo()
         *
         * Return a map of tables and fields that are associated
         * with the state passed.
         *
         * param       state
         * return      result
         * -------------------------------------------------------- */
        var getSourceFieldInfo = function(state) {
          var result = stateSourceFieldMap[state] || {};
          return result;
        };

        return {
          getState: getState,
          getSourceFieldInfo: getSourceFieldInfo,
          getStateDetKey: getStateDetKey,
          getStateDetVal: getStateDetVal
        };
      }
    ]);

})(angular);
