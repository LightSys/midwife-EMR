/*
 * -------------------------------------------------------------------------------
 * dewormingRpt.js
 *
 * Required report for health statistics regarding deworming.
 * -------------------------------------------------------------------------------
 */


var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , PDFDocument = require('pdfkit')
  , fs = require('fs')
  , os = require('os')
  , path = require('path')
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , Medication = require('../models').Medication
  , Medications = require('../models').Medications
  , MedicationType = require('../models').MedicationType
  , MedicationTypes = require('../models').MedicationTypes
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , FONTS = require('./reportGeneral').FONTS
  ;


/* --------------------------------------------------------
 * centerText()
 *
 * Writes the specified text centered according to the
 * specified font and fontSize on the specified y coordinate.
 *
 * param      doc
 * param      text
 * param      font
 * param      fontSize
 * param      y
 * return     undefined
 * -------------------------------------------------------- */
var centerText = function(doc, text, font, fontSize, y) {
  var textWidth
    , xpos
    ;
  doc.font(font);
  doc.fontSize(fontSize);
  textWidth = parseInt(doc.widthOfString(text), 10);
  xpos = Math.round((doc.page.width/2) - (textWidth/2));
  doc.text(text, xpos, y);
};

/* --------------------------------------------------------
 * doSiteTitle()
 *
 * Writes the site title at the y coordinate specified.
 *
 * param       doc
 * param       y
 * return      undefined
 * -------------------------------------------------------- */
var doSiteTitle = function(doc, y) {
  centerText(doc, cfg.site.title, FONTS.Helvetica, 18, y);
};

/* --------------------------------------------------------
 * doReportName()
 *
 * Writes the report name at the specified y coordinate.
 *
 * param      doc
 * param      text
 * param      y
 * return     undefined
 * -------------------------------------------------------- */
var doReportName = function(doc, text, y) {
  centerText(doc, text, FONTS.Helvetica, 20, y);
};

/* --------------------------------------------------------
 * doColumnHeader()
 *
 * Writes the column header on the current page.
 *
 * param      doc
 * return     undefined
 * -------------------------------------------------------- */
var doColumnHeader = function(doc) {
  var x = doc.page.margins.left
    , y = 80
    , width = doc.page.width - doc.page.margins.right - doc.page.margins.left
    , height = 40
    ;
  // Outer rectangle
  doc
    .rect(x, y, width, height)
    .stroke();

  // Column dividers
  doc
    .moveTo(x + 180, y)
    .lineTo(x + 180, y + height)
    .moveTo(x + 205, y)
    .lineTo(x + 205, y + height)
    .moveTo(x + 261, y)
    .lineTo(x + 261, y + height)
    .moveTo(x + 293, y)
    .lineTo(x + 293, y + height)
    .moveTo(x + 410, y)
    .lineTo(x + 410, y + height)
    .stroke();

  // Headings
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(12)
    .text('Name', x + 72, y + 10)
    .text('Last', x + 36, y + 25)
    .text('First', x + 108, y + 25)
    .text('Age', x + 181, y + 10)
    .text('LMP', x + 220, y + 10)
    .text('GP', x + 268, y + 10)
    .text('Address', x + 326, y + 10)
    .text('Deworming', x + 461, y + 10)
    .text('Date/Type', x + 416, y + 25)
    .text('Remarks', x + 515, y + 25)
    ;
};

/* --------------------------------------------------------
 * doFromTo()
 *
 * Write the from and to dates that the report covers on
 * the report.
 *
 * param      doc
 * param      from
 * param      to
 * return     undefined
 * -------------------------------------------------------- */
var doFromTo = function(doc, from, to) {
  var fromDate = moment(from).format('MM/DD/YYYY')
    , toDate = moment(to).format('MM/DD/YYYY')
    ;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(11)
    .text('Reporting Period:', 18, 24)
    .font(FONTS.Helvetica)
    .fontSize(10)
    .text(fromDate + ' to ' + toDate, 18, 38);
};

/* --------------------------------------------------------
 * doFooter()
 *
 * Write the totals, page numbering, and inCharge stuff at
 * the bottom of the report.
 *
 * param      doc
 * param      pageNum
 * param      totalPages
 * param      totalRows
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, pageNum, totalPages, totalRows) {
  // Deworming and page
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(13)
    .text('Total Deworming: ' + totalRows, 18, 730)
    .font(FONTS.Helvetica)
    .fontSize(10)
    .text('Page ' + pageNum + ' of ' + totalPages, 18, 745);

  // Logistics in charge
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(13)
    // TODO: replace hard-code
    .text('MONIQUE R. SUVOURNEROS, RM', 370, 730)
    .font(FONTS.Helvetica)
    .fontSize(10)
    .text('Logistics In-charge', 370, 745);
};


/* --------------------------------------------------------
 * getData()
 *
 * Queries the database for the required information. Returns
 * a promise that resolves to an array of data.
 *
 * param      dateFrom
 * param      dateTo
 * return     Promise
 * -------------------------------------------------------- */
var getData = function(dateFrom, dateTo) {
  return new Promise(function(resolve, reject) {
    // First get the ids of the medicines we are interested in.
    new MedicationTypes().query()
      .where('name', 'LIKE', 'Mebendazole%')
      .orWhere('name', 'LIKE', 'Albendazole%')
      .select(['id'])
      .then(function(medTypes) {
        var medTypeIds = _.pluck(medTypes, 'id');
        // Now query the data restricted to those ids.
        new Medications().query()
          .column('medication.id', 'medication.date', 'medication.medicationType', 'medication.numberDispensed', 'medication.note', 'medication.pregnancy_id')
          .join('medicationType', 'medication.medicationType', '=', 'medicationType.id')
          .column('medicationType.name', 'medicationType.description')
          .join('pregnancy', 'medication.pregnancy_id', '=', 'pregnancy.id')
          .column('pregnancy.lastname', 'pregnancy.firstname', 'pregnancy.lmp', 'pregnancy.gravida', 'pregnancy.para', 'pregnancy.address', 'pregnancy.city')
          .join('patient', 'pregnancy.patient_id', '=', 'patient.id')
          .column('patient.dob')
          .where('medication.date', '>=', dateFrom)
          .andWhere('medication.date', '<=', dateTo)
          .whereIn('medication.medicationType', medTypeIds)
          .select()
          .then(function(list) {
            resolve(list);
          })
          .caught(function(err) {
            logError(err);
            reject(err);
          });
      });
  });
};

/* --------------------------------------------------------
 * doCellBorders()
 *
 * Write a single cell's border on the page.
 *
 * param      doc
 * param      x
 * param      y
 * param      width
 * param      height
 * return     undefined
 * -------------------------------------------------------- */
var doCellBorders = function(doc, x, y, width, height) {
  doc
    .moveTo(x, y)
    .lineTo(x + width, y)
    .lineTo(x + width, y + height)
    .lineTo(x, y + height)
    .lineTo(x, y)
    .stroke();
};


/* --------------------------------------------------------
 * doRow()
 *
 * Writes a row on the report including borders and text.
 *
 * param      doc
 * param      data
 * param      rowNum
 * param      rowHeight
 * return     undefined
 * -------------------------------------------------------- */
var doRow = function(doc, data, rowNum, rowHeight) {
  var cells = []
    , startX = doc.page.margins.left
    , startY = 120 + (rowNum * rowHeight)
    , remark = data.note && data.note.length > 0? data.note: ''
    , gravida = data.gravida || 1
    , para = data.para || 0
    ;
  // Create the cell borders
  // Lastname
  doCellBorders(doc, startX, startY, 90, rowHeight);
  // Firstname
  doCellBorders(doc, startX + 90, startY, 90, rowHeight);
  // Age
  doCellBorders(doc, startX + 180, startY, 25, rowHeight);
  // LMP
  doCellBorders(doc, startX + 205, startY, 56, rowHeight);
  // GP
  doCellBorders(doc, startX + 261, startY, 32, rowHeight);
  // Address
  doCellBorders(doc, startX + 293, startY, 117, rowHeight);
  // Date/Type
  doCellBorders(doc, startX + 410, startY, 80, rowHeight);
  // Remarks
  doCellBorders(doc, startX + 490, startY, 86, rowHeight);

  // --------------------------------------------------------
  // Write the row contents.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(11);
  // Lastname
  doc.text(data.lastname.toUpperCase(), startX + 2, startY + 9);
  // Firstname
  doc.text(data.firstname.toUpperCase(), startX + 92, startY + 9);
  // Age
  doc.text(moment().diff(data.dob, 'years'), startX + 185, startY + 9);
  // LMP
  doc
    .fontSize(10)
    .text(moment(data.lmp).format('MM/DD/YYYY'), startX + 207, startY + 9);
  // GP
  doc
    .fontSize(12)
    .text(gravida + '-' + para, startX + 265, startY + 9);
  // Address
  doc
    .fontSize(8)
    .text(data.address.slice(0, 28), startX + 295, startY + 3)
    .text(data.city, startX + 295, startY + 15);
  // Date/Type
  doc
    .fontSize(8)
    .text(moment(data.date).format('MM/DD/YYYY'), startX + 415, startY + 3)
    .text(data.name.split(' ')[0], startX + 415, startY + 15);
  // Remarks
  doc
    .fontSize(6)
    .text(remark.slice(0, 25), startX + 492, startY + 3)
    .text(remark.slice(25, 50), startX + 492, startY + 11)
    .text(remark.slice(50, 75), startX + 492, startY + 18);

};


/* --------------------------------------------------------
 * doPages()
 *
 * Writes all the pages of the report.
 *
 * param      doc
 * param      data
 * param      rowsPerPage
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doPages = function(doc, data, rowsPerPage, opts) {
  var currentRow = 0
    , pageNum = 1
    , totalRows = data.length
    , totalPages = Math.ceil(totalRows / rowsPerPage)
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary.
  // --------------------------------------------------------
  _.each(data, function(rec) {
    if (currentRow === 0) {
      doSiteTitle(doc, 24);
      doReportName(doc, 'DEWORMING', 48);
      doFromTo(doc, opts.fromDate, opts.toDate);
      doColumnHeader(doc);
      doFooter(doc, pageNum, totalPages, totalRows);
    }
    doRow(doc, rec, currentRow, 25);
    currentRow++;
    if (currentRow >= rowsPerPage) {
      doc.addPage();
      currentRow = 0;
      pageNum++;
    }

  });

};

/* --------------------------------------------------------
 * doReport()
 *
 * Manages building of the report.
 *
 * param      flds
 * param      writable
 * return     undefined
 * -------------------------------------------------------- */
var doReport = function(flds, writable) {
  var options = {
        margins: {
          top: 18
          , right: 18
          , left: 18
          , bottom: 18
        }
        , layout: 'portrait'
        , size: 'letter'
        , info: {
            Title: 'Deworming Report'
            , Author: 'Mercy Application'
            , Subject: 'Deworming Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 23    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = moment(flds.dateFrom).format('YYYY-MM-DD');
  opts.toDate = moment(flds.dateTo).format('YYYY-MM-DD');
  opts.inCharge = flds.inCharge || '';

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  // Build the parts of the document.
  getData(opts.fromDate, opts.toDate)
    .then(function(list) {
      opts.totalRows = list.length;
      doPages(doc, list, rowsPerPage, opts);
    })
    .then(function() {
      doc.end();
    });
};

/* --------------------------------------------------------
 * run()
 *
 * Run the deworming report.
 * -------------------------------------------------------- */
var run = function(req, res) {
  var flds = _.omit(req.body, ['_csrf'])
    , filePath = path.join(cfg.site.tmpDir, 'rpt-' + (Math.random() * 9999999999) + '.pdf')
    , writable = fs.createWriteStream(filePath)
    , success = false
    , fieldsReady = true
    ;

  // --------------------------------------------------------
  // Check that required fields are in place.
  // --------------------------------------------------------
  if (! flds.dateFrom || flds.dateFrom.length == 0 || ! moment(flds.dateFrom).isValid()) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must supply a FROM date for the report.'));
  }
  if (! flds.dateTo || flds.dateTo.length == 0 || ! moment(flds.dateTo).isValid()) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must supply a TO date for the report.'));
  }
  if (! flds.inCharge || flds.inCharge.length == 0) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must choose an In Charge person for the report.'));
  }
  if (! fieldsReady) {
    console.log('Deworming report: not all fields supplied.');
    res.redirect(cfg.path.reportForm);
  }

  // --------------------------------------------------------
  // When the report is fully built, write it back to the caller.
  // --------------------------------------------------------
  writable.on('finish', function() {
    fs.createReadStream(filePath).pipe(res);
    res.end();
    fs.unlink(filePath);
  });

  // --------------------------------------------------------
  // Set up the header correctly.
  // --------------------------------------------------------
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', 'inline; MercyReport.pdf');

  doReport(flds, writable);
};


module.exports = {
  run: run
};



