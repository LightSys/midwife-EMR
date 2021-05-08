/*
 * -------------------------------------------------------------------------------
 * vitaminARpt.js
 *
 * Required report for health statistics regarding vitamin A.
 * -------------------------------------------------------------------------------
 */


var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , PDFDocument = require('pdfkit')
  , fs = require('fs')
  , os = require('os')
  , path = require('path')
  , Labor = require('../models').Labor
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , MotherMedication = require('../models').MotherMedication
  , MotherMedications = require('../models').MotherMedications
  , MotherMedicationType = require('../models').MotherMedicationType
  , MotherMedicationTypes = require('../models').MotherMedicationTypes
  , User = require('../models').User
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , isValidDate = require('../util').isValidDate
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , doSiteTitle = require('./reportGeneral').doSiteTitle
  , doSiteTitleLong = require('./reportGeneral').doSiteTitleLong
  , doReportName = require('./reportGeneral').doReportName
  , doCellBorders = require('./reportGeneral').doCellBorders
  , centerInCol = require('./reportGeneral').centerInCol
  , generateReportFilename = require('./reportGeneral').generateReportFilename
  , FORMAT_SCREEN = require('./reportGeneral.js').FORMAT_SCREEN
  , FORMAT_PDF = require('./reportGeneral.js').FORMAT_PDF
  , FORMAT_CSV = require('./reportGeneral.js').FORMAT_CSV
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
    , middleLineHeaderY = (height/2) - 6
    ;

  // Outer rectangle
  doc
    .rect(x, y, width, height)
    .stroke();

  // Headings
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(12)
    .text('Mother\'s Name', x + 50, y + 7)
    .text('Last', x + 33, y + 25)
    .text('First', x + 123, y + 25)
    .text('Age', x + 183, y + middleLineHeaderY)
    .text('GP', x + 215, y + middleLineHeaderY)
    .text('Address', x + 301, y + 7)
    .text('District', x + 260, y + 25)
    .text('Barangay', x + 350, y + 25)
    .text('DOD', x + 480, y + middleLineHeaderY)
    ;

  doc
    .font(FONTS.HelveticaBold)
    .fontSize(8)
    .text('Given', x + 430, y + 7)
    .text('Date/Time', x + 423, y + 25)
    .text('Remarks', x + 523, y + middleLineHeaderY)
    ;

  // Column dividers
  doc
    .moveTo(x + 182, y)
    .lineTo(x + 182, y + height)
    .moveTo(x + 207, y)
    .lineTo(x + 207, y + height)
    .moveTo(x + 242, y)
    .lineTo(x + 242, y + height)
    .moveTo(x + 420, y)
    .lineTo(x + 420, y + height)
    .moveTo(x + 466, y)
    .lineTo(x + 466, y + height)
    .moveTo(x + 520, y)
    .lineTo(x + 520, y + height)
    .moveTo(x, y + (height/2))
    .lineTo(x + 182, y + (height/2))
    .moveTo(x + 242, y + (height/2))
    .lineTo(x + 420, y + (height/2))
    .stroke();

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
  // Summary
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(13)
    .text('Total Vit A: ' + totalRows, 18, 780)
    .font(FONTS.Helvetica)
    .fontSize(10)
    .text('Page ' + pageNum + ' of ' + totalPages, 18, 795);

  // Logistics in charge
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(13)
    .text(logisticsName, 370, 780)
    .font(FONTS.Helvetica)
    .fontSize(10)
    .text('Director', 370, 795);
};

/* --------------------------------------------------------
 * getData()
 *
 * Queries the database for the required information. Returns
 * a promise that resolves to an array of data.
 *
 * NOTE: The motherMedicationDate is DATETIME rather than 
 * DATE like other prenatal reports, so the report query 
 * leaves out the ending date when the time part is not 
 * exactly zero, which it never is.  So it leaves out 
 * "today" because the datetime occurred after midnight.
 * We handle this by querying for less that dateTo after
 * increasing dateTo by a day.
 *
 * param      dateFrom
 * param      dateTo
 * return     Promise
 * -------------------------------------------------------- */
var getData = function(dateFrom, dateTo) {
  var medTypeIds
    , pregIds
    , data
    , fixedDateTo = moment(dateTo).add(1, 'days').format('YYYY-MM-DD')
    ;

  return new Promise(function(resolve, reject) {
    // First get the ids of the medicines we are interested in.
    new MotherMedicationTypes().query()
      .where('name', 'LIKE', 'Vitamin A%')
      .select(['id'])
      .then(function(medTypes) {
        medTypeIds = _.pluck(medTypes, 'id');
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the pregnancy ids that we need.
        // --------------------------------------------------------
        return new MotherMedications().query()
            .distinct('labor.pregnancy_id')
            .innerJoin('labor', 'motherMedication.labor_id', 'labor.id')
            .innerJoin('motherMedicationType', 'motherMedicationType.id', 'motherMedication.motherMedicationType')
            .whereIn('motherMedication.motherMedicationType', medTypeIds)
            .andWhere('motherMedication.medicationDate', '>=', dateFrom)
            .andWhere('motherMedication.medicationDate', '<', fixedDateTo)
            .select();
      })
      .then(function(list) {
        pregIds = _.pluck(list, 'pregnancy_id');
        logInfo('Vitamin A Report: ' + pregIds.length + ' given.');
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
        new MotherMedications().query()
          .column('motherMedication.medicationDate')
          .join('labor', 'motherMedication.labor_id', '=', 'labor.id')
          .join('laborStage2', 'labor.id', '=', 'laborStage2.labor_id')
          .column('laborStage2.birthDatetime')
          .join('pregnancy', 'labor.pregnancy_id', '=', 'pregnancy.id')
          .column('pregnancy.lastname', 'pregnancy.firstname',
              'pregnancy.address1', 'pregnancy.address2',
              'pregnancy.address3', 'pregnancy.address4',
              'pregnancy.city', 'pregnancy.gravida', 'pregnancy.para')
          .join('patient', 'pregnancy.patient_id', '=', 'patient.id')
          .column('patient.dob')
          .where('motherMedication.medicationDate', '>=', dateFrom)
          .where('motherMedication.medicationDate', '<', fixedDateTo)
          .whereIn('motherMedication.motherMedicationType', medTypeIds)
          .orderByRaw('pregnancy.address4 ASC, pregnancy.address3 ASC')
          //.orderBy('laborStage2.birthDatetime', 'ASC')
          .select()
          .then(function(list) {
            data = list;
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
    , para = (data.para || 0) + 1
    , tmpStr
    , addr1 = data.address1? data.address1.slice(0, 28): ''
    , addr2 = data.address3? data.address3 + ' ' + (data.address4? data.address4: ''): ''
    , district = data.address4? data.address4: ''
    , barangay = data.address3? data.address3: ''
    ;

  // Create the cell borders
  // Lastname
  doCellBorders(doc, startX, startY, 90, rowHeight);
  // Firstname
  doCellBorders(doc, startX + 90, startY, 92, rowHeight);
  // Age
  doCellBorders(doc, startX + 182, startY, 25, rowHeight);
  // GP
  doCellBorders(doc, startX + 207, startY, 35, rowHeight);
  // Address
  doCellBorders(doc, startX + 242, startY, 178, rowHeight);
  // Given date/time
  doCellBorders(doc, startX + 420, startY, 46, rowHeight);
  // DOD date/time
  doCellBorders(doc, startX + 466, startY, 54, rowHeight);
  // Remarks
  doCellBorders(doc, startX + 520, startY, 39, rowHeight);

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
    tmpStr = moment().diff(moment(data.dob), 'years');
    centerInCol(doc, tmpStr, startX + 182, startX + 207, startY + 9);
  }

  // --------------------------------------------------------
  // GP: Gravida and Para. Take the gravida and para from the
  // pregnancy and add one to para and present as GxPy where
  // x = gravida and y = para + 1.
  // --------------------------------------------------------
  centerInCol(doc, "G" + gravida + "P" + para, startX + 207, startX + 242, startY + 9);

  // --------------------------------------------------------
  // Remarks: this is a required column for the government
  // even though we have no information to put in it.
  // --------------------------------------------------------

  // Address
  doc
    .fontSize(10)
    .text(addr1, startX + 245, startY + 3)
    .text(district, startX + 245, startY + 15)
    .text(barangay, startX + 350, startY + 15);

  // Given Date and time
  doc
    .fontSize(8)
    .text(moment(data.medicationDate).format('MM/DD/YYYY'), startX + 423, startY + 3)
    .text(moment(data.medicationDate).format('HH:mm A'), startX + 423, startY + 15);

  // Birth Date and time
  doc
    .fontSize(10)
    .text(moment(data.birthDatetime).format('MM/DD/YYYY'), startX + 468, startY + 9)
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
    , rowsFinished = 0
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary.
  // --------------------------------------------------------
  _.each(data, function(rec) {
    if (currentRow === 0) {
      doSiteTitleLong(doc, 24);
      doReportName(doc, 'Vitamin A', 48);
      doFromTo(doc, opts.fromDate, opts.toDate);
      doColumnHeader(doc);
      doFooter(doc, pageNum, totalPages, totalRows, opts.logisticsName);
    }
    doRow(doc, rec, currentRow, 25);
    rowsFinished++; currentRow++;
    if (currentRow === rowsPerPage && rowsFinished < totalRows) {
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
        , size: 'A4'
        , info: {
            Title: 'Vitamin A Report'
            , Author: 'Midwife-EMR Application'
            , Subject: 'Vitamin A Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 25    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = flds.dateFrom;
  opts.toDate = flds.dateTo;
  opts.logisticsName = logisticsName? logisticsName: '';

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
 * Run the vitamin A report.
 * -------------------------------------------------------- */
var run = function(req, res) {
  var flds = _.omit(req.body, ['_csrf'])
    , filePath = path.join(cfg.site.tmpDir, 'rpt-' + (Math.random() * 9999999999) + '.pdf')
    , writable = fs.createWriteStream(filePath)
    , success = false
    , fieldsReady = true
    , reportFormat = req.body.reportFormat ? req.body.reportFormat : FORMAT_SCREEN
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
      var downloadFilename = generateReportFilename('VitaminARpt_DistBarangay', 'pdf');

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Transfer-Encoding', 'binary');

      switch (reportFormat) {
        case FORMAT_SCREEN:
          res.setHeader('Content-Disposition', 'inline; VitaminARpt_DistBarangay.pdf');
          res.setHeader('Content-Length', ('' + size));
          break;

        case FORMAT_PDF:
          res.attachment(downloadFilename);
          break;
      }

      fs.createReadStream(filePath).pipe(res);
      fs.unlink(filePath);
    });
  });

  // --------------------------------------------------------
  // Get the displayName for the director in charge.
  // --------------------------------------------------------
  User.findDisplayNameById(Number(flds.inCharge), function(err, name) {
    if (err) throw err;
    doReport(flds, writable, name);
  });
};



module.exports = {
  run: run
};

