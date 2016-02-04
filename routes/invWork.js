/* 
 * -------------------------------------------------------------------------------
 * invWork.js
 *
 * Invoice Worksheet. This leverages a pet project build with NodeJS 4.2.4, Webpack,
 * ReactJS, Babel, etc. In other words, technologies that Midwife-EMR is not using
 * yet. So, we incorporate the result of the build into Midwife-EMR for now until
 * Midwife-EMR catches up.
 * ------------------------------------------------------------------------------- 
 */

var invoiceWorksheet = function(req, res) {
  var data = {};
  res.render('invoiceWorksheet', data);
}

module.exports = {
  invoiceWorksheet: invoiceWorksheet
}

