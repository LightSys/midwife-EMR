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
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , getGA = require('../util').getGA
  , getAbbr = require('../util').getAbbr
  , calcEdd = require('../util').calcEdd
  , adjustSelectData = require('../util').adjustSelectData
  , maritalStatus = []
  , religion = []
  , education = []
  , edema = []
  , riskPresent = []
  , riskObHx = []
  , riskMedHx = []
  , riskLifestyle = []
  , incomePeriod = []
  , yesNoUnanswered = []
  , yesNoUnknown = []
  , attendant = []
  , wksMthsYrs = []
  , wksMths = []
  , maleFemale = []
  , location = []
  , dayOfWeek = []
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
    , riskPresentName = 'riskPresent'
    , riskObHxName = 'riskObHx'
    , riskMedHxName = 'riskMedHx'
    , riskLifestyleName = 'riskLifestyle'
    , incomePeriodName = 'incomePeriod'
    , yesNoUnansweredName = 'yesNoUnanswered'
    , yesNoUnknownName = 'yesNoUnknown'
    , attendantName = 'attendant'
    , wksMthsYrsName = 'wksMthsYrs'
    , wksMthsName = 'wksMths'
    , maleFemaleName = 'maleFemale'
    , locationName = 'location'
    , dayOfWeekName = 'dayOfWeek'
    , interval = cfg.data.selectRefreshInterval
  ;

  // --------------------------------------------------------
  // Refresh dataset passed.
  // --------------------------------------------------------
  refresh = function(dataName) {
    return new Promise(function(resolve, reject) {
      logInfo('Refreshing ' + dataName);
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
  doRefresh(riskPresentName, function(l) {riskPresent = l;});
  doRefresh(riskObHxName, function(l) {riskObHx = l;});
  doRefresh(riskMedHxName, function(l) {riskMedHx = l;});
  doRefresh(riskLifestyleName, function(l) {riskLifestyle = l;});
  doRefresh(incomePeriodName, function(l) {incomePeriod = l;});
  doRefresh(yesNoUnansweredName, function(l) {yesNoUnanswered = l;});
  doRefresh(yesNoUnknownName, function(l) {yesNoUnknown = l;});
  doRefresh(attendantName, function(l) {attendant = l;});
  doRefresh(wksMthsYrsName, function(l) {wksMthsYrs = l;});
  doRefresh(wksMthsName, function(l) {wksMths = l;});
  doRefresh(maleFemaleName, function(l) {maleFemale = l;});
  doRefresh(locationName, function(l) {location = l;});
  doRefresh(dayOfWeekName, function(l) {dayOfWeek = l;});
};

/* --------------------------------------------------------
 * load()
 *
 * Loads the pregnancy record from the database based upon the id
 * as specified in the path. Places the pregnancy record in the
 * request as paramPregnancy.
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
    , formatDate = function(val) {
        var d
          , formatted
          ;
        if (val === null) return '';
        if (val === '0000-00-00') return '';
        d = moment(val);
        if (! d.isValid()) return '';
        return d.format('YYYY-MM-DD');
      }
    ;

  User.getUserIdMap().then(function(userMap) {
    Pregnancy.forge({id: id})
      .fetch({withRelated: [
        'patient'
        , 'pregnancyHistory'
        , {
            pregnancyHistory: function(qb) {
              qb.orderBy('year', 'asc');
              qb.orderBy('month', 'asc');
            }
          }
        , 'prenatalExam'
        , 'schedule']})
      .then(function(rec) {
        if (! rec) return next();
        rec = rec.toJSON();

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
        // Calculate the gestational age for each prenatal exam and
        // get a user friendly name for the examiner.
        // --------------------------------------------------------
        if (rec.prenatalExam) {
          _.each(rec.prenatalExam, function(peRec) {
            // Favor the alternateEdd if the useAlternateEdd is specified.
            if (rec.useAlternateEdd && rec.alternateEdd) {
              peRec.ga = getGA(rec.alternateEdd, moment(peRec.date).format('YYYY-MM-DD'));
            } else if (rec.edd || rec.alternateEdd) {
              peRec.ga = getGA(rec.edd || rec.alternateEdd, moment(peRec.date).format('YYYY-MM-DD'));
            } else {
              peRec.ga = '';
            }
            peRec.examiner = userMap[""+peRec.updatedBy]['username'];
            if (peRec.supervisor) peRec.examiner += '/' + userMap[""+peRec.supervisor]['username'];
          });
        }

        if (rec) req.paramPregnancy = rec;

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
 * history()
 *
 * Render the history page for the pregnancy.
 * -------------------------------------------------------- */
var history = function(req, res) {
  var data = {
        title: req.gettext('Pregnancy History')
        , user: req.session.user
        , messages: req.flash()
        , rec: req.paramPregnancy
      }
    ;
  if (req.paramPregnancy) {
    User.getUserIdMap()
      .then(function(users) {
        Pregnancy.forge({id: req.paramPregnancy.id})
          .historyData(req.paramPregnancy.id)
          .then(function(list) {
            var options = {};
            options.sid = req.sessionID;
            options.user_id = req.session.user.id;
            options.pregnancy_id = req.paramPregnancy.id;
            Event.historyEvent(options).then(function() {
              data.history = list;
              data.users = users;
              res.render('history', data);
            });
          });
      })
      .caught(function(err) {
        logError(err);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
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
   , rp   // riskPresent
   , ro   // riskObHx
   , rm   // riskMedHx
   , rl   // riskLifestyle
   , us   // useIodizedSalt
   , fg   // finalGAPeriod
   , et   // episTear
   , er   // repaired (referring to the epis)
   , bf   // BFedPeriod
   , tod = 'NSD' // type of delivery - defaults to NSD
   , mf   // male or female
   , at   // attendant
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
      rp = adjustSelectData(riskPresent, req.paramPregnancy.riskPresent);
      ro = adjustSelectData(riskObHx, req.paramPregnancy.riskObHx);
      rm = adjustSelectData(riskMedHx, req.paramPregnancy.riskMedHx);
      rl = adjustSelectData(riskLifestyle, req.paramPregnancy.riskLifestyle);

      if (_.isUndefined(req.paramPregnancy.riskPresent)) req.paramPregnancy.riskPresent = '';
      if (_.isUndefined(req.paramPregnancy.riskObHx)) req.paramPregnancy.riskObHx = '';
      if (_.isUndefined(req.paramPregnancy.riskMedHx)) req.paramPregnancy.riskMedHx = '';
      if (_.isUndefined(req.paramPregnancy.riskLifestyle)) req.paramPregnancy.riskLifestyle = '';
    }

    // Add or edit prenatal examinations.
    if (path === cfg.path.pregnancyPrenatalExamAdd) {
      ed = adjustSelectData(edema, void(0));
    }
    if (path === cfg.path.pregnancyPrenatalExamEdit) {
      ed = adjustSelectData(edema, req.paramPrenatalExam.edema);
      if (_.isUndefined(req.paramPrenatalExam.edema)) req.paramPrenatalExam.edema = '';
    }

    // Questionnaire page.
    if (path === cfg.path.pregnancyQuesEdit) {
      us = adjustSelectData(yesNoUnanswered, req.paramPregnancy.useIodizedSalt);
      if (_.isUndefined(req.paramPregnancy.useIodizedSalt)) req.paramPregnancy.useIodizedSalt = '';
    }

    // Add or edit pregnancy histories.
    if (path === cfg.path.pregnancyHistoryAdd) {
      fg = adjustSelectData(wksMths, void(0));
      et = adjustSelectData(yesNoUnknown, void(0));
      er = adjustSelectData(yesNoUnknown, void(0));
      bf = adjustSelectData(wksMthsYrs, void(0));
      mf = adjustSelectData(maleFemale, void(0));
      at = adjustSelectData(attendant, void(0));
    }
    if (path === cfg.path.pregnancyHistoryEdit) {
      fg = adjustSelectData(wksMths, req.paramPregHist.finalGAPeriod);
      et = adjustSelectData(yesNoUnknown, req.paramPregHist.episTear);
      er = adjustSelectData(yesNoUnknown, req.paramPregHist.repaired);
      bf = adjustSelectData(wksMthsYrs, req.paramPregHist.howLongBFedPeriod);
      mf = adjustSelectData(maleFemale, req.paramPregHist.sexOfBaby);
      at = adjustSelectData(attendant, req.paramPregHist.attendant);
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
    , riskPresent: rp
    , riskObHx: ro
    , riskMedHx: rm
    , riskLifestyle: rl
    , useIodizedSalt: us
    , finalGAPeriod: fg
    , episTear: et
    , repaired: er
    , howLongBFedPeriod: bf
    , defaultTypeOfDelivery: tod
    , sexOfBaby: mf
    , attendant: at
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
        takingMedication: '0', planToBreastFeed: '0',
        whereDeliver: '', birthCompanion: '',
        practiceFamilyPlanning: '0', practiceFamilyPlanningDetails: '',
        familyHistoryTwins: '0', familyHistoryHighBloodPressure: '0',
        familyHistoryDiabetes: '0', familyHistoryChestPains: '0',
        familyHistoryTB: '0', familyHistorySmoking: '0',
        familyHistoryNone: '0', historyFoodAllergy: '0',
        historyMedicineAllergy: '0', historyAsthma: '0',
        historyChestPains: '0', historyKidneyProblems: '0',
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
  var ms = adjustSelectData(maritalStatus,
        req.paramPregnancy? req.paramPregnancy.maritalStatus: void(0))
    , rel = adjustSelectData(religion,
        req.paramPregnancy? req.paramPregnancy.religion: void(0))
    , edu = adjustSelectData(education,
        req.paramPregnancy? req.paramPregnancy.education: void(0))
    , partEdu = adjustSelectData(education,
        req.paramPregnancy? req.paramPregnancy.partnerEducation: void(0))
    , clientInc = adjustSelectData(incomePeriod,
        req.paramPregnancy? req.paramPregnancy.clientIncomePeriod: void(0))
    , partnerInc = adjustSelectData(incomePeriod,
        req.paramPregnancy? req.paramPregnancy.partnerIncomePeriod: void(0))
    , schRec
    , prenatalDay = adjustSelectData(dayOfWeek, void(0))
    , prenatalLoc = adjustSelectData(location, void(0))
    ;

  // --------------------------------------------------------
  // Store the prenatal scheduling for the client in the record.
  // --------------------------------------------------------
  if (req.paramPregnancy) {
    schRec = _.find(req.paramPregnancy.schedule, function(obj) {
      return obj.scheduleType === 'Prenatal';
    });
    if (schRec) {
      req.paramPregnancy.prenatalSchedule = {
        id: schRec.id
        , day: getAbbr(schRec.day)
        , location: schRec.location
      };
      prenatalDay = adjustSelectData(dayOfWeek, schRec.day);
      prenatalLoc = adjustSelectData(location, req.paramPregnancy.prenatalSchedule.location);
    } else {req.paramPregnancy.prenatalSchedule = {};}
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
    , rec: req.paramPregnancy
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
    , prenatalLoc = req.body.prenatalLocation.length > 0? req.body.prenatalLocation: null
    , prenatalDay = req.body.prenatalDay.length > 0? req.body.prenatalDay: null
    , pregFlds = _.omit(req.body, ['_csrf', 'dob'])
    , patFlds = {}
    , schFlds = {}
    ;

  if (hasRole(req, 'attending')) {
    common.supervisor = req.session.supervisor.id;
  }
  pregFlds = _.extend(pregFlds, common);
  patFlds = _.extend(common, {dob: dob, dohID: doh});
  schFlds = {scheduleType: 'Prenatal', location: prenatalLoc, day: prenatalDay};

  // --------------------------------------------------------
  // Validate the fields.
  // --------------------------------------------------------
  Promise.all([Patient.checkFields(patFlds), Pregnancy.checkFields(pregFlds)])
    .then(function(result) {
      return _.object(['patFlds', 'pregFlds'], result);
    })
    // --------------------------------------------------------
    // Save patient and pregnancy records.
    // --------------------------------------------------------
    .then(function(flds) {
      Patient
        .forge(flds.patFlds)
        .setUpdatedBy(req.session.user.id)
        .setSupervisor(common.supervisor)
        .save()
        .then(function(patient) {
          var pregFields = _.extend(flds.pregFlds, {patient_id: patient.get('id')});
          Pregnancy
            .forge(pregFields)
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(common.supervisor)
            .save()
            .then(function(pregnancy) {
              schFlds.pregnancy_id = pregnancy.get('id');
              Schedule
                .forge(schFlds)
                .setUpdatedBy(req.session.user.id)
                .setSupervisor(common.supervisor)
                .save().then(function() {
                  req.flash('info', req.gettext('Pregnancy was created.'));
                  res.redirect(cfg.path.pregnancyEditForm.replace(/:id/, pregnancy.get('id')));
                });
            })
            .caught(function(e) {
              logError('Error saving pregnancy record. Orphan patient record id: ' + patient.get('id'));
              throw e;
            });
        })
        .caught(function(e) {
          logError('Error saving patient record: ' + e);
          throw e;
        });
    })
    .caught(function(e) {
      logError(e);
      res.status(406);
      res.end();    // TODO: need a custom 406 page.
    });
};

/* --------------------------------------------------------
 * generalEditSave()
 *
 * Update the main patient record (general information).
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
    , supervisor = null;
    ;
  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.id &&
      req.paramPregnancy.id == req.body.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }
    pregFlds = _.omit(req.body, ['_csrf', 'doh', 'dob', 'priority',
        'prenatalDay', 'prenatalLocation']);
    patFlds = {dohID: doh, dob: dob};
    patFlds = _.extend(patFlds, {id: req.paramPregnancy.patient_id});
    schFlds = {scheduleType: 'Prenatal', location: prenatalLoc,
      day: prenatalDay, pregnancy_id: req.paramPregnancy.id};
    if (scheduleId !== null) schFlds.id = scheduleId;
    Pregnancy.checkFields(pregFlds).then(function(flds) {
      Pregnancy.forge(flds)
        .setUpdatedBy(req.session.user.id)
        .setSupervisor(supervisor)
        .save().then(function() {
          Schedule
            .forge(schFlds)
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(supervisor)
            .save().then(function() {
              Patient
                .forge(patFlds)
                .setUpdatedBy(req.session.user.id)
                .setSupervisor(supervisor)
                .save()
                .then(function(patient) {
                  req.flash('info', req.gettext('Pregnancy was updated.'));
                  res.redirect(cfg.path.pregnancyEditForm.replace(/:id/, flds.id));
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
                })
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
    ;
  if (req.paramPregnancy) {
    res.render('prenatal', data);
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
    , defaultFlds = {
        philHealthMCP: '0'
        , philHealthNCP: '0'
        , philHealthApproved: '0'
        , useAlternateEdd: '0'
        , sureLMP: '0'
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
    pnFlds = _.defaults(_.omit(req.body, ['_csrf']), defaultFlds);

    // --------------------------------------------------------
    // If the edd is not filled in and the lmp is, calculate
    // the edd if the useAlternateEdd is not selected. Note
    // that the client side does the same thing when the user
    // leaves the lmp field, but if <Enter> is pressed while
    // in the lmp field, this will pick it up.
    // --------------------------------------------------------
    if (pnFlds.edd.length === 0 &&
        pnFlds.lmp.length !== 0 &&
        pnFlds.useAlternateEdd === '0') {
      pnFlds.edd = calcEdd(pnFlds.lmp);
    }

    Pregnancy.forge({id: pnFlds.id})
      .fetch().then(function(pregnancy) {
        pregnancy
          .setUpdatedBy(req.session.user.id)
          .setSupervisor(supervisor)
          .save(pnFlds).then(function(pregnancy) {
            req.flash('info', req.gettext('Pregnancy was updated.'));
            res.redirect(cfg.path.pregnancyPrenatalEdit.replace(/:id/, pregnancy.id));
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
  } else {
    logError('Error in update of prenatal information: pregnancy not found.');
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * labsForm()
 *
 * Displays the main labs page that contains many sub-sections
 * covering labs, etc.
 * -------------------------------------------------------- */
var labsForm = function(req, res) {
  var data
    , suiteDefs = []
    , labResults = []
    , referrals = []
    , vaccinations = []
    , medications = []
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
            , tests: testNames
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
        _.each(ltResults.toJSON(), function(result) {
            var r = _.omit(result, ['updatedBy','updatedAt','supervisor','LabTest']);
            r.name = result.LabTest.name;
            labResults.push(r);
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
        var refList = [];
        _.each(refs, function(ref) {
          ref.date = moment(ref.date).format('YYYY-MM-DD');
          refList.push(ref);
        });
        refList = _.sortBy(refList, 'date');
        referrals = refList;
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
          vac.vacDate = moment(vac.vacDate).format('YYYY-MM-DD');
          vacList.push(vac);
        });
        vacList = _.sortBy(vacList, 'id');
        vaccinations = vacList;
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
  , labsForm: labsForm
  , doctorDentistSave: doctorDentistSave
  , load: load
  , history: history
  , getCommonFormData: getCommonFormData
};

