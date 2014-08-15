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
  ;


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
  }];

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

};

module.exports = {
  form: form
  , run: run
};


