/* 
 * -------------------------------------------------------------------------------
 * report.js
 *
 * Handles user selection and processing of all reports.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , cfg = require('../config')
  , deworming = require('./dewormingRpt')
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
    }
    ;
  // TODO: create reportType as a select instead of this hack.
  data.reportType = [{
    selectKey: 'deworming'
    , selected: false
    , label: 'Deworming Report'
  }];
  res.render('reports', data);
};


/* --------------------------------------------------------
 * run()
 *
 * Runs the user selected report.
 * -------------------------------------------------------- */
var run = function(req, res) {
  console.log('report.run()');

  deworming.run(req, res);

};

module.exports = {
  form: form
  , run: run
};


