/* 
 * -------------------------------------------------------------------------------
 * inactiveRpt.js
 *
 * Reports on patients whose most recent prenatal return date falls between the
 * dates specified which have not already delivered.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , PDFDocument = require('pdfkit')
  , Bookshelf = require('bookshelf')
  , fs = require('fs')
  , os = require('os')
  , path = require('path')
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , formatDohID = require('../util').formatDohID
  , isValidDate = require('../util').isValidDate
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , centerInCol = require('./reportGeneral').centerInCol
  , Pregnancy = require('../models').Pregnancy
  , Patient = require('../models').Patient
  , PrenatalExam = require('../models').PrenatalExam
  ;


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
  var knex = Bookshelf.DB.knex
    , pregRecs
    , patRecs
    , data = []
    , msg
    , sql
    ;

  // --------------------------------------------------------
  // Add a day to the dateTo because dateTo does not have a
  // time element and will be interpreted as midnight at the
  // beginning of dateTo while we need to include the day of
  // dateTo as well.
  // --------------------------------------------------------
  dateTo = moment(dateTo).add(1, 'days').format('YYYY-MM-DD');

  // --------------------------------------------------------
  // Raw SQL since I have not been able to get the Knex builder
  // to work the way that I want.
  // -------------------------------------------------------- 
  sql =  'SELECT pe.pregnancy_id AS pregId, p.firstname AS firstname, ';
  sql += 'p.lastname AS lastname, pa.dohID AS mmc, ';
  sql += 'MAX(pe.returnDate) AS ReturnDate ';
  sql += 'FROM prenatalExam pe INNER JOIN pregnancy p ';
  sql += 'ON p.id = pe.pregnancy_id ';
  sql += 'INNER JOIN patient pa ';
  sql += 'ON p.patient_id = pa.id ';
  sql += 'WHERE p.pregnancyEndDate IS NULL OR p.pregnancyEndDate = "0000-00-00" ';
  sql += 'GROUP BY pe.pregnancy_id ';
  sql += 'HAVING MAX(pe.returnDate) > "' + dateFrom + '?" ';
  sql += 'AND MAX(pe.returnDate) <= "' + dateTo + '" ';
  sql += 'ORDER BY pa.dohID ASC, p.lastname ASC, p.firstname ASC';

  return new Promise(function(resolve, reject) {
    return knex.raw(sql)
      .then(function(list) {
        var data = list[0];   // First array is our data, second is db info.
        if (data.length > 0) {
          resolve(data);
        } else {
          reject('No records found.');
        }
      })
      .caught(function(err) {
        logError(err);
        reject(err);
      });
  });
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
    , y = 150
    , upperY = y - 13
    , width = doc.page.width - doc.page.margins.right - doc.page.margins.left
    , height = 40
    , colPos = getColXpos(opts)
    , largeFont = 11
    , smallFont = 8
    ;

  // --------------------------------------------------------
  // Headings
  // --------------------------------------------------------
  tmpStr = 'MMC ID';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[0], colPos[1], y);

  tmpStr = 'Last Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[1], colPos[2], y);

  tmpStr = 'First Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], y);

  tmpStr = 'Expected';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[3], colPos[4], upperY);
  tmpStr = 'return date';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[3], colPos[4], y);

  tmpStr = 'Staff Notes';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[4], colPos[5], y);
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
    , startY = 170 + (rowNum * rowHeight)
    , fontSize = 10
    , textY = startY + 5
    , textY2 = textY + fontSize + 2
    , colPadLeft = 2
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
  // MMC ID
  tmpStr = formatDohID(data.mmc, true);
  centerInCol(doc, tmpStr, colPos[0], colPos[1], textY);

  // Lastname
  tmpStr = data.lastname;
  doc.text(tmpStr, colPos[1] + colPadLeft, textY);

  // Firstname
  tmpStr = data.firstname;
  doc.text(tmpStr, colPos[2] + colPadLeft, textY);

  // return date
  tmpStr = moment(data.ReturnDate).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[3], colPos[4], textY);
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
  var fDate = moment(from, 'YYYY-MM-DD')
    , tDate = moment(to, 'YYYY-MM-DD')
    , fromDate = fDate.format('MM/DD/YYYY')
    , toDate = tDate.format('MM/DD/YYYY')
    , fromDays = Math.abs(fDate.diff(moment(), 'days'))
    , toDays = Math.abs(tDate.diff(moment(), 'days'))
    , y = 80
    , text1 = 'Report date: '
    , text2 = 'Expected return dates: '
    , textLen
    ;

  doc
    .font(FONTS.Helvetica)
    .fontSize(11)
    .text(text2, 18, y);
  textLen = doc.widthOfString(text2);
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(11)
    .text(fromDate + ' to ' + toDate + ', ' + toDays + ' to ' + fromDays + ' days overdue.', 18 + textLen, y);

  doc
    .font(FONTS.Helvetica)
    .fontSize(11)
    .text(text1, 18, y + 14);
  textLen = doc.widthOfString(text1);
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(11)
    .text(moment().format('MM/DD/YYYY'), 18 + textLen, y + 14);
};

/* --------------------------------------------------------
 * doReportTitle()
 *
 * Writes out the report name at the top of each page.
 *
 * param      doc
 * param      title
 * return     undefined 
 * -------------------------------------------------------- */
var doReportTitle = function(doc, title) {
  centerText(doc, title, FONTS.Helvetica, 28, 25);
};

/* --------------------------------------------------------
 * doPageNums()
 *
 * Print the page number at the bottom of the report.
 *
 * param      doc
 * param      pageNum
 * param      totalPages
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doPageNums = function(doc, pageNum, totalPages, opts) {
  var str
    , len
    , largeFont = 11
    , x
    , paddingRight = 4
    , y = doc.page.height - opts.margins.bottom - largeFont - 5
    ;

  doc.font(FONTS.HelveticaBold).fontSize(largeFont);
  str =  'Page ' + pageNum + ' of ' + totalPages;
  len = doc.widthOfString(str);
  x = (doc.page.width/2) - (len/2);
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont)
    .text(str, x, y);
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
    , totalPages = Math.ceil(data.length / rowsPerPage)
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary. If there is no
  // data, still create a page with no data.
  // --------------------------------------------------------
  doReportTitle(doc, opts.title);
  doFromTo(doc, opts.fromDate, opts.toDate);
  doPageNums(doc, pageNum, totalPages, opts);
  doColumnHeader(doc, opts);
  _.each(data, function(rec) {
    doRow(doc, rec, opts, currentRow, 18);
    currentRow++;
    if (currentRow >= rowsPerPage) {
      doc.addPage();
      currentRow = 0;
      pageNum++;
      doReportTitle(doc, opts.title);
      doFromTo(doc, opts.fromDate, opts.toDate);
      doPageNums(doc, pageNum, totalPages, opts);
      doColumnHeader(doc, opts);
    }
  });
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
    , x
    ;
  x = opts.margins.left; xPos.push(x);  // left margin
  x += 45; xPos.push(x);                // MMC ID
  x += 120; xPos.push(x);               // lastname
  x += 120; xPos.push(x);               // firstname
  x += 100; xPos.push(x);               // return date
  x += 185; xPos.push(x);               // Notes

  return xPos;
};

/* --------------------------------------------------------
 * doReport()
 *
 * Manages building of the report.
 *
 * param      flds
 * param      writable
 * param      req
 * param      res
 * return     undefined
 * -------------------------------------------------------- */
var doReport = function(flds, writable, req, res) {
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
            Title: cfg.site.title + ' Inactives Report'
            , Author: 'Midwife-EMR Application'
            , Subject: 'Inactives Daily Report'
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

  // Build the parts of the document.
  getData(opts.fromDate, opts.toDate)
    .then(function(data) {
      var fDate = moment(opts.fromDate, 'YYYY-MM-DD')
        , tDate = moment(opts.toDate, 'YYYY-MM-DD')
        ;

      // --------------------------------------------------------
      // Write the report to the writable stream passed.
      // --------------------------------------------------------
      doc.pipe(writable);

      doPages(doc, data, rowsPerPage, opts);

    })
    .then(function() {
      doc.end();
    })
    .caught(function(err) {
      logError(err);
      req.flash('warning', err);
      res.redirect(cfg.path.reportForm);
    });
};


/* --------------------------------------------------------
 * run()
 *
 * Create the inactive report for a patient.
 * -------------------------------------------------------- */
var run = function run(req, res) {
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
    logWarn('Inactives report: not all fields supplied.');
    return res.redirect(cfg.path.reportForm);
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
  res.setHeader('Content-Disposition', 'inline; PhilHealthDaily.pdf');

  doReport(flds, writable, req, res);
};


module.exports = {
  run: run
};
