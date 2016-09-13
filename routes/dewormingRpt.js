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
  , User = require('../models').User
  , CustomField = require('../models').CustomField
  , CustomFields = require('../models').CustomFields
  , CustomFieldType = require('../models').CustomFieldType
  , CustomFieldTypes = require('../models').CustomFieldTypes
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , isValidDate = require('../util').isValidDate
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , doSiteTitle = require('./reportGeneral').doSiteTitle
  , doReportName = require('./reportGeneral').doReportName
  , doCellBorders = require('./reportGeneral').doCellBorders
  , NO_RECORDS_FOUND_TYPE = 1000
  ;


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
  var fromDate = moment(from, 'YYYY-MM-DD').format('MM/DD/YYYY')
    , toDate = moment(to, 'YYYY-MM-DD').format('MM/DD/YYYY')
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
 * param      logisticsName
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, pageNum, totalPages, totalRows, logisticsName) {
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
  var medTypeIds
    , pregIds
    , data
    ;
  return new Promise(function(resolve, reject) {
    // First get the ids of the medicines we are interested in.
    new MedicationTypes().query()
      .where('name', 'LIKE', 'Mebendazole%')
      .orWhere('name', 'LIKE', 'Albendazole%')
      .select(['id'])
      .then(function(medTypes) {
        medTypeIds = _.pluck(medTypes, 'id');
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the pregnancy ids that we need.
        // --------------------------------------------------------
        return new Medications().query()
            .distinct('medication.pregnancy_id')
            .whereIn('medication.medicationType', medTypeIds)
            .andWhere('medication.date', '>=', dateFrom)
            .andWhere('medication.date', '<=', dateTo)
            .select();
      })
      .then(function(list) {
        pregIds = _.pluck(list, 'pregnancy_id');
        logInfo('Deworming Report: ' + pregIds.length + ' pregnancies.');
        if (pregIds.length === 0) {
          // --------------------------------------------------------
          // Throw something that can be caught appropriately to let
          // the user know that no records were found.
          // --------------------------------------------------------
          var err = new Error('No records were found using from: ' + dateFrom + ', to: ' + dateTo);
          err.type = NO_RECORDS_FOUND_TYPE;
          throw err;
        }
      })
      .then(function(medTypes) {
        // --------------------------------------------------------
        // Now query the data restricted to those ids.
        // --------------------------------------------------------
        new Medications().query()
          .column('medication.id', 'medication.date', 'medication.medicationType', 'medication.numberDispensed', 'medication.note', 'medication.pregnancy_id')
          .join('medicationType', 'medication.medicationType', '=', 'medicationType.id')
          .column('medicationType.name', 'medicationType.description')
          .join('pregnancy', 'medication.pregnancy_id', '=', 'pregnancy.id')
          .column('pregnancy.lastname', 'pregnancy.firstname', 'pregnancy.lmp', 'pregnancy.gravida', 'pregnancy.para', 'pregnancy.address1', 'pregnancy.city')
          .join('patient', 'pregnancy.patient_id', '=', 'patient.id')
          .column('patient.dob')
          .where('medication.date', '>=', dateFrom)
          .andWhere('medication.date', '<=', dateTo)
          .whereIn('medication.medicationType', medTypeIds)
          .select()
          .then(function(list) {
            data = list;
            // --------------------------------------------------------
            // Add all of the placeholders for the data obtained below.
            // --------------------------------------------------------
            _.each(data, function(rec) {
              rec.customFields = [];
            });
          })
          .then(function() {
            // --------------------------------------------------------
            // Get the custom field data. This report is customized for
            // a customization field named 'Agdao' in the customFieldType
            // table. If the custom field is not there, there will be
            // no adverse affect on the report. If it is there, the
            // Agdao addresses will be highlighted.
            // --------------------------------------------------------
            return new CustomFields().query()
              .column('customField.pregnancy_id', 'customField.booleanVal',
                'customFieldType.name')
              .innerJoin('customFieldType', 'customField.customFieldType_id',
                'customFieldType.id')
              .whereIn('customField.pregnancy_id', pregIds)
              .andWhere('customFieldType.name', '=', 'Agdao')
              .andWhere('customField.booleanVal', '=', 1)
              .select();
          })
          .then(function(list) {
            // --------------------------------------------------------
            // Add the custom fields to the records to be returned.
            // --------------------------------------------------------
            _.each(list, function(rec) {
              var meds = _.where(data, {pregnancy_id: rec.pregnancy_id});
              _.each(meds, function(med) {
                med.customFields.push(_.omit(rec, ['pregnancy_id']));
              });
            });
          })
          .then(function() {
            resolve(data);
          })
          .caught(function(err) {
            logError(err);
            reject(err);
          });
      })
      .caught(function(err) {
        reject(err);
      });
  })
  .caught(function(err) {
    return err;
  });
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
  if (data.dob && moment(data.dob).isValid()) {
    doc.text(moment().diff(data.dob, 'years'), startX + 185, startY + 9);
  }
  // LMP
  if (data.lmp && moment(data.lmp).isValid()) {
    doc
      .fontSize(10)
      .text(moment(data.lmp).format('MM/DD/YYYY'), startX + 207, startY + 9);
  }
  // GP
  doc
    .fontSize(12)
    .text(gravida + '-' + para, startX + 265, startY + 9);

  // --------------------------------------------------------
  // "Highlight" the address cell if the client resides in Agdao
  // per the custom fields. This really is not a PDFKit
  // hightlight - we draw a yellow filled rectangle in the cell
  // but it has the effect that we want.
  // --------------------------------------------------------
  if (data.customFields && data.customFields.length > 0 &&
      _.findWhere(data.customFields, {name: 'Agdao'})) {
    doc
      .rect(startX + 295, startY + 2, 112, rowHeight - 4)
      .fill('yellow');
    doc.fillColor('black');     // Set back to black.
  }

  // Address
  doc
    .fontSize(8)
    .text(data.address1.slice(0, 28), startX + 295, startY + 3)
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
      doFooter(doc, pageNum, totalPages, totalRows, opts.logisticsName);
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
 * param      logisticsName
 * return     undefined
 * -------------------------------------------------------- */
var doReport = function(flds, writable, logisticsName) {
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
            , Author: 'Midwife-EMR Application'
            , Subject: 'Deworming Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 23    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = flds.dateFrom;
  opts.toDate = flds.dateTo;
  opts.logisticsName = logisticsName;

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  // Build the parts of the document.
  // Note that the result from the promise will either be a list
  // or an Error.
  getData(opts.fromDate, opts.toDate)
    .then(function(result) {
      if (_.isArray(result)) {
        opts.totalRows = result.length;
        doPages(doc, result, rowsPerPage, opts);
      } else {
        // --------------------------------------------------------
        // An "error" occurred of some sort. It may be just that
        // there were no records for the report, or something more
        // serious. Output to the report so that serious errors
        // can be reported by the users.
        // --------------------------------------------------------
        if (result && result.type && result.type === NO_RECORDS_FOUND_TYPE) {
          centerText(doc, 'No records were generated for the report.', FONTS.HelveticaBold, 20, 100);
        } else {
          centerText(doc, 'Oops! An error occurred.', FONTS.HelveticaBold, 20, 100);
          doc
            .font(FONTS.HelveticaBold)
            .fontSize(15)
            .text('1. Please print and/or save this page.', 20, 130)
            .text('2. Then give this page to your supervisor.', 20, 160);
        }
        if (result && result.message) {
          doc
            .font(FONTS.Helvetica)
            .fontSize(10)
            .text(result.message, 20, 200);
        }
      }
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
  if (! flds.dateFrom || flds.dateFrom.length === 0 || ! isValidDate(flds.dateFrom, 'YYYY-MM-DD')) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must supply a FROM date for the report.'));
  }
  if (! flds.dateTo || flds.dateTo.length === 0 || ! isValidDate(flds.dateTo, 'YYYY-MM-DD')) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must supply a TO date for the report.'));
  }
  if (! flds.inCharge || flds.inCharge.length === 0) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must choose an In Charge person for the report.'));
  }
  if (! fieldsReady) {
    logWarn('Deworming report: not all fields supplied.');
    return res.redirect(cfg.path.reportForm);
  }

  // --------------------------------------------------------
  // When the report is fully built, write it back to the caller.
  // --------------------------------------------------------
  writable.on('finish', function() {
    fs.stat(filePath, function(err, stats) {
      if (err) return logError(err);
      var size = stats.size;

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', 'inline; DewormingRpt.pdf');
      res.setHeader('Content-Transfer-Encoding', 'binary');
      res.setHeader('Content-Length', ('' + size));
      fs.createReadStream(filePath).pipe(res);
      fs.unlink(filePath);
    });
  });

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



