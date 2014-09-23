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
  , CustomField = require('../models').CustomField
  , CustomFields = require('../models').CustomFields
  , CustomFieldType = require('../models').CustomFieldType
  , CustomFieldTypes = require('../models').CustomFieldTypes
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , doSiteTitle = require('./reportGeneral').doSiteTitle
  , doReportName = require('./reportGeneral').doReportName
  , doCellBorders = require('./reportGeneral').doCellBorders
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
  var medTypeIds
    , pregIds
    , data
    ;
  return new Promise(function(resolve, reject) {
    // --------------------------------------------------------
    // First get the ids of the medicines we are interested in.
    // --------------------------------------------------------
    new MedicationTypes().query()
      .where('name', 'LIKE', 'Ferrous%')
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
      })
      .then(function(medTypes) {
        // Now query the data restricted to those ids.
        // Note that this will get more than we need, but we need it
        // in order to determine if this is Iron 1 or 2, 3, etc.
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
          .whereIn('medication.pregnancy_id', pregIds)
          .orderByRaw('pregnancy.id ASC, medication.date ASC')
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
              var agdaos = _.where(data, {pregnancy_id: rec.pregnancy_id});
              _.each(agdaos, function(rec2) {
                rec2.customFields.push(_.omit(rec, ['pregnancy_id']));
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
      });
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

  // --------------------------------------------------------
  // "Highlight" the address cell if the client resides in Agdao
  // per the custom fields. This really is not a PDFKit
  // hightlight - we draw a yellow filled rectangle in the cell
  // but it has the effect that we want.
  // --------------------------------------------------------
  if (data.customFields && data.customFields.length > 0 &&
      _.findWhere(data.customFields, {name: 'Agdao'})) {
    doc
      .rect(startX + 335, startY + 2, 143, 17)
      .fill('yellow');
    doc.fillColor('black');     // Set back to black.
  }

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
  var reportNum = parseInt(flds.report.slice(-1), 10) // hack: iron1 through iron5
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
        , dataMap = {}
        , currPregId = 0
        , fDate = moment(opts.fromDate)
        , tDate = moment(opts.toDate)
        ;

      // --------------------------------------------------------
      // Break out the iron dispensations into order by pregnancy.
      // Assumes that the list is sorted by pregnancy_id then
      // by date.
      // --------------------------------------------------------
      _.each(list, function(rec) {
        if (dataMap[rec.pregnancy_id]) {
          dataMap[rec.pregnancy_id].push(rec);
        } else {
          dataMap[rec.pregnancy_id] = [rec];
        }
      });

      // --------------------------------------------------------
      // Populate the data array with the records that are needed
      // for this particular report.
      // --------------------------------------------------------
      _.each(_.keys(dataMap), function(key) {
        var rec = dataMap[key][reportNum-1]
          , recDate
          ;
        if (rec) {
          recDate = moment(rec.date);
          if ((recDate.isSame(fDate, 'day') || (recDate.isAfter(fDate, 'day'))) &&
              ((recDate.isSame(tDate, 'day')) || (recDate.isBefore(tDate, 'day')))) {
            data.push(rec);
          }
        }
      });

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



