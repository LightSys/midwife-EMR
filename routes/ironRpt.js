/*
 * -------------------------------------------------------------------------------
 * ironRpt.js
 *
 * Required report for health statistics regarding iron dispensed.
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
  , User = require('../models').User
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
    .moveTo(x + 220, y)
    .lineTo(x + 220, y + height)
    .moveTo(x + 245, y)
    .lineTo(x + 245, y + height)
    .moveTo(x + 301, y)
    .lineTo(x + 301, y + height)
    .moveTo(x + 333, y)
    .lineTo(x + 333, y + height)
    .moveTo(x + 480, y)
    .lineTo(x + 480, y + height)
    .stroke();

  // Headings
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(12)
    .text('Name', x + 92, y + 10)
    .text('Last', x + 56, y + 25)
    .text('First', x + 158, y + 25)
    .text('Age', x + 221, y + 10)
    .text('LMP', x + 260, y + 10)
    .text('GP', x + 308, y + 10)
    .text('Address', x + 386, y + 10)
    .text('IRON', x + 510, y + 10)
    .text('Pcs.', x + 485, y + 25)
    .text('Date', x + 535, y + 25)
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
 * param      totalPcs
 * param      logisticsName
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, pageNum, totalPages, totalPcs, logisticsName) {
  // Deworming and page
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(13)
    .text('Total Iron: ' + totalPcs, 18, 730)
    .font(FONTS.Helvetica)
    .fontSize(10)
    .text('Page ' + pageNum + ' of ' + totalPages, 18, 745);

  // Logistics in charge
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(13)
    .text(logisticsName, 370, 730)
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
      .where('name', 'LIKE', 'Ferrous%')
      .select(['id'])
      .then(function(medTypes) {
        // Create the subquery which gets all iron medication records for
        // pregnancies that were medicated during the target date range.
        var medTypeIds = _.pluck(medTypes, 'id')
        , subQuery = new Medications().query()
            .distinct('medication.pregnancy_id')
            .whereIn('medication.medicationType', medTypeIds)
            .andWhere('medication.date', '>=', dateFrom)
            .andWhere('medication.date', '<=', dateTo)
          ;

        // Now query the data restricted to those ids.
        // Note that this will get more than we need, but we need it
        // in order to determine if this is Iron 1 or Iron 2.
        // The sort by pregnancy.id then medication.date is important
        // for the processing to follow.
        new Medications().query()
          .column('medication.id', 'medication.date', 'medication.medicationType', 'medication.numberDispensed', 'medication.note', 'medication.pregnancy_id')
          .join('medicationType', 'medication.medicationType', '=', 'medicationType.id')
          .column('medicationType.name', 'medicationType.description')
          .join('pregnancy', 'medication.pregnancy_id', '=', 'pregnancy.id')
          .column('pregnancy.lastname', 'pregnancy.firstname', 'pregnancy.lmp', 'pregnancy.gravida', 'pregnancy.para', 'pregnancy.address', 'pregnancy.city')
          .join('patient', 'pregnancy.patient_id', '=', 'patient.id')
          .column('patient.dob')
          .whereIn('medication.medicationType', medTypeIds)
          .whereIn('medication.pregnancy_id', subQuery)
          .orderByRaw('pregnancy.id ASC, medication.date ASC')
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
  doCellBorders(doc, startX, startY, 130, rowHeight);
  // Firstname
  doCellBorders(doc, startX + 130, startY, 90, rowHeight);
  // Age
  doCellBorders(doc, startX + 220, startY, 25, rowHeight);
  // LMP
  doCellBorders(doc, startX + 245, startY, 56, rowHeight);
  // GP
  doCellBorders(doc, startX + 301, startY, 32, rowHeight);
  // Address
  doCellBorders(doc, startX + 333, startY, 187, rowHeight);
  // Pcs
  doCellBorders(doc, startX + 480, startY, 40, rowHeight);
  // Date
  doCellBorders(doc, startX + 520, startY, 56, rowHeight);

  // --------------------------------------------------------
  // Write the row contents.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(11);
  // Lastname
  doc.text(data.lastname.toUpperCase(), startX + 2, startY + 9);
  // Firstname
  doc.text(data.firstname.toUpperCase(), startX + 132, startY + 9);
  // Age
  doc.text(moment().diff(data.dob, 'years'), startX + 225, startY + 9);
  // LMP
  doc
    .fontSize(10)
    .text(moment(data.lmp).format('MM/DD/YYYY'), startX + 247, startY + 9);
  // GP
  doc
    .fontSize(12)
    .text(gravida + '-' + para, startX + 305, startY + 9);
  // Address
  doc
    .fontSize(8)
    .text(data.address.slice(0, 28), startX + 336, startY + 3)
    .text(data.city, startX + 336, startY + 11);
  // Pcs
  doc
    .fontSize(11)
    .text(data.numberDispensed, startX + 490, startY + 9)
  // Date
  doc
    .fontSize(10)
    .text(moment(data.date).format('MM/DD/YYYY'), startX + 522, startY + 9)

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
    , totalPcs = _.reduce(_.pluck(data, 'numberDispensed'),
        function(memo, num) {return memo + num;}, 0)
    , totalPages = Math.ceil(data.length / rowsPerPage)
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary.
  // --------------------------------------------------------
  _.each(data, function(rec) {
    if (currentRow === 0) {
      doSiteTitle(doc, 24);
      doReportName(doc, opts.title, 48);
      doFromTo(doc, opts.fromDate, opts.toDate);
      doColumnHeader(doc);
      doFooter(doc, pageNum, totalPages, totalPcs, opts.logisticsName);
    }
    doRow(doc, rec, currentRow, 21);
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
 * param      logisticsName
 * return     undefined
 * -------------------------------------------------------- */
var doReport = function(flds, writable, logisticsName) {
  var reportNum = parseInt(flds.report.slice(-1), 10) // hack: iron1 or iron2
    , options = {
        margins: {
          top: 18
          , right: 18
          , left: 18
          , bottom: 18
        }
        , layout: 'portrait'
        , size: 'letter'
        , info: {
            Title: 'Iron Given Date ' + reportNum
            , Author: 'Mercy Application'
            , Subject: 'Iron Given Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 28    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = moment(flds.dateFrom).format('YYYY-MM-DD');
  opts.toDate = moment(flds.dateTo).format('YYYY-MM-DD');
  opts.logisticsName = logisticsName;
  opts.title = options.info.Title;

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  // Build the parts of the document.
  getData(opts.fromDate, opts.toDate)
    .then(function(list) {
      var data = []
        , currPregId = 0
        , fDate = moment(opts.fromDate)
        , tDate = moment(opts.toDate)
        ;

      if (reportNum === 1) {
        // --------------------------------------------------------
        // We only want the first iron medication for the patient and
        // only if it falls within the target date range for the report.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var recDate = moment(rec.date)
            ;
          if (currPregId !== rec.pregnancy_id) {
            if ((recDate.isSame(fDate, 'day') || (recDate.isAfter(fDate, 'day'))) &&
                ((recDate.isSame(tDate, 'day')) || (recDate.isBefore(tDate, 'day')))) {
              data.push(rec);
            }
            currPregId = rec.pregnancy_id;
          }
        });
      } else if (reportNum === 2) {
        // --------------------------------------------------------
        // We only want the second iron medication for the patient and
        // only if it falls within the target date range for the report.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var recDate = moment(rec.date)
            ;
          if (rec.pregnancy_id === 3045) console.dir(rec);
          if (currPregId === rec.pregnancy_id) {
            if ((recDate.isSame(fDate, 'day') || (recDate.isAfter(fDate, 'day'))) &&
                ((recDate.isSame(tDate, 'day')) || (recDate.isBefore(tDate, 'day')))) {
              // Make sure we don't add the same record twice since this
              // report does not care about 3rd or later administrations.
              if (data.length > 0 && data[data.length - 1].pregnancy_id !== currPregId) {
                data.push(rec);
              } else {
                data.push(rec);
              }
            }
          } else {
            currPregId = rec.pregnancy_id;
          }
        });

      } else {
        // This is unexpected so bail.
        throw new Error('Unexpected reportNum of ' + reportNum);
      }

      doPages(doc, data, rowsPerPage, opts);
    })
    .then(function() {
      doc.end();
    });
};

/* --------------------------------------------------------
 * run()
 *
 * Run the iron report.
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
    console.log('Iron report: not all fields supplied.');
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

  // --------------------------------------------------------
  // Get the displayName for the logistics in charge.
  // --------------------------------------------------------
  User.findDisplayNameById(Number(flds.inCharge), function(err, name) {
    if (err) throw err;
    doReport(flds, writable, name);
  });
};


module.exports = {
  run: run
};



