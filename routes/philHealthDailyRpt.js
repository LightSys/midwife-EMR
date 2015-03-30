/* 
 * -------------------------------------------------------------------------------
 * philHealthDailyRpt.js
 *
 * An admission and discharge daily report for Phil Health.
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
  , getGA = require('../util').getGA
  , calcEdd = require('../util').calcEdd
  , isValidDate = require('../util').isValidDate
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , centerInCol = require('./reportGeneral').centerInCol
  , Event = require('../models').Event
  , EventType = require('../models').EventType
  , Pregnancy = require('../models').Pregnancy
  , Patient = require('../models').Patient
  , dateDisplayFormat = 'MM/DD/YYYY'  // TODO: localization
  , timeDisplayFormat = 'HH:mm A'
  , prenatalCheckInId         // set in getData()
  , prenatalCheckOutId
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
    , checkInRecs
    , checkOutRecs
    , pregRecs
    , patRecs
    , data = []
    , msg
    ;

  // --------------------------------------------------------
  // Add a day to the dateTo because dateTo does not have a
  // time element and will be interpreted as midnight at the
  // beginning of dateTo while we need to include the day of
  // dateTo as well.
  // --------------------------------------------------------
  dateTo = moment(dateTo).add(1, 'days').format('YYYY-MM-DD');

  return new Promise(function(resolve, reject) {
    // --------------------------------------------------------
    // Get the eventType ids.
    // --------------------------------------------------------
    new EventType()
      .fetchAll()
      .then(function(evtTypes) {
        var list = evtTypes.toJSON();
        // Stored at the module level.
        prenatalCheckInId = _.findWhere(list, {name: 'prenatalCheckIn'}).id;
        prenatalCheckOutId = _.findWhere(list, {name: 'prenatalCheckOut'}).id;
      })
      // --------------------------------------------------------
      // Get the checkin records.
      // --------------------------------------------------------
      .then(function() {
        return new Event().query()
          .select(['pregnancy_id AS pregnancyId', 'eDateTime AS checkIn'])
          .where('eventType', '=', prenatalCheckInId)
          .andWhere('eDateTime', '>', dateFrom)
          .andWhere('eDateTime', '<', dateTo)
          .orderBy('eDateTime', 'ASC');
      })
      .then(function(checkIn) {
        checkInRecs = checkIn;
      })
      // --------------------------------------------------------
      // Get the checkout records.
      // --------------------------------------------------------
      .then(function() {
        return new Event().query()
          .select(['pregnancy_id AS pregnancyId', 'eDateTime AS checkOut'])
          .where('eventType', '=', prenatalCheckOutId)
          .andWhere('eDateTime', '>', dateFrom)
          .andWhere('eDateTime', '<', dateTo)
          .orderBy('eDateTime', 'ASC');
      })
      .then(function(checkOut) {
        checkOutRecs = checkOut;
      })
      // --------------------------------------------------------
      // Get the pregnancy data for the affected pregnancies.
      // --------------------------------------------------------
      .then(function() {
        var pregIds = _.uniq(_.pluck(checkInRecs, 'pregnancyId'))
          ;
        if (pregIds.length === 0) {
          msg = 'No records found using the dates specified.';
          return [];
        }
        return new Pregnancy().query()
          .whereIn('id', pregIds)
          .select(['id', 'firstname', 'lastname', 'maidenname', 'address1',
            'address3', 'address4', 'city', 'lmp', 'sureLMP', 'alternateEdd',
            'useAlternateEdd', 'philHealthMCP', 'philHealthNCP', 'philHealthID',
            'philHealthApproved', 'patient_id']);
      })
      .then(function(pregs) {
        pregRecs = pregs;
      })
      // --------------------------------------------------------
      // Get the patient data for the affected pregnancies.
      // --------------------------------------------------------
      .then(function() {
        if (pregRecs.length === 0) {
          // No records found.
          return [];
        }
        var patIds = _.uniq(_.pluck(pregRecs, 'patient_id'));
        return new Patient().query()
          .whereIn('id', patIds)
          .select(['id', 'dohID', 'dob']);
      })
      .then(function(pat) {
        patRecs = pat;
      })
      // --------------------------------------------------------
      // Assemble the data for the caller.
      // --------------------------------------------------------
      .then(function() {
        _.each(checkInRecs, function(cin) {
          var checkIn = moment(cin.checkIn);
          var couts = _.where(checkOutRecs, {pregnancyId: cin.pregnancyId});
          _.each(couts, function(cout) {
            var checkOut = moment(cout.checkOut);
            var dataRec;
            var patRec;
            if (checkOut.isAfter(checkIn) && checkIn.dayOfYear() === checkOut.dayOfYear()) {
              if (! cout.used) {
                dataRec = _.findWhere(pregRecs, {id: cin.pregnancyId});
                if (dataRec) {
                  patRec = _.findWhere(patRecs, {id: dataRec.patient_id});
                  if (patRec) {
                    dataRec.pregnancyId = cin.pregnancyId;
                    dataRec.checkInDate = moment(cin.checkIn);
                    dataRec.checkInTime = moment(cin.checkIn);
                    dataRec.checkOutDate = moment(cout.checkOut);
                    dataRec.checkOutTime = moment(cout.checkOut);
                    dataRec.patient = patRec;
                    data.push(dataRec);
                    cout.used = true;   // flag this checkout record as already used.
                  } else {
                    // Should not get here ...
                    logError('Error: patient record not found.');
                  }
                } else {
                  // Should not get here ...
                  logError('Error: pregnancy record not found.');
                }
              }
            }
          });
        });
      })
      .then(function() {
        if (data.length > 0) {
          resolve(data);
        } else {
          reject(msg);
        }
      })
      .caught(function(err) {
        logError(err);
        reject(err);
      });
  });
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
  centerText(doc, title, FONTS.Helvetica, 32, 25);
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
    , y = 80
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

  tmpStr = 'Date of';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[1], colPos[2], upperY);
  tmpStr = 'Adm';
  centerInCol(doc, tmpStr, colPos[1], colPos[2], y);

  tmpStr = 'Time of';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], upperY);
  tmpStr = 'Adm';
  centerInCol(doc, tmpStr, colPos[2], colPos[3], y);

  tmpStr = 'Last Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[3], colPos[4], y);

  tmpStr = 'First Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[4], colPos[5], y);

  tmpStr = 'Middle Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[5], colPos[6], y);

  tmpStr = 'Date of';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[6], colPos[7], upperY);
  tmpStr = 'Birth';
  centerInCol(doc, tmpStr, colPos[6], colPos[7], y);

  tmpStr = 'Address';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[7], colPos[8], y);

  tmpStr = 'Brgy';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[8], colPos[9], y);

  tmpStr = 'District';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[9], colPos[10], y);

  tmpStr = 'NN';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[10], colPos[11], upperY);
  tmpStr = 'NH';
  centerInCol(doc, tmpStr, colPos[10], colPos[11], y);

  tmpStr = 'Adm Dx';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[11], colPos[12], y);

  tmpStr = 'Date of';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[12], colPos[13], upperY);
  tmpStr = 'D/C';
  centerInCol(doc, tmpStr, colPos[12], colPos[13], y);

  tmpStr = 'Time of';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[13], colPos[14], upperY);
  tmpStr = 'D/C';
  centerInCol(doc, tmpStr, colPos[13], colPos[14], y);

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
    , startY = 95 + (rowNum * rowHeight)
    , fontSize = 10
    , textY = startY + 5
    , textY2 = textY + fontSize + 2
    , colPadLeft = 2
    , colPos = getColXpos(opts)
    , tmpStr
    , tmpStr2
    , edd
    , ga
    , refDate
    , tmpFld
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
  // MMC ID
  tmpStr = formatDohID(data.patient.dohID, true);
  centerInCol(doc, tmpStr, colPos[0], colPos[1], textY);

  // Date of Adm
  tmpStr = data.checkInDate.format(dateDisplayFormat);
  centerInCol(doc, tmpStr, colPos[1], colPos[2], textY);

  // Time of Adm
  tmpStr = data.checkInTime.format(timeDisplayFormat);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], textY);

  // Lastname
  tmpStr = data.lastname;
  doc.text(tmpStr, colPos[3] + colPadLeft, textY);

  // Firstname
  tmpStr = data.firstname;
  doc.text(tmpStr, colPos[4] + colPadLeft, textY);

  // Middle name (this is really the maidenname)
  tmpStr = data.maidenname;
  if (tmpStr) doc.text(tmpStr, colPos[5] + colPadLeft, textY);

  // Date of birth
  tmpStr = moment(data.patient.dob).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[6], colPos[7], textY);

  // Address
  tmpStr = data.address1 + ', ' + data.city;
  tmpWidth = doc.widthOfString(tmpStr);   // address1 length
  tmpWidth2 = colPos[8] - colPos[7];      // column width
  if (tmpWidth > tmpWidth2) {
    tmpStr2 = tmpStr.slice(((tmpStr.length * tmpWidth2)/tmpWidth) - 1);
    tmpStr = tmpStr.slice(0, ((tmpStr.length * tmpWidth2)/tmpWidth) - 1);
    doc.text(tmpStr, colPos[7] + colPadLeft, textY);
    doc.text(tmpStr2, colPos[7] + colPadLeft, textY2);
  } else {
    doc.text(tmpStr, colPos[7] + colPadLeft, textY);
  }

  // Barangay
  tmpStr = data.address3;
  doc.text(tmpStr, colPos[8] + colPadLeft, textY);

  // District
  tmpStr = data.address4 || '';
  doc.text(tmpStr, colPos[9] + colPadLeft, textY);

  // NN / NH
  tmpStr = 'NN';
  if (data.philHealthMCP || data.philHealthNCP) tmpStr = 'NH';
  centerInCol(doc, tmpStr, colPos[10], colPos[11], textY);

  // Adm Dx (GA calculation)
  // Anything 37 weeks GA or over is considered pregnancy uterine full term (PUFT),
  // otherwise just pregnancy uterine (PU).
  tmpStr2 = 'PU ';
  refDate = data.checkInDate;
  if (data.useAlternateEdd && _.isDate(data.alternateEdd)) {
    edd = moment(data.alternateEdd);
  } else {
    if (data.lmp && _.isDate(data.lmp)) {
      edd = moment(data.lmp).add(280, 'days');
    }
  }
  if (edd) {
    ga = getGA(edd, refDate);
    if (ga && ga.length > 0 && parseInt(ga.split(' ')[0], 10) > 36) {
      tmpStr2 = 'PUFT ';
    }
    tmpStr = tmpStr2 + ga;
    centerInCol(doc, tmpStr, colPos[11], colPos[12], textY);
  }

  // Date of Adm
  tmpStr = data.checkOutDate.format(dateDisplayFormat);
  centerInCol(doc, tmpStr, colPos[12], colPos[13], textY);

  // Time of Adm
  tmpStr = data.checkOutTime.format(timeDisplayFormat);
  centerInCol(doc, tmpStr, colPos[13], colPos[14], textY);
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
  x += 57; xPos.push(x);                // Date of Adm
  x += 50; xPos.push(x);                // Time of Adm
  x += 100; xPos.push(x);               // Last name
  x += 100; xPos.push(x);               // First name
  x += 78; xPos.push(x);                // Middle Name
  x += 57; xPos.push(x);                // Date of Birth
  x += 155; xPos.push(x);               // Address
  x += 85; xPos.push(x);                // Brgy
  x += 53; xPos.push(x);                // District
  x += 20; xPos.push(x);                // NN / NH
  x += 62; xPos.push(x);                // Adm DX
  x += 57; xPos.push(x);                // Date of D/C
  x += 50; xPos.push(x);                // Time of D/C

  return xPos;
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
    , y = 560
    ;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(11)
    .text('Reporting Period: ', 18, y)
    .font(FONTS.Helvetica)
    .fontSize(11)
    .text(fromDate + ' to ' + toDate, 18, y + 14);
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
    , y = 560
    ;

  doc.font(FONTS.HelveticaBold).fontSize(largeFont);
  str =  'Page ' + pageNum + ' of ' + totalPages;
  len = doc.widthOfString(str);
  x = doc.page.width - opts.margins.right - len - paddingRight;
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
    doRow(doc, rec, opts, currentRow, 30);
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
        , layout: 'landscape'
        , size: 'legal'
        , info: {
            Title: cfg.site.titleLong + ' Daily Admission and Discharge'
            , Author: 'Midwife-EMR Application'
            , Subject: 'PhilHealth Daily Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 15    // Number of rows per page of this report.
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
 * Create the summary report for a patient.
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
    logWarn('PhilHealth Daily report: not all fields supplied.');
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
  res.setHeader('Content-Disposition', 'inline; PhilHealthDaily.pdf');

  doReport(flds, writable, req, res);
};

module.exports = {
  run: run
};
