/*
 * -------------------------------------------------------------------------------
 * scheduledRpt.js
 *
 * Generates a report of all scheduled patients in a certain date range.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Bookshelf = require('bookshelf')
  , PDFDocument = require('pdfkit')
  , fs = require('fs')
  , os = require('os')
  , path = require('path')
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , calcEdd = require('../util').calcEdd
  , getGA = require('../util').getGA
  , isValidDate = require('../util').isValidDate
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , doSiteTitle = require('./reportGeneral').doSiteTitle
  , doSiteTitleLong = require('./reportGeneral').doSiteTitleLong
  , doReportName = require('./reportGeneral').doReportName
  , doCellBorders = require('./reportGeneral').doCellBorders
  , centerInCol = require('./reportGeneral').centerInCol
  , colClipped = require('./reportGeneral').colClipped
  , Labors = require('../models').Labors
  , PostpartumChecks = require('../models').PostpartumChecks
  , PrenatalExams = require('../models').PrenatalExams
  , Pregnancies = require('../models').Pregnancies
  ;

/* --------------------------------------------------------
 * doFooter()
 *
 * Write the page numbering at the bottom of the report.
 *
 * param      doc
 * param      pageNum
 * param      totalPages
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, pageNum, totalPages, opts) {
  var largeFontSize = 15
    , smallFontSize = 12
    , leftX = doc.page.margins.left
    , centerX = doc.page.width / 2
    , y = doc.page.height - opts.margins.bottom -
        ((largeFontSize + smallFontSize)*1.5)
    , str
    , str2
    , x
    , len
    , len2
    ;

  // Lower center
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFontSize);
  str = 'Page ' + pageNum + ' of ' + totalPages;
  x = centerX - (doc.widthOfString(str)/2);
  doc.text(str, x, y);
};

/* --------------------------------------------------------
 * getColXpos()
 *
 * Returns an array with the x value of each of the lines
 * that make up the columns of the report.
 *
 * param      opts
 * return     array of x positions
 * -------------------------------------------------------- */
var getColXpos = function(opts) {
  var xPos = []
    , x = opts.margins.left
    ;
  xPos.push(x);                         // left margin
  x += 62; xPos.push(x);                // Date
  x += 60; xPos.push(x);                // Treatment
  x += 130; xPos.push(x);               // Full name
  x += 70; xPos.push(x);                // Barangay
  x += 68; xPos.push(x);                // Phone
  x += 34; xPos.push(x);                // Current GA
  x += 62; xPos.push(x);                // EDD
  x += 62; xPos.push(x);                // Delivered

  // --------------------------------------------------------
  // 72 points per inch, assuming 1/2 inch margins, largest
  // column should be 72 * 8 for letter size paper.
  // --------------------------------------------------------
  if (xPos[xPos.length - 1] > 576) console.log('Warning: column postions too large: ' + xPos[xPos.length - 1]);

  return xPos;
};


/* --------------------------------------------------------
 * doColumnHeader()
 *
 * Writes the column header on the current page.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doColumnHeader = function(doc, opts) {
  var x = doc.page.margins.left
    , y = 110
    , width = doc.page.width - doc.page.margins.right - doc.page.margins.left
    , height = 40
    , colPos = getColXpos(opts)
    , largeFont = 11
    , smallFont = 8
    ;

  // --------------------------------------------------------
  // Headings
  // --------------------------------------------------------
  // Date
  tmpStr = 'Date';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[0], colPos[1], y);

  // Treatment
  tmpStr = 'Treatment';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[1], colPos[2], y);

  // Full name
  tmpStr = 'Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], y);

  // Barangay
  tmpStr = 'Barangay';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[3], colPos[4], y);

  // Phone
  tmpStr = 'Phone';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[4], colPos[5], y);

  // Curr GA
  tmpStr = 'GA';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[5], colPos[6], y);

  // EDD
  tmpStr = 'EDD';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[6], colPos[7], y);

  // Delivered
  tmpStr = 'Delivered';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[7], colPos[8], y);
};


/* --------------------------------------------------------
 * doFromTo()
 *
 * Write the from and to dates that the report covers on
 * the report.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFromTo = function(doc, opts) {
  var fromDate = moment(opts.fromDate, 'YYYY-MM-DD').format('MM/DD/YYYY')
    , toDate = moment(opts.toDate, 'YYYY-MM-DD').format('MM/DD/YYYY')
    ;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(11)
    .text('Reporting Period:', opts.margins.left, 24)
    .font(FONTS.Helvetica)
    .fontSize(10)
    .text(opts.fromDate + ' to ' + opts.toDate, opts.margins.left, 38);
};

/* --------------------------------------------------------
 * doPages()
 *
 * Builds out the report.
 *
 * param       doc
 * param       data
 * param       rowsPerPage
 * param       opts
 * return      undefined
 * -------------------------------------------------------- */
var doPages = function(doc, data, rowsPerPage, opts) {
  var currRowOnPage = 0
    , currentRow = 0
    , pageNum = 1
    , totalPages = Math.ceil(data.length / rowsPerPage)
    , totalRows = data.length
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary. If there is no
  // data, still create a page with no data.
  // --------------------------------------------------------
  doSiteTitleLong(doc, 24);
  doReportName(doc, opts.title, 48);
  doFromTo(doc, opts);
  doColumnHeader(doc, opts);
  doFooter(doc, pageNum, totalPages, opts);
  _.each(data, function(rec) {
    doRow(doc, rec, opts, currRowOnPage, 20);
    currRowOnPage++;
    currentRow++;
    if (currRowOnPage >= rowsPerPage && currentRow % rowsPerPage === 0 && currentRow !== totalRows) {
      doc.addPage();
      currRowOnPage = 0;
      pageNum++;
      doSiteTitle(doc, 24);
      doReportName(doc, opts.title, 48);
      doFromTo(doc, opts);
      doColumnHeader(doc, opts);
      doFooter(doc, pageNum, totalPages, opts);
    }
  });
};

/* --------------------------------------------------------
 * doRow()
 *
 * Writes a row on the report including borders and text.
 *
 * param      doc
 * param      data
 * param      opts
 * param      rowNum
 * param      rowHeight
 * return     undefined
 * -------------------------------------------------------- */
var doRow = function(doc, data, opts, rowNum, rowHeight) {
  var cells = []
    , startX = doc.page.margins.left
    , startY = 120 + (rowNum * rowHeight)
    , fontSize = 11
    , smallFontSize = 8
    , textY = startY + (rowHeight/2) - (fontSize/2) + 2
    , textAddressY = startY + (rowHeight/2) - (smallFontSize/2) - 3
    , colPad = 2
    , colPos = getColXpos(opts)
    , tmpStr
    , tmpWidth
    , tmpWidth2
    , pe          // prenatalExam
    , ltr         // labTestResult
    ;

  // --------------------------------------------------------
  // Draw all of the lines.
  // --------------------------------------------------------
  // Cell columns.
  _.each(colPos, function(x, idx) {
    doc
      .moveTo(x, startY)
      .lineTo(x, startY + rowHeight)
      .stroke();
  });

  // Top and bottom lines of row.
  doc
    .moveTo(startX, startY)
    .lineTo(colPos[colPos.length - 1], startY)
    .moveTo(colPos[colPos.length - 1], startY + rowHeight)
    .lineTo(startX, startY + rowHeight)
    .stroke();

  // --------------------------------------------------------
  // Write the row contents.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(fontSize);
  // Date
  tmpStr = moment(data.date).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[0], colPos[1], textY);

  // Treatment (prenatal or postpartum)
  if (data.recType === 'pre') {
    tmpStr = 'Prenatal';
  } else {
    tmpStr = 'Postpartum';
  }
  doc.text(tmpStr, colPos[1] + colPad, textY);

  // Full name
  tmpStr = (data.lastname + ', ' + data.firstname).toUpperCase();
  colClipped(doc, tmpStr, colPos[2] + colPad, colPos[3] - colPad, textY);

  // Barangay
  colClipped(doc, data.address3.toUpperCase(), colPos[3] + colPad, colPos[4] - colPad, textY);

  // Phone
  // Remove anything that is not a digit.
  tmpStr = data.telephone.replace(/\D/g, '');
  colClipped(doc, tmpStr, colPos[4] + colPad, colPos[5] - colPad, textY);

  // Current GA
  if (data.useAlternateEdd === 1 && moment.isDate(data.alternateEdd)) {
    tmpStr = getGA(data.alternateEdd);
  } else if (moment.isDate(data.lmp)) {
    tmpStr = getGA(moment(calcEdd(data.lmp), 'YYYY-MM-DD'));
  } else {
    tmpStr = '';
  }
  centerInCol(doc, tmpStr, colPos[5], colPos[6], textY);

  // Estimated Due Date
  if (data.useAlternateEdd === 1 && moment.isDate(data.alternateEdd)) {
    tmpStr = moment(data.alternateEdd).format('MM-DD-YYYY');
  } else if (moment.isDate(data.lmp)) {
    tmpStr = calcEdd(data.lmp, 'MM-DD-YYYY');
  } else {
    tmpStr = '';
  }
  centerInCol(doc, tmpStr, colPos[6], colPos[7], textY);

  // Date of delivery (postpartum only)
  tmpStr = '';
  if (data.birthDatetime && moment.isDate(data.birthDatetime)) {
    tmpStr = moment(data.birthDatetime).format('MM-DD-YYYY');
  }
  centerInCol(doc, tmpStr, colPos[7], colPos[8], textY);
};

/* --------------------------------------------------------
 * getData()
 *
 * Queries for the following scheduled dates:
 *    - prenatal exams
 *    - postpartum checks
 *
 * param      dateFrom
 * param      dateTo
 * return     Promise
 * -------------------------------------------------------- */
var getData = function(dateFrom, dateTo) {
  var data = []
    , knex = Bookshelf.DB.knex
    ;

  return new Promise(function(resolve, reject) {
    var pnSQL;

    // --------------------------------------------------------
    // Get the prenatal exams that are scheduled that do not
    // have a labor record.
    // --------------------------------------------------------
    pnSQL  = 'SELECT DISTINCT p.id, "pre" AS recType, pe.returnDate AS date, p.lastname, p.firstname, p.address3, p.telephone, ';
    pnSQL += 'p.lmp, p.sureLMP, p.alternateEdd, p.useAlternateEdd ';
    pnSQL += 'FROM pregnancy p INNER JOIN prenatalExam pe ON p.id = pe.pregnancy_id ';
    pnSQL += 'WHERE pe.returnDate >= "' + dateFrom + '" AND pe.returnDate <= "' + dateTo + '" ';
    pnSQL += 'AND NOT EXISTS(SELECT * FROM labor WHERE pregnancy_id = p.id)';

    knex
      .raw(pnSQL)
      .then(function(resp) {
        data.push(resp[0]);
      })
      .then(function() {
        var ppSQL;
        // --------------------------------------------------------
        // Get the postpartum checks that are scheduled.
        // --------------------------------------------------------
        ppSQL  = 'SELECT DISTINCT p.id, "post" AS recType, pp.nextScheduledCheck AS date, p.lastname, p.firstname, p.address3, p.telephone, ';
        ppSQL += 'p.lmp, p.sureLMP, p.alternateEdd, p.useAlternateEdd, ls2.birthDatetime ';
        ppSQL += 'FROM pregnancy p INNER JOIN labor l ON l.pregnancy_id = p.id ';
        ppSQL += 'INNER JOIN postpartumCheck pp ON pp.labor_id = l.id ';
        ppSQL += 'INNER JOIN laborStage2 ls2 ON l.id = ls2.labor_id ';
        ppSQL += 'WHERE pp.nextScheduledCheck >= "' + dateFrom + '" ';
        ppSQL += 'AND pp.nextScheduledCheck <= "' + dateTo + '" ';

        return knex.raw(ppSQL);
      })
      .then(function(resp) {
        data.push(resp[0]);
      })
      .then(function() {
        // Flatten the two arrays into one.
        resolve(_.flatten(data));
      })
      .caught(function(err) {
        logError(err);
        reject(err);
      });
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
          , right: 28
          , left: 28
          , bottom: 18
        }
        , layout: 'portrait'
        , size: 'letter'
        , info: {
            Title: 'Scheduled Report'
            , Author: 'Midwife-EMR Application'
            , Subject: 'Scheduled Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 30    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = flds.dateFrom;
  opts.toDate = flds.dateTo;
  opts.title = options.info.Title;
  opts.margins = options.margins;

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  // Build the parts of the document.
  getData(opts.fromDate, opts.toDate)
    .then(function(rawData) {
      var data = []
        ;

      // --------------------------------------------------------
      // Sort records by date (ignoring time) then by recType,
      // prenatal before postpartum.
      // --------------------------------------------------------
      data = _.sortBy(rawData, function(rec) {
        var d = new Date(rec.date.getFullYear(), rec.date.getMonth(), rec.date.getDate());
        if (rec.recType === 'pre') return d.getTime();
        return d.getTime() + 100;
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
 * Run the scheduled report.
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
  if (! fieldsReady) {
    logWarn('Scheduled report: not all fields supplied.');
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
      res.setHeader('Content-Disposition', 'inline; ScheduledRpt.pdf');
      res.setHeader('Content-Transfer-Encoding', 'binary');
      res.setHeader('Content-Length', ('' + size));
      fs.createReadStream(filePath).pipe(res);
      fs.unlink(filePath);
    });
  });

  doReport(flds, writable);
};



module.exports = {
  run: run
};

