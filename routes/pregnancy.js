/*
 * -------------------------------------------------------------------------------
 * pregnancy.js
 *
 * Functionality for management of pregnancies.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , Promise = require('bluebird')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , cfg = require('../config')
  , hasRole = require('../auth').hasRole
  , Patient = require('../models').Patient
  , Patients = require('../models').Patients
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , PregnancyHistory = require('../models').PregnancyHistory
  , PregnancyHistories = require('../models').PregnancyHistories
  , PrenatalExam = require('../models').PrenatalExam
  , PrenatalExams = require('../models').PrenatalExams
  , User = require('../models').User
  , Users = require('../models').Users
  , SelectData = require('../models').SelectData
  , LabSuite = require('../models').LabSuite
  , LabSuites = require('../models').LabSuites
  , LabTest = require('../models').LabTest
  , LabTests = require('../models').LabTests
  , LabTestResult = require('../models').LabTestResult
  , LabTestResults = require('../models').LabTestResults
  , Referral = require('../models').Referral
  , Referrals = require('../models').Referrals
  , Vaccination = require('../models').Vaccination
  , Vaccinations = require('../models').Vaccinations
  , Medication = require('../models').Medication
  , Medications = require('../models').Medications
  , Event = require('../models').Event
  , Schedule = require('../models').Schedule
  , Schedules = require('../models').Schedules
  , Priority = require('../models').Priority
  , Priorities = require('../models').Priorities
  , CustomField = require('../models').CustomField
  , CustomFields = require('../models').CustomFields
  , CustomFieldType = require('../models').CustomFieldType
  , CustomFieldTypes = require('../models').CustomFieldTypes
  , RoFieldsByRole = require('../models').RoFieldsByRole
  , Teaching = require('../models').Teaching
  , Teachings = require('../models').Teachings
  , Pregnote = require('../models').Pregnote
  , Pregnotes = require('../models').Pregnotes
  , PregnoteType = require('../models').PregnoteType
  , PregnoteTypes = require('../models').PregnoteTypes
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , getGA = require('../util').getGA
  , getAbbr = require('../util').getAbbr
  , calcEdd = require('../util').calcEdd
  , adjustSelectData = require('../util').adjustSelectData
  , addBlankSelectData = require('../util').addBlankSelectData
  , maritalStatus = []
  , religion = []
  , education = []
  , edema = []
  , incomePeriod = []
  , yesNoUnanswered = []
  , yesNoUnknown = []
  , episTear = []
  , attendant = []
  , wksMthsYrs = []
  , wksMths = []
  , maleFemale = []
  , location = []
  , dayOfWeek = []
  , placeOfBirth = []
  , referralsDatalist = []  // Used within a datalist mixin rather than selectData.
  , teachingDatalist = []   // datalist too
  , prenatalCheckInId
  , prenatalCheckOutId
  , riskCodes = {}
  , customFieldTypes   // Not associated with select data but custom fields.
  , pregnoteTypes          // Custom fields
  ;

/* --------------------------------------------------------
 * init()
 *
 * Initialize the module.
 * -------------------------------------------------------- */
var init = function() {
  var refresh
    , doRefresh
    , maritalName = 'maritalStatus'
    , religionName = 'religion'
    , educationName = 'education'
    , edemaName = 'edema'
    , incomePeriodName = 'incomePeriod'
    , yesNoUnansweredName = 'yesNoUnanswered'
    , yesNoUnknownName = 'yesNoUnknown'
    , episTearName = 'episTear'
    , attendantName = 'attendant'
    , wksMthsYrsName = 'wksMthsYrs'
    , wksMthsName = 'wksMths'
    , maleFemaleName = 'maleFemale'
    , locationName = 'location'
    , dayOfWeekName = 'dayOfWeek'
    , placeOfBirthName = 'placeOfBirth'
    , referralsDatalistName = 'referrals'
    , teachingDatalistName = 'teachingTopics'
    , interval = cfg.data.selectRefreshInterval
  ;

  // --------------------------------------------------------
  // Refresh dataset passed.
  // --------------------------------------------------------
  refresh = function(dataName) {
    return new Promise(function(resolve, reject) {
      SelectData.getSelect(dataName)
        .then(function(list) {
          resolve(list);
        })
        .caught(function(err) {
          err.status = 500;
          reject(err);
        });
    });
  };

  // --------------------------------------------------------
  // Do an initial refresh and at a set interval afterward.
  // --------------------------------------------------------
  doRefresh = function(dataName, fn) {
    refresh(dataName).then(function(list) {
      fn(list);
    });
    // Turned off interval refresh for now because there are not yet any
    // administrative screeens to update these lists in real-time.
    //setInterval(function() {
      //refresh(dataName).then(function(list) {
        //fn(list);
      //});
    //}, interval);
  };

  // --------------------------------------------------------
  // Keep the various select lists up to date.
  // --------------------------------------------------------
  doRefresh(maritalName, function(l) {maritalStatus = l;});
  doRefresh(religionName, function(l) {religion = l;});
  doRefresh(educationName, function(l) {education = l;});
  doRefresh(edemaName, function(l) {edema = l;});
  doRefresh(incomePeriodName, function(l) {incomePeriod = l;});
  doRefresh(yesNoUnansweredName, function(l) {yesNoUnanswered = l;});
  doRefresh(yesNoUnknownName, function(l) {yesNoUnknown = l;});
  doRefresh(episTearName, function(l) {episTear = l;});
  doRefresh(attendantName, function(l) {attendant = l;});
  doRefresh(wksMthsYrsName, function(l) {wksMthsYrs = l;});
  doRefresh(wksMthsName, function(l) {wksMths = l;});
  doRefresh(maleFemaleName, function(l) {maleFemale = l;});
  doRefresh(locationName, function(l) {location = l;});
  doRefresh(dayOfWeekName, function(l) {dayOfWeek = l;});
  doRefresh(placeOfBirthName, function(l) {placeOfBirth = l;});
  doRefresh(referralsDatalistName, function(l) {referralsDatalist = l;});
  doRefresh(teachingDatalistName, function(l) {teachingDatalist = l;});

  // --------------------------------------------------------
  // Do a one time load of custom field types.
  // --------------------------------------------------------
  new CustomFieldTypes()
    .fetch()
    .then(function(list) {
      customFieldTypes = list.toJSON();
    });

  // --------------------------------------------------------
  // Do a one time load of EventType ids.
  // --------------------------------------------------------
  new EventTypes()
    .fetch()
    .then(function(list) {
      prenatalCheckInId = list.findWhere({name: 'prenatalCheckIn'}).get('id');
      prenatalCheckOutId = list.findWhere({name: 'prenatalCheckOut'}).get('id');
    });

  // --------------------------------------------------------
  // Do a one time load of risk codes.
  // --------------------------------------------------------
  new RiskCodes()
    .fetch()
    .then(function(list) {
      riskCodes = list.toJSON();
    });

  // --------------------------------------------------------
  // Do a one time load of note types.
  // --------------------------------------------------------
  new PregnoteTypes()
    .fetch()
    .then(function(list) {
      pregnoteTypes = list.toJSON();
    });
};

/* --------------------------------------------------------
 * load()
 *
 * Loads the pregnancy record from the database based upon the id
 * as specified in the path. Places the pregnancy record in the
 * request as paramPregnancy and the pregnancy id in the
 * session as currentPregnancyId.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var load = function(req, res, next) {
  var id = req.params.id
    , id2 = parseInt(req.params.id2, 10)
    , op = req.params.op
    , op2 = req.params.op2
    , rec
    , formatTime = function(val) {
        var d
          , formatted
          ;
        if (val === null) return '';
        if (val === '00:00') return '';
        if (_.isDate(val)) {
          d = moment(val);
        } else if (typeof val === 'string' && /..:../.test(val)) {
          d = moment(val, 'HH:mm');
        } else {
          return '';
        }
        if (! d.isValid()) return '';
        return d.format('HH:mm');
      }
    , formatDate = function(val) {
        var d
          , formatted
          ;
        if (val === null) return '';
        if (val === '0000-00-00') return '';
        if (_.isDate(val)) {
          d = moment(val);
        } else if (typeof val === 'string' && /....-..-../.test(val)) {
          d = moment(val, 'YYYY-MM-DD');
        } else {
          return '';
        }
        if (! d.isValid()) return '';
        return d.format('YYYY-MM-DD');
      }
    , fetchObject = {withRelated: [
        'patient'
        , 'priority'
        , 'schedule'
        , 'customField']
      }
    ;

  // --------------------------------------------------------
  // If the url is 'pregnancy/new', we don't have anything to load.
  // --------------------------------------------------------
  if (id === 'new') return next();

  // --------------------------------------------------------
  // Add tables to fetch depending upon the URL.
  // --------------------------------------------------------
  if (op === 'midwifeinterview' || op === 'preghistory') {
    fetchObject.withRelated.push('pregnancyHistory');
    fetchObject.withRelated.push({pregnancyHistory: function(qb) {
        qb.orderBy('year', 'asc');
        qb.orderBy('month', 'asc');
      }
    });
  }
  if (op === 'prenatal' || op === 'prenatalexam') {
    fetchObject.withRelated.push('risk');
    fetchObject.withRelated.push('prenatalExam');
    fetchObject.withRelated.push({prenatalExam: function(qb) {
        qb.orderBy('date', 'asc');
      }
    });
  }
  // --------------------------------------------------------
  // Fetches progress notes here instead of in labsForm()
  // for in the case where progress notes are accessed from
  // more than one screen.
  // --------------------------------------------------------
  if (op === 'labs') {
    fetchObject.withRelated.push('pregnote');
    fetchObject.withRelated.push({pregnote: function(qb) {
        qb.where('pregnote.pregnoteType', '=', _.findWhere(pregnoteTypes, {name: 'prenatalProgress'}).id);
        qb.orderBy('noteDate', 'asc');
      }
    });
  }

  User.getUserIdMap().then(function(userMap) {
    Pregnancy.forge({id: id})
      .fetch(fetchObject)
      .then(function(pregRec) {
        rec = pregRec.toJSON();
      })
      .then(function() {
        var knex = Bookshelf.DB.knex
          , sql
          ;
        // --------------------------------------------------------
        // Retrieve the prenatalExamLog data if needed.
        // --------------------------------------------------------
        if (op === 'prenatal') {
          sql =  'SELECT * FROM prenatalExamLog WHERE pregnancy_id = ? ';
          sql += 'ORDER BY id, replacedAt';
          return knex.raw(sql, id);
        } else {return void 0;}
      })
      .then(function(data) {
        rec.prenatalExamLog = [];
        if (data && data[0] && data[0].length > 0) {
          rec.prenatalExamLog = data[0];
        }
      })
      .then(function() {
        // --------------------------------------------------------
        // Set only the required information for risk.
        // --------------------------------------------------------
        rec.risk = _.map(rec.risk, function(risk) {
          return _.omit(risk, 'pregnancy_id', 'updatedBy', 'updatedAt', 'supervisor');
        });

        // --------------------------------------------------------
        // Fix the dates for the screen in the format that the
        // input[type='date'] expects.
        // --------------------------------------------------------
        rec.patient.dob = formatDate(rec.patient.dob);
        rec.lmp = formatDate(rec.lmp);
        rec.edd = formatDate(rec.edd);
        rec.alternateEdd = formatDate(rec.alternateEdd);
        rec.pregnancyEndDate = formatDate(rec.pregnancyEndDate);
        rec.dentistConsultDate = formatDate(rec.dentistConsultDate);
        rec.doctorConsultDate = formatDate(rec.doctorConsultDate);

        // --------------------------------------------------------
        // transferOfCareTime is a psuedo field that is stored in
        // the database as a DATETIME in pregnancy.transferOfCare.
        // Populate the transferOfCareTime field for the form.
        // prenatalSave() does the reverse.
        // Note: handle transferOfCareTime first because the
        // source field is changed when the date portion is processed.
        // --------------------------------------------------------
        rec.transferOfCareTime = formatTime(rec.transferOfCare);
        rec.transferOfCare = formatDate(rec.transferOfCare);

        // --------------------------------------------------------
        // Calculate the gestational age at this point or at the
        // point of delivery.
        // --------------------------------------------------------
        if (rec.edd || rec.alternateEdd) {
          // Favor the alternateEdd if the useAlternateEdd is specified.
          if (rec.useAlternateEdd && rec.alternateEdd) {
            rec.ga = getGA(rec.alternateEdd, rec.pregnancyEndDate || moment());
          } else {
            rec.ga = getGA(rec.edd || rec.alternateEdd, rec.pregnancyEndDate || moment());
          }
        } else {
          rec.ga = '';
        }

        // --------------------------------------------------------
        // 1) Calculate the gestational age for each prenatal exam.
        // 2) Build a string representing the staff that have modified
        //    each prenatal exam record so this can be displayed.
        // --------------------------------------------------------
        if (rec.prenatalExam) {
          _.each(rec.prenatalExam, function(peRec) {
            var examiners = []
              ;
            // Favor the alternateEdd if the useAlternateEdd is specified.
            if (rec.useAlternateEdd && rec.alternateEdd) {
              peRec.ga = getGA(rec.alternateEdd, moment(peRec.date).format('YYYY-MM-DD'));
            } else if (rec.edd || rec.alternateEdd) {
              peRec.ga = getGA(rec.edd || rec.alternateEdd, moment(peRec.date).format('YYYY-MM-DD'));
            } else {
              peRec.ga = '';
            }

            // Get the examiners and supervisors from the prenatalExamLog data
            // for each prenatal exam.
            _.each(rec.prenatalExamLog, function(pel) {
              var examStr;
              if (pel.id === peRec.id) {
                examStr = userMap[""+pel.updatedBy]['shortName'];
                if (pel.supervisor && pel.supervisor !== null) {
                  examStr += '/' + userMap[""+pel.supervisor]['shortName'];
                }
                examiners.push(examStr);
              }
            });
            peRec.examiner = _.uniq(examiners);
          });
        }

        // --------------------------------------------------------
        // Place the prenatal priority number in an easy to access location.
        // --------------------------------------------------------
        rec.prenatalCheckinPriority = void(0);
        if (_.isArray(rec.priority) && rec.priority.length > 0) {
          rec.prenatalCheckinPriority = _.findWhere(rec.priority, {eType: prenatalCheckInId}).priority;
        }

        // --------------------------------------------------------
        // Provide a means to determine name from user id on labs page.
        // --------------------------------------------------------
        req.paramUserMap = userMap;

        // --------------------------------------------------------
        // Store the pregnancy record in the request and the
        // pregnancy id in the session.
        // --------------------------------------------------------
        if (rec) {
          req.paramPregnancy = rec;
          req.session.currentPregnancyId = rec.id;
        }

        // --------------------------------------------------------
        // Assign detail record in the master-detail relationship
        // to a convenient location on the request object.
        // --------------------------------------------------------
        if (! isNaN(id2)) {
          // --------------------------------------------------------
          // Historical pregnancies.
          // --------------------------------------------------------
          if (op === 'preghistory') {
            req.paramPregHist = _.find(rec.pregnancyHistory, function(r) {
              return r.id === id2;
            });
          }
          // --------------------------------------------------------
          // Prenatal exams.
          // --------------------------------------------------------
          if (op === 'prenatalexam') {
            req.paramPrenatalExam = _.find(rec.prenatalExam, function(p) {
              return p.id === id2;
            });
            if (req.paramPrenatalExam) {
              // Favor the alternateEdd if the useAlternateEdd is specified.
              if (rec.useAlternateEdd && rec.alternateEdd) {
                req.paramPrenatalExam.ga = getGA(rec.alternateEdd, req.paramPrenatalExam.date);
              } else if (rec.edd || rec.alternateEdd) {
                req.paramPrenatalExam.ga = getGA(rec.edd || rec.alternateEdd, req.paramPrenatalExam.date);
              } else {
                req.paramPrenatalExam.ga = '';
              }
            }
          }
          // --------------------------------------------------------
          // Lab tests
          // --------------------------------------------------------
          if (op === 'labtest') {
            req.paramLabTestResultId = id2;
          }
          // --------------------------------------------------------
          // Referrals
          // --------------------------------------------------------
          if (op === 'referral') {
            req.paramReferralId = id2;
          }
          // --------------------------------------------------------
          // Progress notes
          // --------------------------------------------------------
          if (op === 'pregnote') {
            req.paramPregnoteId = id2;
          }
          // --------------------------------------------------------
          // Health Teachings
          // --------------------------------------------------------
          if (op === 'teaching') {
            req.paramTeachingId = id2;
          }
          // --------------------------------------------------------
          // Vaccinations
          // --------------------------------------------------------
          if (op === 'vaccination') {
            req.paramVaccinationId = id2;
          }
          // --------------------------------------------------------
          // Medications
          // --------------------------------------------------------
          if (op === 'medication') {
            req.paramMedicationId = id2;
          }
        }
        next();
      });
  })
  .caught(function(err) {
    logError(err);
  });

};

/* --------------------------------------------------------
 * getCommonFormData()
 *
 * Return the data necessary to populate several of the forms
 * according to the database record.
 * -------------------------------------------------------- */
var getCommonFormData = function(req, addData) {
 var path = req.route.path
   , schRec
   , ed   // edema
   , us   // useIodizedSalt
   , tm   // takingMedication
   , ptbf // planToBreastFeed
   , fg   // finalGAPeriod
   , et   // episTear
   , er   // repaired (referring to the epis)
   , bf   // BFedPeriod
   , tod = 'NSD' // type of delivery - defaults to NSD
   , mf   // male or female
   , at   // attendant
   , rc   // riskCodes
   , pb   // placeOfBirth
   , rf   // referrals datalist
   , ht   // health teaching datalist
   ;

  // --------------------------------------------------------
  // Load select data for the various pages as per the route.
  // --------------------------------------------------------
  if (req.paramPregnancy) {

    // --------------------------------------------------------
    // Store the prenatal scheduling for the client in the record.
    // --------------------------------------------------------
    schRec = _.find(req.paramPregnancy.schedule, function(obj) {
      return obj.scheduleType === 'Prenatal';
    });
    if (schRec) {
      req.paramPregnancy.prenatalSchedule = {
        day: getAbbr(schRec.day)
        , location: schRec.location
      };
    } else {req.paramPregnancy.prenatalSchedule = {};}

    // Prenatal page.
    if (path === cfg.path.pregnancyPrenatalEdit) {
      // Set up the risk codes.
      rc = riskCodes;
    }

    // Add or edit prenatal examinations.
    if (path === cfg.path.pregnancyPrenatalExamAdd) {
      ed = adjustSelectData(edema, void(0));
    }
    if (path === cfg.path.pregnancyPrenatalExamEdit) {
      ed = adjustSelectData(edema, req.paramPrenatalExam.edema);
      if (_.isUndefined(req.paramPrenatalExam.edema)) req.paramPrenatalExam.edema = '';
    }

    // Add or edit referrals from the main lab page.
    if (path === cfg.path.referralAdd || path === cfg.path.referralEdit) {
      // We set this up the same way we do the selectData mixin, though this
      // is using the datalist mixin. The source table is still the selectData
      // table but we only use the selectKey field in the data generated by the
      // adjustSelectdata() method because that is all the datalist mixin needs.
      rf = adjustSelectData(referralsDatalist, '');
    }

    // Add or edit health teachings from the main lab page.
    if (path === cfg.path.teachingAdd || path === cfg.path.teachingEdit) {
      // We set this up the same way we do the selectData mixin, though this
      // is using the datalist mixin. The source table is still the selectData
      // table but we only use the selectKey field in the data generated by the
      // adjustSelectdata() method because that is all the datalist mixin needs.
      ht = adjustSelectData(teachingDatalist, '');
    }

    // Questionnaire page.
    if (path === cfg.path.pregnancyQuesEdit) {
      us = adjustSelectData(yesNoUnanswered, req.paramPregnancy.useIodizedSalt);
      if (_.isUndefined(req.paramPregnancy.useIodizedSalt)) req.paramPregnancy.useIodizedSalt = '';
      tm = adjustSelectData(yesNoUnanswered, req.paramPregnancy.takingMedication);
      if (_.isUndefined(req.paramPregnancy.takingMedication)) req.paramPregnancy.takingMedication = '';
      ptbf = adjustSelectData(yesNoUnanswered, req.paramPregnancy.planToBreastFeed);
      if (_.isUndefined(req.paramPregnancy.planToBreastFeed)) req.paramPregnancy.planToBreastFeed = '';
    }

    // Add or edit pregnancy histories.
    if (path === cfg.path.pregnancyHistoryAdd) {
      fg = adjustSelectData(wksMths, void(0));
      et = adjustSelectData(episTear, void(0));
      er = adjustSelectData(yesNoUnknown, void(0));
      bf = adjustSelectData(wksMthsYrs, void(0));
      mf = adjustSelectData(maleFemale, void(0));
      at = adjustSelectData(attendant, void(0));
      pb = adjustSelectData(placeOfBirth, void(0));
    }
    if (path === cfg.path.pregnancyHistoryEdit) {
      fg = adjustSelectData(wksMths, req.paramPregHist.finalGAPeriod);
      et = adjustSelectData(episTear, req.paramPregHist.episTear);
      er = adjustSelectData(yesNoUnknown, req.paramPregHist.repaired);
      bf = adjustSelectData(wksMthsYrs, req.paramPregHist.howLongBFedPeriod);
      mf = adjustSelectData(maleFemale, req.paramPregHist.sexOfBaby);
      at = adjustSelectData(attendant, req.paramPregHist.attendant);
      pb = adjustSelectData(placeOfBirth, req.paramPregHist.placeOfBirth);
      tod = req.paramPregHist.typeOfDelivery;
    }

  }

  return _.extend(addData, {
    user: req.session.user
    , messages: req.flash()
    , rec: req.paramPregnancy
    , pregHist: req.paramPregHist || void(0)
    , prenatalExam: req.paramPrenatalExam || void(0)
    , edema: ed
    , useIodizedSalt: us
    , takingMedication: tm
    , planToBreastFeed: ptbf
    , finalGAPeriod: fg
    , episTear: et
    , repaired: er
    , howLongBFedPeriod: bf
    , defaultTypeOfDelivery: tod
    , sexOfBaby: mf
    , attendant: at
    , riskCodes: rc
    , placeOfBirth: pb
    , customFields: req.paramPregnancy.customField
    , customFieldTypes: customFieldTypes
    , referralsDatalist: rf
    , teachingDatalist: ht
    , userMap: req.paramUserMap
  });
};

/* --------------------------------------------------------
 * questionaireForm()
 *
 * Display the pregnancy questionnaire form.
 * -------------------------------------------------------- */
var questionaireForm = function(req, res) {
  var data = {title: req.gettext('Pregnancy Questionnaire')};
  if (req.paramPregnancy) {
    res.render('pregnancyQuestionnaire', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * questionaireSave()
 *
 * Update the pregnancy record with the questionnaire data.
 * -------------------------------------------------------- */
var questionaireSave = function(req, res) {
  var supervisor = null
    , pregFlds = {}
    , defaultFlds = {
        currentlyVomiting: '0', currentlyDizzy: '0',
        currentlyFainting: '0', currentlyBleeding: '0',
        currentlyUrinationPain: '0', currentlyBlurryVision: '0',
        currentlySwelling: '0', currentlyVaginalPain: '0',
        currentlyVaginalItching: '0',
        currentlyNone: '0', useIodizedSalt: '',
        whereDeliver: '', birthCompanion: '',
        practiceFamilyPlanning: '0', practiceFamilyPlanningDetails: '',
        familyHistoryTwins: '0', familyHistoryHighBloodPressure: '0',
        familyHistoryDiabetes: '0', familyHistoryHeartProblems: '0',
        familyHistoryTB: '0', familyHistorySmoking: '0',
        familyHistoryNone: '0', historyFoodAllergy: '0',
        historyMedicineAllergy: '0', historyAsthma: '0',
        historyHeartProblems: '0', historyKidneyProblems: '0',
        historyHepatitis: '0', historyGoiter: '0',
        historyHighBloodPressure: '0', historyHospitalOperation: '0',
        historyBloodTransfusion: '0', historySmoking: '0',
        historyDrinking: '0', historyNone: '0'
      }
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.id &&
      req.paramPregnancy.id == req.body.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // Allow 'unchecking' a box by providing a default of off.
    // --------------------------------------------------------
    pregFlds = _.extend(defaultFlds, _.omit(req.body, ['_csrf']));

    // --------------------------------------------------------
    // If none field is checked as well as other fields in each
    // group, turn the none field off because it does not make
    // sense.
    // --------------------------------------------------------
    _.each(_.keys(pregFlds), function(key) {
      if (pregFlds.currentlyNone == '1') {
        if (key.indexOf('currently') == 0 && key != 'currentlyNone') {
          if (pregFlds[key] == '1') pregFlds.currentlyNone = '0';
        }
      }
      if (pregFlds.familyHistoryNone == '1') {
        if (key.indexOf('familyHistory') == 0 && key != 'familyHistoryNone') {
          if (pregFlds[key] == '1') pregFlds.familyHistoryNone = '0';
        }
      }
      if (pregFlds.historyNone == '1') {
        if (key.indexOf('history') == 0 && key != 'historyNone') {
          if (pregFlds[key] == '1') pregFlds.historyNone = '0';
        }
      }
    });

    Pregnancy.forge(pregFlds)
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save().then(function(pregnancy) {
        req.flash('info', req.gettext('Pregnancy was updated.'));
        res.redirect(cfg.path.pregnancyQuesEdit.replace(/:id/, pregnancy.id));
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });
  } else {
    logError('Error in update of pregnancy: pregnancy not found.');
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * generalAddForm()
 *
 * Display the form to create a new pregnancy record.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var generalAddForm = function(req, res) {
  var data = {title: req.gettext('New Client Record') }
    ;

  // --------------------------------------------------------
  // If the user previously submitted the form but it was
  // rejected for some reason, pre-fill the data again for
  // the user so they don't have to re-enter everything.
  // --------------------------------------------------------
  if (req.session.priorRec) {
    data.priorRec = _.clone(req.session.priorRec);
    // Use the saved information only once.
    delete req.session.priorRec;
  }
  res.render('pregnancyAddForm', getEditFormData(req, data));
};

/* --------------------------------------------------------
 * getEditFormData()
 *
 * TODO: refactor to use getCommonFormData() instead of this
 * function.
 *
 * Returns an object representing the data that is rendered
 * when the edit form is displayed. Expects the caller to
 * pass the key/value pair for title in addData.
 *
 * param       req
 * param       addData  - (Object) additional data
 * return      Object
 * -------------------------------------------------------- */
var getEditFormData = function(req, addData) {
  var preData
    , ms
    , rel
    , edu
    , partEdu
    , clientInc
    , partnerInc
    , cf
    , schRec
    , priRec
    , prenatalDay
    , prenatalLog
    , defaultCity
    , mb
    ;

  // --------------------------------------------------------
  // Where is the pre-existing data coming from, a form that
  // was rejected or the database?
  // --------------------------------------------------------
  if (addData.priorRec) preData = addData.priorRec;
  if (req.paramPregnancy) preData = req.paramPregnancy;

  ms = adjustSelectData(maritalStatus, preData? preData.maritalStatus: void(0))
  rel = adjustSelectData(religion, preData? preData.religion: void(0))
  edu = adjustSelectData(education, preData? preData.education: void(0))
  partEdu = adjustSelectData(education, preData? preData.partnerEducation: void(0))
  clientInc = adjustSelectData(incomePeriod, preData? preData.clientIncomePeriod: void(0))
  partnerInc = adjustSelectData(incomePeriod, preData? preData.partnerIncomePeriod: void(0))
  cf = preData? preData.customField: void(0)
  prenatalDay = _.map(dayOfWeek, function(obj) {return _.clone(obj);})
  prenatalLoc = _.map(location, function(obj) {return _.clone(obj);})
  defaultCity = cfg.client.defaultCity.length > 0? cfg.client.defaultCity: ''
  mb = adjustSelectData(yesNoUnanswered, '')
    ;

  // --------------------------------------------------------
  // Add an empty selection as the default.
  // --------------------------------------------------------
  addBlankSelectData(prenatalDay);
  addBlankSelectData(prenatalLoc);

  // --------------------------------------------------------
  // If the user already filled these fields in a prior
  // rejected form, retain the user's selections.
  // --------------------------------------------------------
  if (preData && preData.prenatalDay) {
    prenatalDay = adjustSelectData(prenatalDay, preData.prenatalDay);
  }
  if (preData && preData.prenatalLocation) {
    prenatalLoc = adjustSelectData(prenatalLoc, preData.prenatalLocation);
  }
  if (preData && preData.mbBook) {
    mb = adjustSelectData(yesNoUnanswered, preData.mbBook);
  }

  if (req.paramPregnancy) {
    // --------------------------------------------------------
    // Store the prenatal scheduling for the client in the record.
    // --------------------------------------------------------
    schRec = _.find(req.paramPregnancy.schedule, function(obj) {
      return obj.scheduleType === 'Prenatal';
    });
    if (schRec) {
      req.paramPregnancy.prenatalSchedule = {
        id: schRec.id
        , day: getAbbr(schRec.day)
        , location: schRec.location
      };
      prenatalDay = adjustSelectData(prenatalDay, schRec.day);
      prenatalLoc = adjustSelectData(prenatalLoc, req.paramPregnancy.prenatalSchedule.location);
    } else {req.paramPregnancy.prenatalSchedule = {};}

    // --------------------------------------------------------
    // Store the priority number for the view.
    // --------------------------------------------------------
    priRec = _.find(req.paramPregnancy.priority, function(obj) {
      return obj.eType === prenatalCheckInId;
    });

    // --------------------------------------------------------
    // Mother/Baby Book.
    // --------------------------------------------------------
    if (req.paramPregnancy.mbBook === null) mb = adjustSelectData(yesNoUnanswered, '');
    if (req.paramPregnancy.mbBook === 1) mb = adjustSelectData(yesNoUnanswered, 'Y');
    if (req.paramPregnancy.mbBook === 0) mb = adjustSelectData(yesNoUnanswered, 'N');
  }

  return _.extend(addData, {
    user: req.session.user
    , messages: req.flash()
    , marital: ms
    , religion: rel
    , education: edu
    , partnerEducation: partEdu
    , clientIncomePeriod: clientInc
    , partnerIncomePeriod: partnerInc
    , prenatalLocation: prenatalLoc
    , prenatalDay: prenatalDay
    , priority: priRec && priRec.priority? priRec.priority: null
    , rec: req.paramPregnancy
    , customFields: cf
    , customFieldTypes: customFieldTypes
    , defaultCity: defaultCity
    , mbBook: mb
  });
};

/* --------------------------------------------------------
 * generalEditForm()
 *
 * Displays the edit form for the pregnancy.
 *
 * param
 * return
 * -------------------------------------------------------- */
var generalEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Client')};
  if (req.paramPregnancy) {
    res.render('pregnancyEditForm', getEditFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * generalAddSave()
 *
 * Create a new patient record and the corresponding pregnancy
 * record to go along with it. Insures that the required fields
 * are provided otherwise does not change the database.
 *
 * Also inserts into the following tables depending upon the
 * information provided by the user.
 *
 *  schedule
 *  priority
 *  event
 *
 * All writes to the database are done in a single transaction.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var generalAddSave = function(req, res) {
  var common = {
        updatedBy: req.session.user.id
        , supervisor: null
      }
    , dob = req.body.dob.length > 0? req.body.dob: null
    , doh = req.body.doh.length > 0? req.body.doh: null
    , prenatalLoc = req.body.prenatalLocation && req.body.prenatalLocation.length > 0? req.body.prenatalLocation: null
    , prenatalDay = req.body.prenatalDay && req.body.prenatalDay.length > 0? req.body.prenatalDay: null
    , priorityBarcode = req.body.priorityBarcode || void(0)
    , pregFlds = _.omit(req.body, ['_csrf', 'dob'])
    , patFlds = {}
    , schFlds = false
    , priFlds = {eType: prenatalCheckInId}
    , evtFlds = {}
    , pregnancy_id
    ;

  if (hasRole(req, 'attending')) {
    common.supervisor = req.session.supervisor.id;
  }
  pregFlds = _.extend(pregFlds, common);
  patFlds = _.extend(common, {dob: dob, dohID: doh});
  if (prenatalLoc && prenatalDay) {
    schFlds = {scheduleType: 'Prenatal', location: prenatalLoc, day: prenatalDay};
  } else {
    if (prenatalLoc || prenatalDay) {
      req.flash('info', req.gettext('Both Prenatal Day and Location have to be specified together or not at all.'));
    }
  }

  // --------------------------------------------------------
  // If unselected, don't translate that to 'No'.
  // --------------------------------------------------------
  if (! pregFlds.mbBook || pregFlds.mbBook.length === 0) pregFlds.mbBook = null;
  if (pregFlds.mbBook && pregFlds.mbBook === 'Y') pregFlds.mbBook = 1;
  if (pregFlds.mbBook && pregFlds.mbBook === 'N') pregFlds.mbBook = 0;

  // --------------------------------------------------------
  // Validate the fields.
  // --------------------------------------------------------
  Promise.all([patFlds, Pregnancy.checkFields(pregFlds)])
    .then(function(result) {
      return _.object(['patFlds', 'pregFlds'], result);
    })
    .then(function(flds) {
      // --------------------------------------------------------
      // Here begins a transaction that saves to the patient,
      // pregnancy, schedule, priority, and event tables.
      // --------------------------------------------------------
      return Bookshelf.DB.knex.transaction(function(t) {

        // --------------------------------------------------------
        // Create and save the patient record.
        // --------------------------------------------------------
        Patient
          .forge(flds.patFlds)
          .setUpdatedBy(req.session.user.id)
          .setSupervisor(common.supervisor)
          .save(null, {transacting: t})
          .then(function(patient) {
            // --------------------------------------------------------
            // Create and save the pregnancy record.
            // --------------------------------------------------------
            var pregFields = _.extend(flds.pregFlds, {patient_id: patient.get('id')});
            return Pregnancy
              .forge(pregFields)
              .setUpdatedBy(req.session.user.id)
              .setSupervisor(common.supervisor)
              .save(null, {transacting: t});
          })
          .then(function(pregnancy) {
            // --------------------------------------------------------
            // Save the pregnancy id for later.
            // --------------------------------------------------------
            pregnancy_id = pregnancy.get('id');
            if (schFlds) {
              // --------------------------------------------------------
              // User specified day and location for the schedule so save.
              // --------------------------------------------------------
              schFlds.pregnancy_id = pregnancy_id;
              return new Schedule(schFlds)
                .setUpdatedBy(req.session.user.id)
                .setSupervisor(common.supervisor)
                .save(null, {transacting: t})
                .then(function() {
                  return pregnancy;
                });
            } else {
              // --------------------------------------------------------
              // No schedule specified.
              // --------------------------------------------------------
              return pregnancy;
            }
          })
          .then(function(pregnancy) {
            var assignedDateTime
              ;
            return new Promise(function(resolve, reject) {
              if (priorityBarcode) {
                // --------------------------------------------------------
                // The user specified a priority number so retrieve the record
                // based upon the priority barcode. This is the priority that
                // the guard assigned when the client arrived but there were
                // no patient/pregnancy records in the system yet.
                // --------------------------------------------------------
                priFlds.barcode = priorityBarcode;
                Priority.forge(priFlds)
                  .fetch()
                  .then(function(priModel) {
                    var priorityPregId
                      , msg = 'Sorry, the priority barcode was not found. Please enter the barcode again.'
                      ;
                    if (priModel === null) {
                      // --------------------------------------------------------
                      // The priority number was not found which means that the
                      // priority number does not exist.
                      // --------------------------------------------------------
                      if (priorityBarcode.length <= 3) {
                        msg = 'Sorry, the priority barcode was not found. Did you enter the priority number instead of the barcode?';
                      }
                      msg = req.gettext(msg);
                      req.flash('error', msg);
                      return reject(msg);
                    }
                    assignedDateTime = priModel.get('assigned');
                    priorityPregId = priModel.get('pregnancy_id');
                    if (! priorityPregId) {
                      // --------------------------------------------------------
                      // The pregnancy id in the priority record is not set which
                      // is as expected. The assigned field in the priority record
                      // will be used as the dateTime stamp for the prenatalCheckIn
                      // event that will be inserted into the event table.
                      //
                      // We set the pregnancy id in the priority record as a flag
                      // so that this is not processed again as well as remove the
                      // assigned value.
                      // --------------------------------------------------------
                      priModel
                        .set('pregnancy_id', pregnancy_id)
                        .setUpdatedBy(req.session.user.id)
                        .setSupervisor(common.supervisor)
                        .save(null, {transacting: t})
                        .then(function() {
                          var opts = {}
                            ;
                          // --------------------------------------------------------
                          // Now create a prenatal checkin event using the datetime
                          // stamp from the priority record.
                          // --------------------------------------------------------
                          opts.eDateTime = assignedDateTime;
                          opts.pregnancy_id = pregnancy_id;
                          opts.sid = req.sessionID;
                          Event.prenatalCheckInEvent(opts, t).then(function() {
                            resolve();
                          });
                      });
                    } else {
                      // --------------------------------------------------------
                      // This means that the priority number entered is already
                      // assigned to another pregnancy. We reject the whole thing.
                      // --------------------------------------------------------
                      msg = req.gettext('The priority number has already been used by another client. Please choose another.');
                      req.flash('error', msg);
                      reject(msg);
                    }
                  });

              } else {
                // --------------------------------------------------------
                // Priority number was not entered in form when pregnancy created.
                // This is fine but there will be no prenatalCheckIn event
                // created.
                // --------------------------------------------------------
                resolve();
              }
            });
          })
          .then(function() {
            var jsonObj
              ;
            // --------------------------------------------------------
            // Handle any custom fields, if any.
            //
            // Custom fields will arrive for new records in this format:
            // customField-new as the key and the value will be a JSON
            // string with two elements: customFieldType_id and value.
            //
            // E.g. customField: '{customFieldType_id: 1, value: "Y"}'
            // Look up id 1 in the customFieldType table, get the value
            // from the valueFieldName field, use that value as the field
            // to put the 'Y' in the customField table.
            // --------------------------------------------------------
            if (req.body.customField && req.body.customField.length > 0) {
              try {
                jsonObj = JSON.parse(req.body.customField);
                return new CustomFieldType({id: jsonObj.customFieldType_id})
                  .fetch()
                  .then(function(cftModel) {
                    var cfObj
                      ;
                    if (! cftModel) return true;
                    if (cftModel.get('valueFieldName') === 'booleanVal') {
                      cfObj = {booleanVal: jsonObj.value === 'Y'? 1: 0};
                    }
                    if (cftModel.get('valueFieldName') === 'intVal') {
                      cfObj = {intVal: parseInt(jsonObj.value, 10)};
                    }
                    if (cftModel.get('valueFieldName') === 'decimalVal') {
                      cfObj = {decimalVal: jsonObj.value - 0};
                    }
                    if (cftModel.get('valueFieldName') === 'textVal') cfObj = {textVal: jsonObj.value};
                    if (cftModel.get('valueFieldName') === 'dateTimeVal') cfObj = {dateTimeVal: jsonObj.value};
                    cfObj = _.extend(cfObj, {customFieldType_id: cftModel.id, pregnancy_id: pregnancy_id});
                    return CustomField
                      .forge(cfObj)
                      .save(null, {transacting: t})
                      .then(function(cfModel) {
                        logInfo('Saved custom field.');
                      });
                  });
              } catch (e) {
                logError('Unable to save custom fields during pregnancy creation.');
                logError(e);
              }
            } else {
              logInfo('No custom fields submitted.');
            }
          })
          .then(function() {
            t.commit();
          })
          .caught(function(e) {
            logError('Error saving pregnancy record. Rolling back transaction.');
            logError(e);
            if (e.code && e.code === 'ER_DUP_ENTRY') {
              req.flash('error', 'Error: A patient with this MMC # already exists.');
            } else {
              req.flash('error', 'Error: Sorry an error occurred with error code ' + e.code);
            }
            t.rollback();
            return e;
          });
      });    // end of transaction
    })
    .then(function() {
      // --------------------------------------------------------
      // A successful transaction, return the edit page.
      // --------------------------------------------------------
      req.flash('info', req.gettext('Pregnancy was created.'));
      res.redirect(cfg.path.pregnancyEditForm.replace(/:id/, pregnancy_id));
    })
    .caught(function(err) {
      // --------------------------------------------------------
      // If the error is a string, it came from the fields check
      // so we log it appropriately. Otherwise, it was already
      // logged before.
      // --------------------------------------------------------
      if (_.isString(err)) {
        req.flash('error', err);
        logError(err);
      }

      // --------------------------------------------------------
      // Store the form to allow it to be filled for the user to
      // try again rather than losing all of their work.
      // --------------------------------------------------------
      req.session.priorRec = _.omit(req.body, ['_csrf']);
      res.redirect(cfg.path.pregnancyNewForm);
    });
};

/* --------------------------------------------------------
 * generalEditSave()
 *
 * Update the patient record and the corresponding pregnancy
 * record to go along with it. Insures that the required fields
 * are provided otherwise does not change the database.
 *
 * Also inserts/updates the following tables depending upon the
 * information provided by the user.
 *
 *  schedule
 *  priority
 * -------------------------------------------------------- */
var generalEditSave = function(req, res) {
  var pregFlds
    , patFlds
    , schFlds
    , dob = req.body.dob.length > 0? req.body.dob: null
    , doh = req.body.doh.length > 0? req.body.doh: null
    , prenatalLoc = req.body.prenatalLocation.length > 0? req.body.prenatalLocation: null
    , prenatalDay = req.body.prenatalDay.length > 0? req.body.prenatalDay: null
    , scheduleId = req.body.scheduleId.length > 0? req.body.scheduleId: null
    , priorityBarcode = req.body.priorityBarcode.length > 0? req.body.priorityBarcode: null
    , supervisor = null
    ;
  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.id &&
      req.paramPregnancy.id == req.body.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }
    pregFlds = _.omit(req.body, ['_csrf', 'doh', 'dob', 'priorityBarcode',
        'prenatalDay', 'prenatalLocation']);
    patFlds = {dohID: doh, dob: dob};
    patFlds = _.extend(patFlds, {id: req.paramPregnancy.patient_id});
    schFlds = {scheduleType: 'Prenatal', location: prenatalLoc,
      day: prenatalDay, pregnancy_id: req.paramPregnancy.id};
    if (scheduleId !== null) schFlds.id = scheduleId;

    // --------------------------------------------------------
    // If unselected, don't translate that to 'No'.
    // --------------------------------------------------------
    if (pregFlds.mbBook.length === 0) pregFlds.mbBook = null;
    if (pregFlds.mbBook === 'Y') pregFlds.mbBook = 1;
    if (pregFlds.mbBook === 'N') pregFlds.mbBook = 0;

    // --------------------------------------------------------
    // Convert to a number.
    // --------------------------------------------------------
    if (priorityBarcode) {
      priorityBarcode = parseInt(priorityBarcode, 10) || null;
    }

    Pregnancy.checkFields(pregFlds)
      .then(function(flds) {
        return Bookshelf.DB.knex.transaction(function(t) {
          // --------------------------------------------------------
          // Save the pregnancy information.
          // --------------------------------------------------------
          return Pregnancy.forge(flds)
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(supervisor)
            .save(null, {transacting: t})
            .then(function() {
              // --------------------------------------------------------
              // Save the patient record.
              // --------------------------------------------------------
              return Patient
                .forge(patFlds)
                .setUpdatedBy(req.session.user.id)
                .setSupervisor(supervisor)
                .save(null, {transacting: t});
            })
            .then(function() {
              var msg;
              // --------------------------------------------------------
              // Create or update the schedule records as necessary but
              // skip any update if they are not both present. Either
              // way, the transaction continues and is not aborted.
              // --------------------------------------------------------
              if ((_.isNull(prenatalDay) && ! _.isNull(prenatalLoc)) ||
                 (! _.isNull(prenatalDay) && _.isNull(prenatalLoc))) {
                msg = 'Both prenatal day and location must be specified together or not at all.';
                req.flash('warning', req.gettext(msg));
                logWarn(msg);
              } else {
                // If they are both populated, update the schedule, otherwise ignore.
                if (! (_.isNull(prenatalDay) && _.isNull(prenatalLoc))) {
                  logInfo('Updating schedule');
                  return Schedule
                    .forge(schFlds)
                    .setUpdatedBy(req.session.user.id)
                    .setSupervisor(supervisor)
                    .save(null, {transacting: t});
                }
              }
            })
            .then(function() {
              return new Promise(function(resolve, reject) {
                // --------------------------------------------------------
                // Handle priority numbers.
                // --------------------------------------------------------
                var priFlds = {
                      eType: prenatalCheckInId
                      , pregnancy_id: req.paramPregnancy.id
                    }
                  ;
                Promise
                  .join(Priority.getAvailablePriorityBarcodes(prenatalCheckInId),
                        Priority.getAssignedPriorityBarcodes(prenatalCheckInId))
                  .spread(function(available, assigned) {
                    Priority.forge(priFlds)
                      .fetch()
                      .then(function(priorityRec) {
                        if (priorityRec === null && priorityBarcode === null) {
                          // --------------------------------------------------------
                          // Priority number was not already assigned and it is not
                          // being assigned now. There is nothing to do.
                          // --------------------------------------------------------
                          return resolve();
                        }

                        if (priorityRec !== null && priorityRec.get('barcode') == priorityBarcode) {
                          // --------------------------------------------------------
                          // The priority number that was already assigned is not being
                          // changed. Apparently the user entered it twice. There is
                          // nothing to do.
                          // --------------------------------------------------------
                          return resolve();
                        }

                        if (priorityRec !== null && priorityBarcode === null) {
                          // --------------------------------------------------------
                          // The priority number is already assigned and this save
                          // is not changing that. There is nothing to do.
                          // --------------------------------------------------------
                          return resolve();
                        }

                        if (! _.contains(available, priorityBarcode) &&
                            ! _.contains(assigned, priorityBarcode)) {
                          // --------------------------------------------------------
                          // The priority barcode the user chose to assign does not
                          // exist in the system and therefore cannot be used.
                          // --------------------------------------------------------
                          return reject('The priority barcode specified does not exist.');
                        }

                        if (_.contains(assigned, priorityBarcode)) {
                          // --------------------------------------------------------
                          // The priority barcode the user choose to assign is already
                          // assigned to another pregnancy and cannot be used.
                          // --------------------------------------------------------
                          return reject('The priority barcode specified is already used.');
                        }

                        if (priorityRec === null && _.contains(available, priorityBarcode)) {
                          // --------------------------------------------------------
                          // Priority barcode was not already assigned and it is being
                          // assigned now to a number that is available for use.
                          //
                          // Update the priority record with the pregnancy id and
                          // create a prenatal check in event using the date/time that
                          // the priority record was created.
                          // --------------------------------------------------------
                          return Priority
                            .forge()
                            .query(function(qb) {
                              qb.where('barcode', '=', priorityBarcode);
                              qb.andWhere('eType', '=', prenatalCheckInId);
                            })
                            .fetch()
                            .then(function(priRec) {
                              var assigned
                                ;
                              if (priRec === null) return reject();
                              assigned = priRec.get('assigned');
                              priRec
                                .set('pregnancy_id', req.paramPregnancy.id)
                                .setUpdatedBy(req.session.user.id)
                                .setSupervisor(supervisor)
                                .save(null, {method: 'update', transacting: t})
                                .then(function() {
                                  var opts = {
                                        eDateTime: assigned
                                        , pregnancy_id: req.paramPregnancy.id
                                        , sid: req.sessionID
                                      }
                                    ;
                                  Event.prenatalCheckInEvent(opts, t).then(function() {
                                    resolve();
                                  });
                                });
                            });
                        } else {
                          // --------------------------------------------------------
                          // This is an unaccounted for situation - abort.
                          // --------------------------------------------------------
                          logError('Unknown priority number situation. Aborting.');
                          return reject();
                        }
                      });
                });
              });   // end Promise
            })
            .then(function() {
              var jsonObj
                ;
              // --------------------------------------------------------
              // Handle custom fields, if any.
              //
              // Custom fields will arrive for new records in this format:
              // customField-new as the key and the value will be a JSON
              // string with two elements: customFieldType_id and value.
              //
              // E.g. customField: '{customFieldType_id: 1, value: "Y"}'
              // Look up id 1 in the customFieldType table, get the value
              // from the valueFieldName field, use that value as the field
              // to put the 'Y' in the customField table.
              // --------------------------------------------------------
              if (req.body.customField && req.body.customField.length > 0) {
                try {
                  jsonObj = JSON.parse(req.body.customField);
                  return new CustomFieldType({id: jsonObj.customFieldType_id})
                    .fetch()
                    .then(function(cftModel) {
                      var cfObj
                        ;
                      if (! cftModel) return true;

                      // --------------------------------------------------------
                      // Prepare the customField record whether for create or update.
                      // --------------------------------------------------------
                      if (cftModel.get('valueFieldName') === 'booleanVal') {
                        cfObj = {booleanVal: jsonObj.value === 'Y'? 1: 0};
                      }
                      if (cftModel.get('valueFieldName') === 'intVal') {
                        cfObj = {intVal: parseInt(jsonObj.value, 10)};
                      }
                      if (cftModel.get('valueFieldName') === 'decimalVal') {
                        cfObj = {decimalVal: jsonObj.value - 0};
                      }
                      if (cftModel.get('valueFieldName') === 'textVal') cfObj = {textVal: jsonObj.value};
                      if (cftModel.get('valueFieldName') === 'dateTimeVal') cfObj = {dateTimeVal: jsonObj.value};

                      // --------------------------------------------------------
                      // Determine if there already is a customField record or if
                      // we are creating a new one.
                      // --------------------------------------------------------
                      return new CustomField({customFieldType_id: cftModel.get('id'), pregnancy_id: req.paramPregnancy.id})
                        .fetch()
                        .then(function(cfModel) {
                          if (! cfModel) {
                            // --------------------------------------------------------
                            // Creating a new record.
                            // --------------------------------------------------------
                            cfObj = _.extend(cfObj, {customFieldType_id: cftModel.id, pregnancy_id: req.paramPregnancy.id});
                            return CustomField
                              .forge(cfObj)
                              .save(null, {transacting: t})
                              .then(function(cfModel) {
                                logInfo('Saved custom field.');
                              });
                          } else {
                            // --------------------------------------------------------
                            //  Updating existing record.
                            // --------------------------------------------------------
                            return cfModel
                              .save(cfObj, {transacting: t})
                              .then(function(model) {
                                logInfo('Updated custom field.');
                              });
                          }
                        });
                    });
                } catch (e) {
                  logError('Unable to save custom fields during pregnancy creation.');
                  logError(e);
                }
              } else {
                logInfo('No custom fields submitted.');
              }
            })
            .then(function() {
              logInfo('Pregnancy was updated.');
              req.flash('info', req.gettext('Pregnancy was updated.'));
            })
            .caught(function(err) {
              logError(err);
              if (err.code && err.code === 'ER_DUP_ENTRY') {
                req.flash('error', 'Error: A patient with this MMC # already exists.');
              } else {
                req.flash('error', 'Error: Sorry an error occurred with error code ' + err.code);
              }
            });
          // --------------------------------------------------------
          // returns a transaction - commit() or rollback() is called
          // automatically when returning a promise.
          // --------------------------------------------------------
          });
      })
      .then(function() {
        // --------------------------------------------------------
        // Success or already handled error.
        // --------------------------------------------------------
        res.redirect(cfg.path.pregnancyEditForm.replace(/:id/, req.paramPregnancy.id));
      })
      .caught(function(err) {
        // --------------------------------------------------------
        // Failure in checkFields().
        // --------------------------------------------------------
        logError(err);
        req.flash('error', err);
        res.redirect(cfg.path.pregnancyEditForm.replace(/:id/, req.paramPregnancy.id));
      });

  } else {
    logError('Error in update of pregnancy: pregnancy not found.');
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * midwifeForm()
 *
 * Display the midwife interview screen.
 * -------------------------------------------------------- */
var midwifeForm = function(req, res) {
  var data = getCommonFormData(req, {title: req.gettext('Midwife Interview')})
    ;
  // --------------------------------------------------------
  // Properly set the noneOfAbove field which does not have
  // representation in the database.
  // --------------------------------------------------------
  if (data.rec.invertedNipples == 0 && data.rec.hasUS == 0 && data.rec.wantsUS == 0) {
    data.rec.noneOfAbove = 1;
  }
  if (req.paramPregnancy) {
    res.render('midwifeInterview', data);
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * midwifeSave()
 *
 * Update the patient, pregnancy and pregnancyHistory records
 * with changes from the midwife interview screen.
 * -------------------------------------------------------- */
var midwifeSave = function(req, res) {
  var supervisor = null
    , pregFlds = {}
    , defaultFlds = {
        invertedNipples: '0'
        , hasUS: '0'
        , wantsUS: '0'
        , noneOfAbove: '0'        // Field does not exist in database.
        , ageOfMenarche: null     // Patient field, not pregnancy.
        , note: ''
      }
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.id &&
      req.paramPregnancy.id == req.body.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // Allow 'unchecking' a box by providing a default of off.
    // --------------------------------------------------------
    pregFlds = _.extend(defaultFlds, _.omit(req.body, ['_csrf']));

    Pregnancy.checkMidwifeInterviewFields(pregFlds).then(function(flds) {
      Pregnancy.forge({id: pregFlds.id})
        .fetch().then(function(pregnancy) {
          pregnancy
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(supervisor)
            .save(pregFlds).then(function(pregnancy) {
              Patient.forge({id: pregnancy.get('patient_id')})
                .fetch().then(function(patient) {
                  patient
                    .setUpdatedBy(req.session.user.id)
                    .setSupervisor(supervisor)
                    .save({ageOfMenarche: pregFlds.ageOfMenarche}).then(function(patient) {
                      req.flash('info', req.gettext('Pregnancy was updated.'));
                      res.redirect(cfg.path.pregnancyMidwifeEdit.replace(/:id/, pregnancy.id));
                    })
                    .caught(function(err) {
                      logError(err);
                      res.redirect(cfg.path.search);
                    });
                });
            })
            .caught(function(err) {
              logError(err);
              res.redirect(cfg.path.search);
            });
      });
    })
    .caught(function(err) {
      logError(err);
      req.flash('warning', req.gettext(err));
      res.redirect(cfg.path.pregnancyMidwifeEdit.replace(/:id/, pregFlds.id));
    });
  } else {
    logError('Error in update of pregnancy: pregnancy not found.');
    res.redirect(cfg.path.search);
  }

};


/* --------------------------------------------------------
 * prenatalForm()
 *
 * Display the edit form for the prenatal information.
 * -------------------------------------------------------- */
var prenatalForm = function(req, res) {
  var data = getCommonFormData(req, {title: req.gettext('Prenatal')})
    , role = req.session.roleInfo.roleNames[0]
    , table1 = 'pregnancy'
    , table2 = 'risk'
    ;
  if (req.paramPregnancy) {
    RoFieldsByRole
      .getTableFieldsByRole(role, table1)
      .then(function(map) {
        data.readonlyFields = map;
        RoFieldsByRole
          .getTableFieldsByRole(role, table2)
          .then(function(map) {
            _.extend(data.readonlyFields, map);
            res.render('prenatal', data);
          });
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * prenatalSave()
 *
 * Update the high-level prenatal information about the
 * pregnancy.
 * -------------------------------------------------------- */
var prenatalSave = function(req, res) {
  var supervisor = null
    , pnFlds = {}
    , riskFlds = {}
    , riskInsertRecs = []
    , riskDeleteRecs = []
    , defaultFlds = {
        philHealthMCP: '0'
        , philHealthNCP: '0'
        , philHealthApproved: '0'
        , useAlternateEdd: '0'
        , sureLMP: '0'
      }
    , defaultRiskFlds = {
        A1: '0'
        , A2: '0'
        , B1: '0'
        , B2: '0'
        , B3: '0'
        , C: '0'
        , F: '0'
        , D1: '0'
        , D2: '0'
        , D3: '0'
        , D4: '0'
        , D5: '0'
        , D6: '0'
        , D7: '0'
        , E1: '0'
        , E2: '0'
        , E3: '0'
        , E4: '0'
        , E5: '0'
        , E6: '0'
        , E7: '0'
        , E8: '0'
        , G1: '0'
        , G2: '0'
        , G3: '0'
        , G4: '0'
        , G5: '0'
        , G6: '0'
      }
    , role = req.session.roleInfo.roleNames[0]
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.id &&
      req.paramPregnancy.id == req.body.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // Allow 'unchecking' a box by providing a default of off.
    // --------------------------------------------------------
    pnFlds = _.defaults(_.omit(req.body, _.union(['_csrf'], _.keys(defaultRiskFlds))), defaultFlds);
    riskFlds = _.defaults(_.omit(req.body, _.union(['_csrf'], _.keys(pnFlds))), defaultRiskFlds);

    // --------------------------------------------------------
    // transferOfCare and transferOfCareTime actually are all
    // stored in transferOfCare as a DATETIME. But if they are
    // not both specified, we reject both of these fields.
    // --------------------------------------------------------
    if (pnFlds.transferOfCare || pnFlds.transferOfCareTime) {
      if (! pnFlds.transferOfCare || ! pnFlds.transferOfCareTime) {
        req.flash('warning', 'Transfer of care date and time must be specified. Transfer of care change not saved.');
        delete pnFlds.transferOfCareTime;
        delete pnFlds.transferOfCare;
      } else {
        pnFlds.transferOfCare = moment(pnFlds.transferOfCare + ' ' + pnFlds.transferOfCareTime, 'YYYY-MM-DD HH:mm').toDate();
        delete pnFlds.transferOfCareTime;
      }
    } else {
      // Clear field of content, if any.
      pnFlds.transferOfCare = null;
    }

    // --------------------------------------------------------
    // For each potential risk, determine if the pregnancy had
    // previously had the risk assigned. If so and the new value
    // is '0' (unchecked), delete the record. If not and the
    // new value is '1' (checked), insert a new record. Store
    // decisions in riskInsertRecs and riskDeleteRecs to be
    // applied later.
    // --------------------------------------------------------
    _.each(riskFlds, function(val, key) {
      var riskCodeId
        , riskRec
        ;
      // --------------------------------------------------------
      // Get the riskCode id that this risk name maps to.
      // --------------------------------------------------------
      riskCodeId = _.findWhere(riskCodes, {name: key}).id;

      // --------------------------------------------------------
      // Find if risk record already exists in the database for
      // this pregnancy.
      // --------------------------------------------------------
      riskRec = _.findWhere(req.paramPregnancy.risk, {riskCode: riskCodeId});
      if (riskRec) {
        if (val === '0') {
          // --------------------------------------------------------
          // Delete the record from the risk table.
          // --------------------------------------------------------
          riskDeleteRecs.push({id: riskRec.id, pregnancy_id: req.paramPregnancy.id});
        }
      } else {
        if (val === '1') {
          // --------------------------------------------------------
          // Create a new record in the risk table.
          // --------------------------------------------------------
          riskInsertRecs.push({riskCode: riskCodeId, pregnancy_id: req.paramPregnancy.id});
        }
      }
    });

    // --------------------------------------------------------
    // Save the data, the pregnncy record first and then the
    // risk records. But first check to see if the user is
    // authorized to update all of these fields and eliminate
    // the fields the user is not authorized for.
    // --------------------------------------------------------
    RoFieldsByRole
      .getTableFieldsByRole(role, 'pregnancy')
      .then(function(roFlds) {
        RoFieldsByRole
          .getTableFieldsByRole(role, 'risk')
          .then(function(roFlds2) {
            _.each(pnFlds, function(val, key) {
              if (_.has(roFlds, key)) delete pnFlds[key];
            });
            // All risk fields are represented as the riskCode field so if that
            // is specified as readonly, we do nothing with the records.
            if (_.has(roFlds2, 'riskCode')) {
              riskDeleteRecs = [];
              riskInsertRecs = [];
            }
            Pregnancy.forge({id: pnFlds.id})
              .fetch().then(function(pregnancy) {
                pregnancy
                  .setUpdatedBy(req.session.user.id)
                  .setSupervisor(supervisor)
                  .save(pnFlds)
                  .then(function(pregnancy) {
                    var risksDel
                      ;
                    // --------------------------------------------------------
                    // Delete the risk records necessary.
                    // --------------------------------------------------------
                    if (riskDeleteRecs.length > 0 || riskInsertRecs.length > 0) {
                      risksDel = new Risks(riskDeleteRecs);
                      risksDel.invokeThen('destroy', null)
                        .then(function() {
                          // --------------------------------------------------------
                          // Insert the new risk records.
                          // --------------------------------------------------------
                          var risksIns = new Risks(riskInsertRecs);
                          risksIns.invokeThen('setUpdatedBy', [req.session.user.id]).then(function() {
                            risksIns.invokeThen('setSupervisor', supervisor).then(function() {
                              risksIns.invokeThen('save').then(function() {
                                req.flash('info', req.gettext('Pregnancy was updated.'));
                                res.redirect(cfg.path.pregnancyPrenatalEdit.replace(/:id/, pregnancy.id));
                              });
                            });
                          });
                        });
                    } else {
                      // No risk records to change.
                      req.flash('info', req.gettext('Pregnancy was updated.'));
                      res.redirect(cfg.path.pregnancyPrenatalEdit.replace(/:id/, pregnancy.id));
                    }
                  })
                  .caught(function(err) {
                    logError(err);
                    res.redirect(cfg.path.search);
                  });
              })
              .caught(function(err) {
                logError(err);
                res.redirect(cfg.path.search);
              });
          });
      });
  } else {
    logError('Error in update of prenatal information: pregnancy not found.');
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * pregnancyDelete()
 *
 * Delete a master pregnancy record and all records in the
 * child tables. All deleted records are still available in
 * the respective log tables due to the delete triggers on
 * each table. Finally deletes the patient record itself
 * which is master to the pregnancy record.
 *
 * Records in these tables are deleted, if available:
 *    customField
 *    healthTeaching
 *    labTestResult
 *    medication
 *    pregnancyHistory
 *    prenatalExam
 *    referral
 *    risk
 *    schedule
 *    vaccination
 *    patient
 *
 * NOTE: The patient record is deleted for the time being until
 * the database schema is refactored. Right now the patient to
 * pregnancy relationship is one to one instead of one to many.
 * When this is refactored, the patient record will need to
 * survive a pregnancy delete. There will need to be a separate
 * patient delete that handles the patient and child tables.
 * -------------------------------------------------------- */
var pregnancyDelete = function(req, res) {
  var pregId
    , patId = -1
    , knex = Bookshelf.DB.knex
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    pregId = parseInt(req.paramPregnancy.id, 10);

    logInfo('Deleting master and all child tables for pregnancy id ' + pregId);

    // --------------------------------------------------------
    // Get the patient id in order to delete the patient record
    // at the end.
    // --------------------------------------------------------
    Pregnancy.forge({id: pregId})
      .fetch()
      .then(function(preg) {
        patId = preg.get('patient_id');
      })
      .then(function() {
        if (patId !== -1) {
          Bookshelf.DB.knex.transaction(function(t) {
            var tblNames = [
                'customField'
                , 'healthTeaching'
                , 'labTestResult'
                , 'medication'
                , 'pregnancyHistory'
                , 'prenatalExam'
                , 'referral'
                , 'risk'
                , 'schedule'
                , 'vaccination'
                , 'pregnancy'
              ]
              ;

            return Promise.all(_.map(tblNames, function(tblName) {
              var fldName = 'pregnancy_id';
              if (tblName === 'pregnancy') {
                fldName = 'id';
              }
              return knex(tblName)
                .transacting(t)
                .where(fldName, pregId)
                .del()
                .then(function(numRows) {
                  logInfo(numRows + ' rows deleted from ' + tblName + '.');
                });
            }));

          })   // end transaction
          .then(function() {
            // --------------------------------------------------------
            // Clean up the orphaned patient record.
            // --------------------------------------------------------
            return Patient.forge({id: patId})
              .destroy()
              .then(function(result) {
                return true;
              });
          })
          .then(function() {
            logInfo('Pregnancy ' + pregId + ' was deleted.');
            req.flash('info', req.gettext('Pregnancy was deleted.'));
            res.redirect(cfg.path.search);
          })
          .caught(function(err) {
            logError(err);
            logError('The pregnancy and related records were not deleted.');
            req.flash('error', req.gettext('Sorry, an error was encountered and the pregnancy was not deleted.'));
            res.redirect(cfg.path.search);
          });
        } else {
          // --------------------------------------------------------
          // Patient id was not found, so do nothing.
          // --------------------------------------------------------
          logError('There was a problem so we did not do anything. The pregnancy record is unchanged.');
          req.flash('error', req.gettext('Sorry, an error was encountered and the pregnancy was not deleted.'));
          res.redirect(cfg.path.search);
        }
      });   // end then

  }   // end if
};


/* --------------------------------------------------------
 * labsForm()
 *
 * Displays the main labs page that contains many sub-sections
 * covering labs, etc.
 *
 * Note: progress notes are retrieved in load() instead of
 * here on the chance that they may likely be available on
 * more than one screen.
 * -------------------------------------------------------- */
var labsForm = function(req, res) {
  var data
    , suiteDefs = []
    , labResults = []
    , referrals = []
    , teachings = []
    , vaccinations = []
    , medications = []
    , tetanusComplete
    ;

  if (req.paramPregnancy) {
    // --------------------------------------------------------
    // The labs page has a lot of data so we load all of the
    // data sequentially in order to populate the page.
    //
    // TODO: consider using Promise.all() to load in parallel.
    // --------------------------------------------------------

    // labSuite, labTest, and labTestValue for adding new lab results.
    new LabSuites()
      .fetch({withRelated: ['LabTest']})
      .then(function(suites) {
        suites.forEach(function(suite) {
          var tests = suite.related('LabTest')
            , testNames = _.pluck(tests.toJSON(), 'name')
            ;
          suiteDefs.push({
            id: suite.get('id')
            , name: suite.get('name')
            , tests: tests.toJSON()
          });
        });
      })
      // Get existing labTestResult records.
      .then(function() {
        return new LabTestResults()
          .query(function(qb) {
            qb.where('pregnancy_id', '=', req.paramPregnancy.id);
          })
          .fetch({withRelated: ['LabTest']});
      })
      // Massage the labTestResult records into the format that we want.
      .then(function(ltResults) {
        var ltests = []
          ;
        _.each(ltResults.toJSON(), function(result) {
            var r = _.omit(result, ['updatedBy','updatedAt','supervisor','LabTest']);
            r.name = result.LabTest.name;
            ltests.push(r);
        });
        // --------------------------------------------------------
        // Sort by test id then date.
        // --------------------------------------------------------
        labResults = _.sortBy(ltests, function(lt) {
          return Number(lt.labTest_id + '.' + moment(lt.testDate).unix());
        });
      })
      // Get the referrals
      .then(function() {
        return new Referrals().query()
          .where({pregnancy_id: req.paramPregnancy.id})
          .select();
      })
      // Load the referrals into our list
      .then(function(refs) {
        var refList;
        refList = _.sortBy(refs, 'date');
        _.each(refList, function(ref) {
          ref.date = moment(ref.date).format('MM-DD-YYYY');
        });
        referrals = refList;
      })
      // Get the Health teachings.
      .then(function() {
        return new Teachings().query()
          .where({pregnancy_id: req.paramPregnancy.id})
          .select();
      })
      // Load the health teachings into our list.
      .then(function(records) {
        var teachingsList;
        teachingsList = _.sortBy(records, 'date');
        _.each(teachingsList, function(teach) {
          teach.date = moment(teach.date).format('MM-DD-YYYY');
        });
        teachings = teachingsList;
      })
      // Get the vaccinations
      .then(function() {
        return new Vaccinations().query()
          .column('vaccination.id', 'vacDate', 'vacMonth', 'vacYear', 'administeredInternally', 'note')
          .join('vaccinationType', 'vaccinationType', '=', 'vaccinationType.id')
          .column('name', 'description')
          .where({pregnancy_id: req.paramPregnancy.id})
          .select();
      })
      // Load the vaccinations into our list
      .then(function(vacs) {
        var vacList = [];
        _.each(vacs, function(vac) {
          // Create a virtual field in order to sort the records by date using
          // the 3 date fields: vacData, vacMonth, and vacYear.
          if (vac.vacDate === null) {
            if (vac.vacMonth && vac.vacYear) {
              // Moment expects month as 0 - 11.
              vac.sortDate = moment([vac.vacYear, vac.vacMonth - 1]).format('YYYYMM');
            } else if (vac.vacYear) {
              vac.sortDate = moment([vac.vacYear]).format('YYYY');
            } else {
              // Invalid record.
              vac.sortDate = '0';
            }
          } else {
            vac.vacDate = moment(vac.vacDate).format('YYYY-MM-DD');
            vac.sortDate = moment(vac.vacDate).format('YYYYMMDD');
          }
          vacList.push(vac);
        });
        vacList = _.sortBy(vacList, 'sortDate');
        vaccinations = vacList;
      })
      // Determine if the number of vaccinations has already been administered.
      .then(function() {
        var sql
          , knex
          , pid = req.paramPregnancy.id
          ;
        sql =  'SELECT IF(IFNULL(p.numberRequiredTetanus <= ';
        sql += '(SELECT COUNT(*) FROM vaccination v ';
        sql += 'WHERE v.pregnancy_id = ' + pid + ' AND v.vaccinationType IN ';
        sql += '(SELECT id FROM vaccinationType WHERE name LIKE "Tetanus%") ';
        sql += 'AND v.vacDate > p.lmp), 0), 1, 0) ';
        sql += 'AS tetanusComplete FROM pregnancy p WHERE p.id = ' + pid;
        knex = Bookshelf.DB.knex;
        return knex
          .raw(sql)
          .then(function(ans) {
            tetanusComplete = ans[0][0].tetanusComplete;
          });
      })
      // Get the medications
      .then(function() {
        return new Medications().query()
          .column('medication.id', 'date', 'numberDispensed', 'note')
          .join('medicationType', 'medicationType', '=', 'medicationType.id')
          .column('name', 'description')
          .where({pregnancy_id: req.paramPregnancy.id})
          .select();
      })
      // Load the medications into our list
      .then(function(meds) {
        var medList = [];
        _.each(meds, function(med) {
          med.date = moment(med.date).format('YYYY-MM-DD');
          medList.push(med);
        });
        medList = _.sortBy(medList, 'date');
        medications = medList;
      })
      // Prepare the data for the form and return it to the user.
      .then(function() {
        data = getCommonFormData(
                req,
                _.extend({title: req.gettext('Labs')}, {
                    labTests: suiteDefs
                    , labTestResults: labResults
                    , referrals: referrals
                    , vaccinations: vaccinations
                    , medications: medications
                    , teachings: teachings
                    , tetanusComplete: tetanusComplete? tetanusComplete: 0
                })
        );
        return res.render('labs', data);
      })
      .caught(function(err) {
        logError(err);
        return res.redirect(cfg.path.search);
      });
  } else {
    // Pregnancy not found.
    logError('Pregnancy not found: ' + req.url);
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * doctorDentistSave()
 *
 * Update the doctor and/or dentist consult date fields.
 * -------------------------------------------------------- */
var doctorDentistSave = function(req, res) {
  var supervisor = null
    , flds = _.omit(req.body, ['_csrf'])
    ;

  if (req.paramPregnancy && req.paramPregnancy.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.id = req.paramPregnancy.id;
    Pregnancy.forge(flds)
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save().then(function(pregnancy) {
        req.flash('info', req.gettext('Doctor/Dentist dates were updated.'));
        res.redirect(cfg.path.pregnancyLabsEditForm.replace(/:id/, flds.id));
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });
  } else {
    logError('Error in update of Doctor/Dentist: pregnancy not found.');
    res.redirect(cfg.path.search);
  }
};

// --------------------------------------------------------
// Initialize the module.
// --------------------------------------------------------
init();

module.exports = {
  generalAddForm: generalAddForm
  , generalAddSave: generalAddSave
  , generalEditForm: generalEditForm
  , generalEditSave: generalEditSave
  , questionaireForm: questionaireForm
  , questionaireSave: questionaireSave
  , midwifeForm: midwifeForm
  , midwifeSave: midwifeSave
  , prenatalForm: prenatalForm
  , prenatalSave: prenatalSave
  , pregnancyDelete: pregnancyDelete
  , labsForm: labsForm
  , doctorDentistSave: doctorDentistSave
  , load: load
  , getCommonFormData: getCommonFormData
};

