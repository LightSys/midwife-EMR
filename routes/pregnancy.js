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
  , LabTestValue = require('../models').LabTestValue
  , LabTestValues = require('../models').LabTestValues
  , LabTestResult = require('../models').LabTestResult
  , LabTestResults = require('../models').LabTestResults
  , Referral = require('../models').Referral
  , Referrals = require('../models').Referrals
  , Event = require('../models').Event
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , getGA = require('../util').getGA
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
        , 'prenatalExam']})
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
          // TODO: use req.route instead for this test.
          // --------------------------------------------------------
          if (op === 'preghistoryedit' || op === 'preghistorydelete') {
            req.paramPregHist = _.find(rec.pregnancyHistory, function(r) {
              return r.id === id2;
            });
          }
          // --------------------------------------------------------
          // Prenatal exams.
          // --------------------------------------------------------
          if (op === 'prenatalexamedit' || op === 'prenatalexamdelete') {
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
          if (op === 'labedit' || op === 'labdelete') {
            req.paramLabTestResultId = id2;
          }
          // --------------------------------------------------------
          // Referrals
          // --------------------------------------------------------
          if (op === 'referraledit' || 'referraldelete') {
            req.paramReferralId = id2;
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
    if (path === cfg.path.pregnancyPrenatalExamAddForm) {
      ed = adjustSelectData(edema, void(0));
    }
    if (path === cfg.path.pregnancyPrenatalExamEditForm) {
      ed = adjustSelectData(edema, req.paramPrenatalExam.edema);
      if (_.isUndefined(req.paramPrenatalExam.edema)) req.paramPrenatalExam.edema = '';
    }

    // Labs page.
    if (path === cfg.path.pregnancyLabsEditForm) {

    }

    // Questionnaire page.
    if (path === cfg.path.pregnancyQuesEdit) {
      us = adjustSelectData(yesNoUnanswered, req.paramPregnancy.useIodizedSalt);
      if (_.isUndefined(req.paramPregnancy.useIodizedSalt)) req.paramPregnancy.useIodizedSalt = '';
    }

    // Midwife interview page.
    if (path === cfg.path.pregnancyMidwifeEdit) {

    }

    // Add or edit pregnancy histories.
    if (path === cfg.path.pregnancyHistoryAddForm) {
      fg = adjustSelectData(wksMths, void(0));
      et = adjustSelectData(yesNoUnknown, void(0));
      er = adjustSelectData(yesNoUnknown, void(0));
      bf = adjustSelectData(wksMthsYrs, void(0));
      mf = adjustSelectData(maleFemale, void(0));
      at = adjustSelectData(attendant, void(0));
    }
    if (path === cfg.path.pregnancyHistoryEditForm) {
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
 * quesEdit()
 *
 * Display the pregnancy questionnaire form.
 * -------------------------------------------------------- */
var quesEdit = function(req, res) {
  var data = {title: req.gettext('Pregnancy Questionnaire')};
  if (req.paramPregnancy) {
    res.render('pregnancyQuestionnaire', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * quesUpdate()
 *
 * Update the pregnancy record with the questionnaire data.
 * -------------------------------------------------------- */
var quesUpdate = function(req, res) {
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
 * addForm()
 *
 * Display the form to create a new pregnancy record.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var addForm = function(req, res) {
  var data = {title: req.gettext('New Client Record') }
    ;
  res.render('pregnancyAddForm', getEditFormData(req, data));
};

/* --------------------------------------------------------
 * getEditFormData()
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
    ;
  return _.extend(addData, {
    user: req.session.user
    , messages: req.flash()
    , marital: ms
    , religion: rel
    , education: edu
    , partnerEducation: partEdu
    , clientIncomePeriod: clientInc
    , partnerIncomePeriod: partnerInc
    , rec: req.paramPregnancy
  });
};

/* --------------------------------------------------------
 * editForm()
 *
 * Displays the edit form for the pregnancy.
 *
 * param
 * return
 * -------------------------------------------------------- */
var editForm = function(req, res) {
  var data = {title: req.gettext('Edit Client')};
  if (req.paramPregnancy) {
    res.render('pregnancyEditForm', getEditFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * create()
 *
 * Create a new patient record and the corresponding pregnancy
 * record to go along with it. Insures that the required fields
 * are provided otherwise does not change the database.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var create = function(req, res) {
  var common = {
        updatedBy: req.session.user.id
        , supervisor: null
      }
    , dob = req.body.dob.length > 0? req.body.dob: null
    , doh = req.body.doh.length > 0? req.body.doh: null
    , pregFlds = _.omit(req.body, ['_csrf', 'dob'])
    , patFlds = {}
    ;

  if (hasRole(req, 'attending')) {
    common.supervisor = req.session.supervisor.id;
  }
  pregFlds = _.extend(pregFlds, common);
  patFlds = _.extend(common, {dob: dob, dohID: doh});

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
              req.flash('info', req.gettext('Pregnancy was created.'));
              res.redirect(cfg.path.pregnancyEditForm.replace(/:id/, pregnancy.get('id')));
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
 * update()
 *
 * Update the main patient record (general information).
 * -------------------------------------------------------- */
var update = function(req, res) {
  var pregFlds
    , patFlds
    , dob = req.body.dob.length > 0? req.body.dob: null
    , doh = req.body.doh.length > 0? req.body.doh: null
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
    pregFlds = _.omit(req.body, ['_csrf', 'doh', 'dob', 'priority']);
    patFlds = {dohID: doh, dob: dob};
    patFlds = _.extend(patFlds, {id: req.paramPregnancy.patient_id});
    Pregnancy.checkFields(pregFlds).then(function(flds) {
      Pregnancy.forge(flds)
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
 * midwifeEdit()
 *
 * Display the midwife interview screen.
 * -------------------------------------------------------- */
var midwifeEdit = function(req, res) {
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
 * midwifeUpdate()
 *
 * Update the patient, pregnancy and pregnancyHistory records
 * with changes from the midwife interview screen.
 * -------------------------------------------------------- */
var midwifeUpdate = function(req, res) {
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
 * pregnancyHistoryAddForm()
 *
 * Displays the historical pregnancy form for adding.
 * -------------------------------------------------------- */
var pregnancyHistoryAddForm = function(req, res) {
  var data = {title: req.gettext('Add Historical Pregnancy')};
  if (req.paramPregnancy) {
    res.render('midwifeInterviewAddPreg', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * pregnancyHistoryEditForm()
 *
 * Displays the historical pregnancy form for editing.
 * -------------------------------------------------------- */
var pregnancyHistoryEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Historical Pregnancy')};
  if (req.paramPregnancy) {
    res.render('midwifeInterviewEditPreg', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * pregnancyHistoryEdit()
 *
 * Updates the historical pregnancy record.
 * -------------------------------------------------------- */
var pregnancyHistoryEdit = function(req, res) {
  var supervisor = null
    , flds = req.body
    , pregHistRec
    , defaultFlds = {
        FT: '0'
      }
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // Allow 'unchecking' a box by providing a default of off.
    // --------------------------------------------------------
    flds = _.extend(defaultFlds, _.omit(flds, ['_csrf']));

    pregHistRec = new PregnancyHistory(flds);
    pregHistRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save(flds, {method: 'update'}).then(function(model) {
        var path = cfg.path.pregnancyHistoryEditForm
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        path = path.replace(/:id2/, flds.id);
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    logError('Error in update of pregnancyHistory: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * pregnancyHistoryAdd()
 *
 * Adds a new historical pregnancy record. Called from the
 * midwife interview screen.
 * -------------------------------------------------------- */
var pregnancyHistoryAdd = function(req, res) {
  var supervisor = null
    , flds = req.body
    , pregHistRec
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }
    pregHistRec = new PregnancyHistory(flds);
    pregHistRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save().then(function(model) {
        res.redirect(cfg.path.pregnancyHistoryAddForm.replace(/:id/, model.get('pregnancy_id')));
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });

  } else {
    logError('Error in update of pregnancyHistory: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * pregnancyHistoryDelete()
 *
 * Deletes a new historical pregnancy record. Called from the
 * midwife interview screen.
 * -------------------------------------------------------- */
var pregnancyHistoryDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    , pregHistRec
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }
    flds.id = parseInt(flds.id, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    pregHistRec = new PregnancyHistory({id: flds.id, pregnancy_id: flds.pregnancy_id});
    pregHistRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyMidwifeEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    logError('Error in update of pregnancyHistory: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * prenatalEdit()
 *
 * Display the edit form for the prenatal information.
 * -------------------------------------------------------- */
var prenatalEdit = function(req, res) {
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
 * prenatalUpdate()
 *
 * Update the high-level prenatal information about the
 * pregnancy.
 * -------------------------------------------------------- */
var prenatalUpdate = function(req, res) {
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

var prenatalExamAddForm = function(req, res) {
  var data = {title: req.gettext('Add Prenatal Exam')};
  if (req.paramPregnancy) {
    res.render('prenatalAddEditExam', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * clerkPermittedFields()()
 *
 * Clerks have restrictions on which fields they can change
 * on prenatal exams. Clerks can only change these fields:
 *    weight, systolic, diastolic, date
 *
 * These fields necessarily need to have values:
 *    id, pregnancy_id, _csrf
 *
 * Therefore, only the allowed fields are returned.
 *
 * param    flds - the flds fron req.body
 * return   flds - the flds that are allowed
 * -------------------------------------------------------- */
var clerkPermittedFields = function(flds) {
  return _.pick(flds,
      'weight','systolic','diastolic','date','_csrf','pregnancy_id', 'id');
};

var prenatalExamAdd = function(req, res, next) {
  var supervisor = null
    , flds = req.body
    , disAllowed
    , pass
    , preRec
    , unauth
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // The form should disable the fields that clerks should
    // not change but should that fail, this check will
    // eliminate any fields that are disallowed.
    // --------------------------------------------------------
    if (hasRole(req, 'clerk')) {
      flds = clerkPermittedFields(flds);
    }

    preRec = new PrenatalExam(flds);
    preRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save(flds, {method: 'insert'}).then(function(model) {
        var pregId = model.get('pregnancy_id');
        req.flash('info', req.gettext('Prenatal Exam was saved.'));
        res.redirect(cfg.path.pregnancyPrenatalEdit.replace(/:id/, pregId));
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });

  } else {
    logError('Error in add of prenatal exam: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

var prenatalExamEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Prenatal Exam')};
  if (req.paramPregnancy) {
    res.render('prenatalAddEditExam', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

var prenatalExamEdit = function(req, res) {
  var supervisor = null
    , flds = _.omit(req.body, ['_csrf'])
    , preRec
    , defaultFlds = {
        mvmt: '0'
        , edema: '0'
        , risk: '0'
        , vitamin: '0'
        , pray: '0'
      }
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // The form should disable the fields that clerks should
    // not change but should that fail, this check will
    // eliminate any fields that are disallowed.
    // --------------------------------------------------------
    if (hasRole(req, 'clerk')) {
      flds = clerkPermittedFields(flds);
    }

    // --------------------------------------------------------
    // Allow 'unchecking' a box by providing a default of off.
    // --------------------------------------------------------
    flds = _.defaults(flds, defaultFlds);

    preRec = new PrenatalExam(flds);
    preRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save(flds, {patch: true, method: 'update'}).then(function(model) {
        var path = cfg.path.pregnancyPrenatalEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });

  } else {
    logError('Error in update of pregnancyHistory: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

var prenatalExamDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    , peRec
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }
    flds.id = parseInt(flds.id, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    peRec = new PrenatalExam({id: flds.id, pregnancy_id: flds.pregnancy_id});
    peRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyPrenatalEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    logError('Error in update of pregnancyHistory: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * labsEdit()
 *
 * Displays the main labs page that contains many sub-sections
 * covering labs, etc.
 * -------------------------------------------------------- */
var labsEdit = function(req, res) {
  var data
    , suiteDefs = []
    , labResults = []
    , referrals = []
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
        return new LabTestResults({'pregnancy_id': req.paramPregnancy.id})
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
        return new Referrals({pregnancy_id: req.paramPregnancy.id})
          .fetch();
      })
      // Load the referrals into our list
      .then(function(refs) {
        var refList = [];
        _.each(refs.toJSON(), function(ref) {
          ref.date = moment(ref.date).format('YYYY-MM-DD');
          refList.push(ref);
        });
        refList = _.sortBy(refList, 'date');
        referrals = refList;
      })
      // Prepare the data for the form and return it to the user.
      .then(function() {
        data = getCommonFormData(req, _.extend({title: req.gettext('Labs')},
            {labTests: suiteDefs, labTestResults: labResults, referrals: referrals})
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
 * labAddForm()
 *
 * Displays the form that the user fills out for a specific
 * suite of tests.
 *
 * Note that this is generated via a POST instead of a GET
 * because the user specified in the form which lab suite
 * to use. This produces a form that contains all of the
 * tests within the chosen suite.
 * -------------------------------------------------------- */
var labAddForm = function(req, res) {
  var data
    , suiteId
    , suiteName
    , viewTemplate
    , data
    , qb
    ;
  if (req.paramPregnancy) {
    suiteId = req.body.suite;
    if (suiteId) {
      LabSuite.forge({id: suiteId})
        .fetch()
        .then(function(suite) {
          if (suite) {
            viewTemplate = suite.get('viewTemplate');
            suiteName = suite.get('name');
            // --------------------------------------------------------
            // Load the tests for this suite to pass to the form.
            // --------------------------------------------------------
            new LabTests().query(function(qb) {
                qb.where('labSuite_id', '=', suiteId);
              })
              .fetch({withRelated: ['LabTestValue']})
              .then(function(testList) {
                var labTests = []
                  , formData = {title: req.gettext('Add Lab Test: ') + suiteName}
                  ;

                // --------------------------------------------------------
                // Prepare the test data by putting it into the format used
                // by the Jade select mixins and sorting by value.
                // --------------------------------------------------------
                testList.each(function(test) {
                  labTests.push(labTestFormat(test));
                });

                data = getCommonFormData(req, _.extend(formData, {labTests: labTests}));
                res.render('labs/' + viewTemplate, data);
              });
          } else {
            logWarn('Suite id not found.');
            res.redirect(cfg.path.search);
          }
        });
    } else {
      logWarn('Suite id not passed.');
      res.redirect(cfg.path.search);
    }
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * labAddEdit()
 *
 * Add or update labTestResult records.
 *
 * For new lab results, creates new lab results in the
 * database for a single lab suite which may contain more
 * than one lab test. This results in inserting multiple
 * records into the labTestResult table within one transaction.
 *
 * For updates of lab results, still uses a transaction but
 * existing records are updated rather than inserted.
 * -------------------------------------------------------- */
var labAddEdit = function(req, res) {
  var supervisor = null
    , testDate = req.body.testDate
    , flds = _.omit(req.body, ['_csrf', 'testDate'])
    , testResults = {}
    , isUpdate = _.has(req, 'paramLabTestResultId')
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // Consolidate our results in preparation for storage into
    // the testResults array.
    // --------------------------------------------------------
    _.each(flds, function(val, key) {
      var fldType = key.split('-')[0]
        , testId = key.split('-')[1]
        ;
      if (val.length === 0) return;
      if (! testResults[testId]) {
        testResults[testId] = {
          labTest_id: testId
          , pregnancy_id: req.paramPregnancy.id
          , testDate: moment(testDate).format('YYYY-MM-DD')
          , result: ''
          , result2: ''
          , warn: null
        };
        if (isUpdate) {
          // This is an update, not an insert so add the id.
          // The existence of the id will cause the ORM to
          // do an update rather than an insert into the DB.
          testResults[testId].id = req.paramLabTestResultId;
        }
      }
      if (fldType === 'warn' && val === '1') testResults[testId].warn = true;

      // --------------------------------------------------------
      // Number always overrides the select if both are provided.
      // --------------------------------------------------------
      if (fldType === 'numberLow' &&
        _.isNumber(Number(val))) testResults[testId].result = val;
      if (fldType === 'numberHigh' &&
        _.isNumber(Number(val))) testResults[testId].result2 = val;
      if (fldType === 'number' &&
        _.isNumber(Number(val))) testResults[testId].result = val;
      if (fldType === 'select') {
        if (testResults[testId].result.length === 0) {
          testResults[testId].result = val;
        }
      }
    });

    // --------------------------------------------------------
    // Insert or update all of the records as a single transaction.
    // --------------------------------------------------------
    Bookshelf.DB.knex.transaction(function(t) {
      return Promise.all(_.map(testResults, function(tst) {
        return new Promise(function(resolve, reject) {
          LabTestResult.forge(tst)
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(supervisor)
            .save(null, {transacting: t})
            .then(function(model) {
              logInfo('Saved ' + model.get('id'));
              resolve(model.get('id'));
            })
            .caught(function(err) {
              reject(err);
            });
        });
      }))
      .then(function(rows) {
        t.commit();
        logInfo('Committed ' + rows.length + ' records.');
      }, function(err) {
        logError(err);
        t.rollback();
        logInfo('Transaction was rolled back.');
        req.flash('error', req.gettext('There was a problem and your changes were NOT saved.'));
      })
      .then(function() {
        res.redirect(cfg.path.pregnancyLabsEditForm.replace(/:id/, req.paramPregnancy.id));
      });
    });

  } else {
    logError('Error in update of labAdd(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * labTestFormat()
 *
 * Formats the JSON of a lab test in the format required
 * for the add or edit form.
 *
 * param       labTest - JSON representing labTest with labTestValue
 * param       result - the result the user already chose, if any
 * param       result2 - the high range of the result if a range
 * param       warn - if result, whether warning or not
 * return      labTestFormatted - JSON in correct format
 * -------------------------------------------------------- */
var labTestFormat = function(labTest, result, result2, warn) {
  var labTestOmitFlds = ['LabTestValue', 'updatedBy', 'updatedAt', 'supervisor']
    , data = _.omit(labTest.toJSON(), labTestOmitFlds)
    , ltVals = _.pluck(labTest.related('LabTestValue').toJSON(), 'value')
    , resultInVals = false
    ;
  data.result = result || void(0);
  data.result2 = result2 || void(0);
  data.warn = warn || void(0);
  if (ltVals.length > 0) {
    ltVals = _.map(ltVals, function(val) {
      if (! resultInVals && val === result) {
        resultInVals = true;
      }
      return {
        selectKey: val
        , selected: result && result === val? true: false
        , label: val
      };
    });
    // --------------------------------------------------------
    // Create an empty value as the default value and put it
    // at the top.
    // --------------------------------------------------------
    ltVals.push({selectKey: '', selected: true, label: ''});
    data.values = _.sortBy(ltVals, 'selectKey');
  }

  return data;
};

/* --------------------------------------------------------
 * labEditForm()
 *
 * Displays the form to edit an individual lab test result.
 * -------------------------------------------------------- */
var labEditForm = function(req, res) {
  var ltrId = req.paramLabTestResultId
    ;
  if (req.paramPregnancy && ltrId) {
    LabTestResult.forge({id: ltrId})
      .fetch()
      .then(function(rst) {
        var labTestId = rst.get('labTest_id')
          , result = rst.get('result')
          , result2 = rst.get('result2')
          , warn = rst.get('warn')
          , testDate = rst.get('testDate')
          ;
        LabTest.forge({id: labTestId})
          .fetch({withRelated: ['LabTestValue']})
          .then(function(labTest) {
            LabSuite.forge({id: labTest.get('labSuite_id')})
              .fetch()
              .then(function(suite) {
                var viewTemplate = suite.get('viewTemplate')
                  , formData = {
                    title: req.gettext('Edit Lab Test: ' + labTest.get('name'))
                    , labTestResultId: ltrId
                    , labTestResultDate: moment(testDate).format('YYYY-MM-DD')
                  }
                  , data
                  , ltf = labTestFormat(labTest, result, result2, warn)
                  ;
                data = getCommonFormData(req, _.extend(formData, {labTests: [ltf]}));
                res.render('labs/' + viewTemplate, data);
              });
          });
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * labDelete()
 *
 * Delete a specific labTestResult row.
 * -------------------------------------------------------- */
var labDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramLabTestResultId && req.body.labTestResultId &&
      req.body.labTestResultId == req.paramLabTestResultId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.labTestResultId = parseInt(flds.labTestResultId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    ltr = new LabTestResult({id: flds.labTestResultId,
      pregnancy_id: flds.pregnancy_id});
    ltr
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted labTestResult with id: ' + flds.labTestResultId);
        req.flash('info', req.gettext('Lab Test Result was deleted.'));
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * referralAddForm()
 *
 * Displays the form to add a new referral.
 * -------------------------------------------------------- */
var referralAddForm = function(req, res) {
  var data = {title: req.gettext('Add Referral')};
  if (req.paramPregnancy) {
    res.render('referralAddEditForm', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * referralEditForm()
 *
 * Displays the form to edit or delete an existing referral.
 * -------------------------------------------------------- */
var referralEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Referral')};
  if (req.paramPregnancy && req.paramReferralId) {
    var refId = req.paramReferralId
      ;
    Referral.forge({id: refId})
      .fetch()
      .then(function(model) {
        var referral = _.omit(model.toJSON(), ['updatedBy', 'updatedAt', 'supervisor'])
          ;
        referral.date = moment(referral.date).format('YYYY-MM-DD');
        data.referralRec = referral;
        res.render('referralAddEditForm', getCommonFormData(req, data));
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * referralAddEdit()
 *
 * Adds new referrals to the database or updates existing
 * referrals.
 * -------------------------------------------------------- */
var referralAddEdit = function(req, res) {
  var supervisor = null
    , flds = _.omit(req.body, ['_csrf'])
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // If this is an update, set the id so that the ORM does
    // an update rather than an insert.
    if (req.paramReferralId) {
      flds.id = req.paramReferralId;
    }

    // --------------------------------------------------------
    // Insert into database after sanity check.
    // --------------------------------------------------------
    Referral.checkFields(flds).then(function(flds) {
      Referral.forge(flds)
        .setUpdatedBy(req.session.user.id)
        .setSupervisor(supervisor)
        .save()
        .then(function(model) {
          var path = cfg.path.pregnancyLabsEdit
            ;
          path = path.replace(/:id/, flds.pregnancy_id);
          req.flash('info', req.gettext('Referral was saved.'));
          res.redirect(path);
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
    logError('Error in update of referralAddEdit(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * referralDelete()
 *
 * Deletes a referral from the database.
 * -------------------------------------------------------- */
var referralDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramReferralId && req.body.referralId &&
      req.body.referralId == req.paramReferralId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.referralId = parseInt(flds.referralId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    ref = new Referral({id: flds.referralId, pregnancy_id: flds.pregnancy_id});
    ref
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted Referral with id: ' + flds.referralId);
        req.flash('info', req.gettext('Referral was deleted.'));
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }

};

// --------------------------------------------------------
// Initialize the module.
// --------------------------------------------------------
init();

module.exports = {
  addForm: addForm
  , create: create
  , load: load
  , editForm: editForm
  , update: update
  , history: history
  , quesEdit: quesEdit
  , quesUpdate: quesUpdate
  , midwifeEdit: midwifeEdit
  , midwifeUpdate: midwifeUpdate
  , pregnancyHistoryAddForm: pregnancyHistoryAddForm
  , pregnancyHistoryAdd: pregnancyHistoryAdd
  , pregnancyHistoryEditForm: pregnancyHistoryEditForm
  , pregnancyHistoryEdit: pregnancyHistoryEdit
  , pregnancyHistoryDelete: pregnancyHistoryDelete
  , prenatalEdit: prenatalEdit
  , prenatalUpdate: prenatalUpdate
  , prenatalExamAddForm: prenatalExamAddForm
  , prenatalExamAdd: prenatalExamAdd
  , prenatalExamEditForm: prenatalExamEditForm
  , prenatalExamEdit: prenatalExamEdit
  , prenatalExamDelete: prenatalExamDelete
  , labsEdit: labsEdit
  , labAddForm: labAddForm
  , labAdd: labAddEdit    // Note: uses same method as labEdit
  , labEditForm: labEditForm
  , labEdit: labAddEdit   // Note: uses same method as labAdd
  , labDelete: labDelete
  , referralAddForm: referralAddForm
  , referralAddEdit: referralAddEdit
  , referralEditForm: referralEditForm
  , referralDelete: referralDelete
};

