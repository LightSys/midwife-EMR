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
  , deworming = require('./dewormingRpt')
  , iron = require('./ironRpt')
  , vaccine = require('./vaccinationRpt')
  , summaryRpt = require('./summaryRpt')
  ;


/* --------------------------------------------------------
 * summary()
 *
 * Generates the summary report for the current pregnancy.
 * -------------------------------------------------------- */
var summary = function summary(req, res) {
  var id = req.param('id')
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
  //, {
    //selectKey: 'vaccine1'
    //, selected: false
    //, label: 'Tetanus Given Date 1'
  //}
  //, {
    //selectKey: 'vaccine2'
    //, selected: false
    //, label: 'Tetanus Given Date 2'
  //}
  ];

  new Users()
    .fetch({withRelated: 'roles'})
    .then(function(list) {
      var supers = [{selectKey: '', selected: true, label: ''}]
        ;
      list.forEach(function(rec) {
        var roles = rec.related('roles').toJSON()
          , superRec = {}
          ;
        if (_.contains(_.pluck(roles, 'name'), 'supervisor')) {
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
 * run()
 *
 * Runs the user selected report.
 * -------------------------------------------------------- */
var run = function(req, res) {
  var report = req.body && req.body.report || void 0
    ;

  if (report === 'deworming') deworming.run(req, res);
  if (report === 'iron1') iron.run(req, res);
  if (report === 'iron2') iron.run(req, res);
  if (report === 'iron3') iron.run(req, res);
  if (report === 'iron4') iron.run(req, res);
  if (report === 'iron5') iron.run(req, res);
  if (report === 'vaccine1') vaccine.run(req, res);
  if (report === 'vaccine2') vaccine.run(req, res);

};

module.exports = {
  form: form
  , run: run
  , summary: summary
};


