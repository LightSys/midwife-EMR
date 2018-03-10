/*
 * -------------------------------------------------------------------------------
 * hepbRpt.js
 *
 * Produces the baby Hep B report.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Bookshelf = require('bookshelf')
  , PDFDocument = require('pdfkit')
  , fs = require('fs')
  , os = require('os')
  , util = require('util')
  , path = require('path')
  , Baby = require('../models').Baby
  , Labor = require('../models').Labor
  , LaborStage2 = require('../models').LaborStage2
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , BabyVaccination = require('../models').BabyVaccination
  , BabyVaccinations = require('../models').BabyVaccinations
  , BabyVaccinationType = require('../models').BabyVaccinationType
  , BabyVaccinationTypes = require('../models').BabyVaccinationTypes
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
  , NO_RECORDS_FOUND_TYPE = 1000
  ;


/* --------------------------------------------------------
 * combine()
 *
 * Combine strings with the separator passed, ignoring null
 * and undefined strings in the process.
 * -------------------------------------------------------- */
var combine = function(...args) {
  var sep = args.shift()
    , result = ''
    ;

  _.each(args, function(arg) {
    if (result.length > 0) {
      if (arg) result += sep + arg.trim();
    } else {
      if (arg) result = arg.trim();
    }
  });
  return result;
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


var doBabyNameHeader = function(doc, opts) {
  var y = 90
    x = 200
    ;

  doc
    .fontSize(20)
    .font(FONTS.HelveticaBold)
    .text("Baby's Name", x, y);

  doc
    .fontSize(11)
    .font(FONTS.Helvetica);
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
  x += 62; xPos.push(x);                // Date of birth
  x += 110; xPos.push(x);               // Baby Lastname
  x += 127; xPos.push(x);               // Baby Firstname
  x += 110; xPos.push(x);                // Baby Middlename
  x += 120; xPos.push(x);                // Address
  x += 58; xPos.push(x);                // Time of birth
  x += 48; xPos.push(x);                // Weight
  x += 62; xPos.push(x);                // Date of Hep B
  x += 58; xPos.push(x);                // Time of Hep B
  x += 50; xPos.push(x);                // within 24 hours

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
    , width = doc.page.width - doc.page.margins.right - doc.page.margins.left
    , height = 40
    , colPos = getColXpos(opts)
    , largeFont = 11
    , smallFont = 8
    , y = 100
    , y2 = y + (height/2) - (largeFont/2)
    ;

  // --------------------------------------------------------
  // Headings
  // --------------------------------------------------------
  // Date of birth
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Date', colPos[0], colPos[1], y);
  centerInCol(doc, 'of Birth', colPos[0], colPos[1], y2);

  // Baby Lastname
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Last', colPos[1], colPos[2], y2);

  // Baby Firstname
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'First', colPos[2], colPos[3], y2);

  // Baby Middlename
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Middle', colPos[3], colPos[4], y2);

  // Address
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Address', colPos[4], colPos[5], y2);

  // Time of birth
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Time', colPos[5], colPos[6], y);
  centerInCol(doc, 'of Birth', colPos[5], colPos[6], y2);

  // Weight
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Weight', colPos[6], colPos[7], y2);

  // Date of Hep B
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Date of', colPos[7], colPos[8], y);
  centerInCol(doc, 'Hep B', colPos[7], colPos[8], y2);

  // Time of Hep B
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'Time of', colPos[8], colPos[9], y);
  centerInCol(doc, 'Hep B', colPos[8], colPos[9], y2);

  // Hep B within 24 hours
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, 'HepB in', colPos[9], colPos[10], y);
  centerInCol(doc, '24 hrs', colPos[9], colPos[10], y2);
};


var doPages = function(doc, data, rowsPerPage, totalBirths, opts) {
  var currentRow = 0
    , pageNum = 1
    , totalVaccinations = data.rows.length
    , totalPages = Math.ceil(data.rows.length / rowsPerPage)
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary. If there is no
  // data, still create a page with no data.
  // --------------------------------------------------------
  doSiteTitleLong(doc, 24);
  doReportName(doc, opts.title, 48);
  doFromTo(doc, opts);
  doBabyNameHeader(doc, opts);
  doColumnHeader(doc, opts);
  doFooter(doc, pageNum, totalPages, totalVaccinations, totalBirths, opts);
  _.each(data.rows, function(rec) {
    doRow(doc, rec, opts, currentRow, 20);
    currentRow++;
    if (currentRow >= rowsPerPage) {
      doc.addPage();
      currentRow = 0;
      pageNum++;
      doSiteTitle(doc, 24);
      doReportName(doc, opts.title, 48);
      doFromTo(doc, opts);
      doBabyNameHeader(doc, opts);
      doColumnHeader(doc, opts);
      doFooter(doc, pageNum, totalPages, totalVaccinations, totalBirths, opts);
    }
  });
};


/* --------------------------------------------------------
 * doRow()
 *
 * Writes a row on the report including borders and text.
 *
 * param      doc
 * param      row
 * param      opts
 * param      rowNum
 * param      rowHeight
 * return     undefined
 * -------------------------------------------------------- */
var doRow = function(doc, row, opts, rowNum, rowHeight) {
  var cells = []
    , startX = doc.page.margins.left
    , startY = 130 + (rowNum * rowHeight)
    , fontSize = 11
    , smallFontSize = 8
    , textY = startY + (rowHeight/2) - (fontSize/2) + 2
    , textAddressY = startY + (rowHeight/2) - (smallFontSize/2) - 3
    , colPadLeft = 2
    , colPos = getColXpos(opts)
    , tmpStr
    , birthDatetime
    , vacDatetime
    , duration

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
  tmpStr = moment(row.birthDatetime).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[0], colPos[1], textY);

  // Lastname
  doc.text(row.lastname.toUpperCase(), colPos[1] + colPadLeft, textY);

  // Firstname
  doc.text(row.firstname.toUpperCase(), colPos[2] + colPadLeft, textY);

  // Middlename
  doc.text(row.middlename.toUpperCase(), colPos[3] + colPadLeft, textY);

  // Address
  // --------------------------------------------------------
  // "Highlight" the address cell if the client resides in Agdao
  // per the custom fields. This really is not a PDFKit
  // hightlight - we draw a yellow filled rectangle in the cell
  // but it has the effect that we want.
  // --------------------------------------------------------
  if (row.booleanVal) {
    doc
      .rect(colPos[4] + 2, textAddressY - 1, colPos[5] - colPos[4] - 5, rowHeight - 4)
      .fill('yellow');
    doc.fillColor('black');     // Set back to black.
  }

  // --------------------------------------------------------
  // We wrap the address on two lines using a smaller font.
  // --------------------------------------------------------
  doc
    .fontSize(smallFontSize);
  tmpStr = combine(', ', row.address1, row.address4, row.city, row.state);
  doc.text(tmpStr, colPos[4] + colPadLeft, textAddressY, {width: colPos[5] - colPos[4], height: rowHeight});

  // Time of birth
  doc
    .fontSize(fontSize);
  tmpStr = moment(row.birthDatetime).format('hh:mm A');
  centerInCol(doc, tmpStr, colPos[5], colPos[6], textY);

  // Time of birth
  tmpStr = row.birthWeight;
  centerInCol(doc, tmpStr, colPos[6], colPos[7], textY);

  // Date of Hep B
  tmpStr = moment(row.vaccinationDate).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[7], colPos[8], textY);

  // Time of Hep B
  tmpStr = moment(row.vaccinationDate).format('hh:mm A');
  centerInCol(doc, tmpStr, colPos[8], colPos[9], textY);

  // Hep B with in 24 hours
  birthDatetime = moment(row.birthDatetime);
  vacDatetime = moment(row.vaccinationDate);
  duration = vacDatetime.diff(birthDatetime);
  if (moment.duration(duration).asMinutes() < 1440) {
    tmpStr = 'Yes';
  } else {
    tmpStr = 'No';
  }
  centerInCol(doc, tmpStr, colPos[9], colPos[10], textY);
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
 * param      totalBirths
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, pageNum, totalPages, totalPcs, totalBirths, opts) {
  var largeFontSize = 15
    , smallFontSize = 12
    , leftX = doc.page.margins.left
    , centerX = doc.page.width / 2
    , y = doc.page.height - opts.margins.bottom -
        ((largeFontSize + smallFontSize)*1.5)
    , y2 = y + largeFontSize
    , str
    , str2
    , x
    , len
    , len2
    ;

  // Lower left
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(smallFontSize)
    .text('Total number of births: ' + totalBirths, leftX, y)
    .text('Total number of Hep B given: ' + totalPcs, leftX, y2);

  // Lower center
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFontSize);
  str = 'Page ' + pageNum + ' of ' + totalPages;
  x = centerX - (doc.widthOfString(str)/2);
  doc.text(str, x, y);

  // Lower right
  doc.font(FONTS.HelveticaBold).fontSize(largeFontSize);
  str = opts.logisticsName;
  len = doc.widthOfString(str);
  doc.font(FONTS.Helvetica).fontSize(smallFontSize);
  str2 = 'MMC Vaccine In-Charge';
  len2 = doc.widthOfString(str2);
  if (len >= len2) {
    x = doc.page.width - opts.margins.right - len - 5;
  } else {
    x = doc.page.width - opts.margins.right - len2 - 5;
  }
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFontSize)
    .text(str, x, y);
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFontSize)
    .text(str2, x, y2);
};


var getData = function(dateFrom, dateTo) {
  var knex = Bookshelf.DB.knex
    , sql
    , sql2
    , data = {}
    , fixedDateTo = moment(dateTo).add(1, 'days').format('YYYY-MM-DD')
    ;

  sql =  'SELECT ls2.birthDatetime, b.lastname, b.firstname, b.middlename, p.address1, ';
  sql += 'p.address2, p.address3, p.address4, p.city, p.state, p.id, b.birthWeight, ' ;
  sql += 'bv.vaccinationDate, cf.booleanVal ';
  sql += 'FROM babyVaccinationType bvt INNER JOIN babyVaccination bv ON bv.babyVaccinationType = bvt.id '
  sql += 'INNER JOIN baby b ON bv.baby_id = b.id ';
  sql += 'INNER JOIN labor l ON b.labor_id = l.id ';
  sql += 'INNER JOIN laborStage2 ls2 ON ls2.labor_id = l.id ';
  sql += 'INNER JOIN pregnancy p ON l.pregnancy_id = p.id ';
  sql += 'INNER JOIN customField cf ON p.id = cf.pregnancy_id ';
  sql += 'INNER JOIN customFieldType cft ON cf.customFieldType_id = cft.id ';
  sql += 'WHERE ls2.birthDatetime >= "' + dateFrom + '" ';
  sql += 'AND ls2.birthDatetime <= "' + fixedDateTo + '" ';
  sql += 'AND bvt.name LIKE "%Hep B%"';

  sql2 =  'SELECT COUNT(*) AS count FROM baby b ';
  sql2 += 'INNER JOIN labor l ON l.id = b.labor_id ';
  sql2 += 'INNER JOIN laborStage2 ls2 ON ls2.labor_id = l.id ';
  sql2 += 'WHERE ls2.birthDatetime >= "' + dateFrom + '" ';
  sql2 += 'AND ls2.birthDatetime <= "' + fixedDateTo + '" ';

  return new Promise(function(resolve, reject) {
    knex
      .raw(sql)
      .then(function(resp) {
        // Data array is the first element of the array.
        return resp[0];
      })
      .then(function(rows) {
        data.rows = rows;

        // --------------------------------------------------------
        // Convert nulls into empty strings for string fields.
        // --------------------------------------------------------
        _.each(data.rows, function(row) {
          if (! row.middlename) row.middlename = '';
          if (! row.lastname) row.lastname = '';
          if (! row.firstname) row.firstname = '';
          if (! row.address1) row.address1 = '';
          if (! row.address2) row.address2 = '';
          if (! row.address3) row.address3 = '';
          if (! row.address4) row.address4 = '';
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the total number of babies born during this period.
        // --------------------------------------------------------
        return knex
          .raw(sql2)
          .then(function(resp) {
            var count = _.flatten(resp)[0].count;
            return count;
          });
      })
      .then(function(count) {
        data.count = count;
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
        , layout: 'landscape'
        , size: 'A4'
        , info: {
            Title: 'Birth Dose HEP B Report'
            , Author: 'Midwife-EMR Application'
            , Subject: 'Hep B Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 19    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = flds.dateFrom;
  opts.toDate = flds.dateTo;
  opts.margins = options.margins;
  opts.logisticsName = logisticsName;
  opts.title = options.info.Title;
  opts.logisticsName = logisticsName

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  // Build the parts of the document.
  // Note that the result from the promise will either be a list
  // or an Error.
  getData(opts.fromDate, opts.toDate)
    .then(function(result) {
      if (_.isArray(result.rows)) {
        opts.totalRows = result.rows.length;
        doPages(doc, result, rowsPerPage, result.count, opts);
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
      res.setHeader('Content-Disposition', 'inline; HepB-Report.pdf');
      res.setHeader('Content-Transfer-Encoding', 'binary');
      res.setHeader('Content-Length', ('' + size));
      fs.createReadStream(filePath).pipe(res);
      fs.unlink(filePath);
    });
  });

  // --------------------------------------------------------
  // Get the displayName for the director in charge.
  // --------------------------------------------------------
  User.findDisplayNameById(Number(flds.inCharge), function(err, name) {
    if (err) throw err;
    if (! name) name = '';
    doReport(flds, writable, name);
  });
};


module.exports = {
  run: run
};

