/* 
 * -------------------------------------------------------------------------------
 * dueRpt.js
 *
 * Generates a report of pregnancies due.
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
  x += 200; xPos.push(x);               // Full name
  x += 119; xPos.push(x);               // Barangay
  x += 85; xPos.push(x);                // Phone
  x += 72; xPos.push(x);                // EDD
  x += 72; xPos.push(x);                // Last prenatal exam

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
  // Full name
  tmpStr = 'Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[0], colPos[1], y);

  // Barangay
  tmpStr = 'Barangay';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[1], colPos[2], y);

  // Phone
  tmpStr = 'Phone';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], y);

  // EDD
  tmpStr = 'EDD';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[3], colPos[4], y);

  // Last prenatal exam
  tmpStr = 'Last Prenatal';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[4], colPos[5], y);
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
 * doFooter()
 *
 * Write the page numbering at the bottom of the report.
 *
 * param      doc
 * param      pageNum
 * param      totalPages
 * param      numRecs
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, pageNum, totalPages, numRecs, opts) {
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

  // Lower left, but only on the last page.
  if (pageNum === totalPages) {
    doc
      .font(FONTS.HelveticaBold)
      .fontSize(smallFontSize)
      .text('Total number due: ' + numRecs, leftX, y)
  }

  // Lower center
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFontSize);
  str = 'Page ' + pageNum + ' of ' + totalPages;
  x = centerX - (doc.widthOfString(str)/2);
  doc.text(str, x, y);
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
  var currentRow = 0
    , pageNum = 1
    , totalPages = Math.ceil(data.length / rowsPerPage)
    , numRecs = data.length
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary. If there is no
  // data, still create a page with no data.
  // --------------------------------------------------------
  doSiteTitleLong(doc, 24);
  doReportName(doc, opts.title, 48);
  doFromTo(doc, opts);
  doColumnHeader(doc, opts);
  doFooter(doc, pageNum, totalPages, numRecs, opts);
  _.each(data, function(rec) {
    doRow(doc, rec, opts, currentRow, 20);
    currentRow++;
    if (currentRow >= rowsPerPage) {
      doc.addPage();
      currentRow = 0;
      pageNum++;
      doSiteTitle(doc, 24);
      doReportName(doc, opts.title, 48);
      doFromTo(doc, opts);
      doColumnHeader(doc, opts);
      doFooter(doc, pageNum, totalPages, numRecs, opts);
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
  // Full name
  tmpStr = (data.lastname + ', ' + data.firstname).toUpperCase();
  colClipped(doc, tmpStr, colPos[0] + colPad, colPos[1] - colPad, textY);

  // Barangay
  colClipped(doc, data.address3.toUpperCase(), colPos[1] + colPad, colPos[2] - colPad, textY);

  // Phone
  // Remove anything that is not a digit.
  tmpStr = data.telephone.replace(/\D/g, '');
  //colClipped(doc, tmpStr, colPos[2] + colPad, colPos[3] - colPad, textY);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], textY);

  // Estimated Due Date
  tmpStr = moment(data.EDD).format('MM-DD-YYYY');
  centerInCol(doc, tmpStr, colPos[3], colPos[4], textY);

  // Last prenatal exam
  tmpStr = moment(data.LastPrenatal).format('MM-DD-YYYY');
  centerInCol(doc, tmpStr, colPos[4], colPos[5], textY);
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
  var knex = Bookshelf.DB.knex
    , data
    ;

  return new Promise(function(resolve, reject) {
    var dueSQL;

    dueSQL  = 'SELECT p.id AS ID, p.lastname, p.firstname, p.address3, p.telephone, p.alternateEdd AS EDD, ';
    dueSQL += '(SELECT MAX(pe.date) FROM prenatalExam pe WHERE pe.pregnancy_id = p.id) AS LastPrenatal '
    dueSQL += 'FROM pregnancy p WHERE p.useAlternateEdd = 1 AND p.alternateEdd IS NOT NULL ';
    dueSQL += 'AND NOT EXISTS (SELECT * FROM labor l WHERE l.pregnancy_id = p.id) ';
    dueSQL += 'AND p.alternateEdd >= "' + dateFrom + '" AND alternateEdd <= "' + dateTo + '" ';
    dueSQL += 'UNION SELECT p.id AS ID, p.lastname, p.firstname, p.address3, p.telephone, DATE_ADD(p.lmp, INTERVAL 280 DAY) AS EDD, ';
    dueSQL += '(SELECT MAX(pe.date) FROM prenatalExam pe WHERE pe.pregnancy_id = p.id) AS LastPrenatal '
    dueSQL += 'FROM pregnancy p WHERE p.useAlternateEdd = 0 AND p.lmp IS NOT NULL ';
    dueSQL += 'AND NOT EXISTS (SELECT * FROM labor l WHERE l.pregnancy_id = p.id) ';
    dueSQL += 'AND DATE_ADD(p.lmp, INTERVAL 280 DAY) >= "' + dateFrom + '" ';
    dueSQL += 'AND DATE_ADD(p.lmp, INTERVAL 280 DAY) <= "' + dateTo + '" ORDER BY EDD';

    //console.log(dueSQL);

    knex
      .raw(dueSQL)
      .then(function(resp) {
        data = resp[0];
      })
      .then(function() {
        resolve(data);
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
            Title: 'Due Report'
            , Author: 'Midwife-EMR Application'
            , Subject: 'Due Report'
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
    .then(function(data) {
      doPages(doc, data, rowsPerPage, opts);
    })
    .then(function() {
      doc.end();
    });
};



/* --------------------------------------------------------
 * run()
 *
 * Run the due report.
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
    logWarn('Due report: not all fields supplied.');
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
      res.setHeader('Content-Disposition', 'inline; DueRpt.pdf');
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

