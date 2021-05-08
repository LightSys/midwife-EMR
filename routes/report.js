/* 
 * -------------------------------------------------------------------------------
 * report.js
 *
 * Handles user selection and processing of all reports.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , cfg = require('../config')
  , User = require('../models').User
  , Users = require('../models').Users
  , dewormingRpt = require('./dewormingRpt')
  , dewormingRptDistBaran = require('./dewormingRptDistBaran')
  , iron = require('./ironRpt')
  , vaccinationRpt = require('./vaccinationRpt')
  , vaccinationRptDistBaran = require('./vaccinationRptDistBaran')
  , summaryRpt = require('./summaryRpt')
  , dohMasterList = require('./dohMasterListRpt')
  , philHealthDailyRpt = require('./philHealthDailyRpt')
  , inactiveRpt = require('./inactiveRpt')
  , vitaminARpt = require('./vitaminARpt')
  , vitaminARptDistBaran = require('./vitaminARptDistBaran')
  , bcgRpt = require('./bcgRpt')
  , bcgRptDistBaran = require('./bcgRptDistBaran')
  , hepbRpt = require('./hepbRpt')
  , hepbRptDistBaran = require('./hepbRptDistBaran')
  , birthCertificateRpt = require('./birthCertificateRpt')
  , scheduledRpt = require('./scheduledRpt')
  , scheduledRptByName = require('./scheduledRptByName')
  , dueRpt = require('./dueRpt')
  , treatedRpt = require('./treatedRpt')
  , FORMAT_SCREEN = require('./reportGeneral.js').FORMAT_SCREEN
  , FORMAT_PDF = require('./reportGeneral.js').FORMAT_PDF
  , FORMAT_CSV = require('./reportGeneral.js').FORMAT_CSV
  ;

/* --------------------------------------------------------
 * summary()
 *
 * Generates the summary report for the current pregnancy.
 * -------------------------------------------------------- */
var summary = function summary(req, res) {
  var id = req.params.id
    ;
  if (! id) {
    req.flash('warning', req.gettext('Pregnancy id not specified.'));
    // TODO: fix with better path that still shows flash messages.
    return res.redirect(cfg.path.search);
  }
  summaryRpt.run(req, res);
};

/* --------------------------------------------------------
 * form()
 *
 * Displays the report selection form.
 * -------------------------------------------------------- */
var form = function(req, res) {
  var data = {
        title: req.gettext('Reports')
        , user: req.session.user
        , messages: req.flash()
      }
    ;
  // TODO: create reportType as a select instead of this hack.
  data.reportType = [{
    selectKey: 'deworming'
    , selected: false
    , label: 'Deworming Report'
  }
  , {
    selectKey: 'dewormingDistBaran'
    , selected: false
    , label: 'Deworming by Dist/Barangay'
  }
  , {
    selectKey: 'iron1'
    , selected: false
    , label: 'Iron Given Date 1'
  }
  , {
    selectKey: 'iron2'
    , selected: false
    , label: 'Iron Given Date 2'
  }
  , {
    selectKey: 'iron3'
    , selected: false
    , label: 'Iron Given Date 3'
  }
  , {
    selectKey: 'iron4'
    , selected: false
    , label: 'Iron Given Date 4'
  }
  , {
    selectKey: 'iron5'
    , selected: false
    , label: 'Iron Given Date 5'
  }
  , {
    selectKey: 'dohmasterlist'
    , selected: false
    , label: 'DOH Master List'
  }
  , {
    selectKey: 'philHealthDaily'
    , selected: false
    , label: 'PhilHealth Daily'
  }
  , {
    selectKey: 'vaccine1'
    , selected: false
    , label: 'TT/Td Given Date 1'
  }
  , {
    selectKey: 'vaccine2'
    , selected: false
    , label: 'TT/Td Given Date 2'
  }
  , {
    selectKey: 'vaccine3'
    , selected: false
    , label: 'TT/Td Given Date 3'
  }
  , {
    selectKey: 'vaccine4'
    , selected: false
    , label: 'TT/Td Given Date 4'
  }
  , {
    selectKey: 'vaccine5'
    , selected: false
    , label: 'TT/Td Given Date 5'
  }
  , { selectKey: 'vaccineDistBaran1'
    , selected: false
    , label: 'TT/Td Given 1 by Dist/Barangay'
  }
  , { selectKey: 'vaccineDistBaran2'
    , selected: false
    , label: 'TT/Td Given 2 by Dist/Barangay'
  }
  , { selectKey: 'vaccineDistBaran3'
    , selected: false
    , label: 'TT/Td Given 3 by Dist/Barangay'
  }
  , { selectKey: 'vaccineDistBaran4'
    , selected: false
    , label: 'TT/Td Given 4 by Dist/Barangay'
  }
  , { selectKey: 'vaccineDistBaran5'
    , selected: false
    , label: 'TT/Td Given 5 by Dist/Barangay'
  }
  , {
    selectKey: 'inactive'
    , selected: false
    , label: 'Inactive Report'
  }
  , {
    selectKey: 'vitaminA'
    , selected: false
    , label: 'Vitamin A'
  }
  , {
    selectKey: 'vitaminADistBaran'
    , selected: false
    , label: 'Vitamin A by Dist/Barangay'
  }
  , {
    selectKey: 'bcg'
    , selected: false
    , label: 'BCG Report'
  }
  , {
    selectKey: 'bcgDistBaran'
    , selected: false
    , label: 'BCG Report by Dist/Barangay'
  }
  , {
    selectKey: 'hepb'
    , selected: false
    , label: 'Hep B Report'
  }
  , {
    selectKey: 'hepbDistBaran'
    , selected: false
    , label: 'Hep B by Dist/Barangay'
  }
  , {
    selectKey: 'scheduled'
    , selected: false
    , label: 'Scheduled Report'
  }
  , {
    selectKey: 'scheduledByName'
    , selected: false
    , label: 'Scheduled Report by Name'
  }
  , {
    selectKey: 'due'
    , selected: false
    , label: 'Due Report'
  }
  , {
    selectKey: 'treated'
    , selected: false
    , label: 'Treated Report'
  }
  ];

  new Users()
    .fetch({withRelated: 'role'})
    .then(function(list) {
      var supers = [{selectKey: '', selected: true, label: ''}]
        ;
      list.forEach(function(rec) {
        var role = rec.related('role').toJSON()
          , superRec = {}
          ;
        if (role.name === 'supervisor') {
          superRec.selectKey = rec.get('id');
          superRec.selected = false;
          superRec.label = rec.get('lastname') + ', ' + rec.get('firstname');
          supers.push(superRec);
        }
      });
      data.inCharge = supers;
      res.render('reports', data);
    });
};

/* --------------------------------------------------------
 * runPdf()
 *
 * Runs the user selected report with PDF format.
 * -------------------------------------------------------- */
var runPdf = function(req, res) {
  req.body.reportFormat = FORMAT_PDF;
  return runReport(req, res);
};

/* --------------------------------------------------------
 * run()
 *
 * Runs the user selected report with screen format.
 * -------------------------------------------------------- */
var run = function(req, res) {
  req.body.reportFormat = FORMAT_SCREEN;
  return runReport(req, res);
};

/* --------------------------------------------------------
 * runReport()
 *
 * Runs the user selected report.
 * -------------------------------------------------------- */
var runReport = function(req, res) {
  var report = req.body && req.body.report || void 0
    ;

  if (report === 'deworming') dewormingRpt.run(req, res);
  if (report === 'dewormingDistBaran') dewormingRptDistBaran.run(req, res);
  if (report === 'iron1') iron.run(req, res);
  if (report === 'iron2') iron.run(req, res);
  if (report === 'iron3') iron.run(req, res);
  if (report === 'iron4') iron.run(req, res);
  if (report === 'iron5') iron.run(req, res);
  if (report === 'vaccine1') vaccinationRpt.run(req, res);
  if (report === 'vaccine2') vaccinationRpt.run(req, res);
  if (report === 'vaccine3') vaccinationRpt.run(req, res);
  if (report === 'vaccine4') vaccinationRpt.run(req, res);
  if (report === 'vaccine5') vaccinationRpt.run(req, res);
  if (report === 'vaccineDistBaran1') vaccinationRptDistBaran.run(req, res);
  if (report === 'vaccineDistBaran2') vaccinationRptDistBaran.run(req, res);
  if (report === 'vaccineDistBaran3') vaccinationRptDistBaran.run(req, res);
  if (report === 'vaccineDistBaran4') vaccinationRptDistBaran.run(req, res);
  if (report === 'vaccineDistBaran5') vaccinationRptDistBaran.run(req, res);
  if (report === 'dohmasterlist') dohMasterList.run(req, res);
  if (report === 'philHealthDaily') philHealthDailyRpt.run(req, res);
  if (report === 'inactive') inactiveRpt.run(req, res);
  if (report === 'vitaminA') vitaminARpt.run(req, res);
  if (report === 'vitaminADistBaran') vitaminARptDistBaran.run(req, res);
  if (report === 'bcg') bcgRpt.run(req, res);
  if (report === 'bcgDistBaran') bcgRptDistBaran.run(req, res);
  if (report === 'hepb') hepbRpt.run(req, res);
  if (report === 'hepbDistBaran') hepbRptDistBaran.run(req, res);
  if (report === 'scheduled') scheduledRpt.run(req, res);
  if (report === 'scheduledByName') scheduledRptByName.run(req, res);
  if (report === 'due') dueRpt.run(req, res);
  if (report === 'treated') treatedRpt.run(req, res);
};

/* --------------------------------------------------------
 * birthCertificate()
 *
 * Runs the birth certificate report.
 * -------------------------------------------------------- */
var birthCertificate = function(req, res) {
  birthCertificateRpt.run(req, res);
};

module.exports = {
  form: form
  , run: run
  , runPdf: runPdf
  , summary: summary
  , birthCertificate
};
