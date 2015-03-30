/*
 * -------------------------------------------------------------------------------
 * vaccinationRpt.js
 *
 * Required report for health statistics regarding vaccinations dispensed.
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
  , Vaccination = require('../models').Vaccination
  , Vaccinations = require('../models').Vaccinations
  , VaccinationType = require('../models').VaccinationType
  , VaccinationTypes = require('../models').VaccinationTypes
  , PrenatalExam = require('../models').PrenatalExam
  , PrenatalExams = require('../models').PrenatalExams
  , User = require('../models').User
  , CustomField = require('../models').CustomField
  , CustomFields = require('../models').CustomFields
  , CustomFieldType = require('../models').CustomFieldType
  , CustomFieldTypes = require('../models').CustomFieldTypes
  , LabTestResult = require('../models').LabTestResult
  , LabTestResults = require('../models').LabTestResults
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
  , doReportName = require('./reportGeneral').doReportName
  , doCellBorders = require('./reportGeneral').doCellBorders
  , centerInCol = require('./reportGeneral').centerInCol
  ;


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

  // Lastname
  tmpStr = 'Last Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[1], colPos[2], y);

  // Firstname
  tmpStr = 'First Name';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], y);

  // Age
  tmpStr = 'Age';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[3], colPos[4], y);

  // LMP
  tmpStr = 'LMP';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[4], colPos[5], y);

  // GP
  tmpStr = 'GP';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[5], colPos[6], y);

  // Address
  tmpStr = 'Address';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[6], colPos[7], y);

  // AOG
  tmpStr = 'AOG';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[7], colPos[8], y);

  // Weight
  tmpStr = 'Wt';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[8], colPos[9], y);

  // BP
  tmpStr = 'BP';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[9], colPos[10], y);

  // CR
  tmpStr = 'CR';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[10], colPos[11], y);

  // RR
  tmpStr = 'RR';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[11], colPos[12], y);

  // UA WBC
  tmpStr = 'UA';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[12], colPos[13], y - 6);
  centerInCol(doc, 'WBC', colPos[12], colPos[13], y + 2);

  // UA RBC
  tmpStr = 'UA';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[13], colPos[14], y - 6);
  centerInCol(doc, 'RBC', colPos[13], colPos[14], y + 2);

  // Temp
  tmpStr = 'Temp';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[14], colPos[15], y + 2);

  // BT
  tmpStr = 'BT';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[15], colPos[16], y);

  // HBSAG
  tmpStr = 'HBSAG';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[16], colPos[17], y + 2);

  // Hct
  tmpStr = 'Hct';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[17], colPos[18], y);

  // Hgb
  tmpStr = 'Hgb';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[18], colPos[19], y);

  // TT
  tmpStr = 'TT' + opts.reportNum;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(largeFont);
  centerInCol(doc, tmpStr, colPos[19], colPos[20], y);
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
  x += 45; xPos.push(x);                // Date
  x += 60; xPos.push(x);                // Lastname
  x += 68; xPos.push(x);                // Firstname
  x += 15; xPos.push(x);                // Age
  x += 45; xPos.push(x);                // LMP
  x += 16; xPos.push(x);                // GP
  x += 158; xPos.push(x);               // Address
  x += 42; xPos.push(x);                // AOG
  x += 22; xPos.push(x);                // Weight
  x += 32; xPos.push(x);                // Blood Pressure
  x += 16; xPos.push(x);                // CR
  x += 16; xPos.push(x);                // RR
  x += 23; xPos.push(x);                // UA WBC
  x += 23; xPos.push(x);                // UA RBC
  x += 22; xPos.push(x);                // Temp
  x += 16; xPos.push(x);                // Blood Type
  x += 45; xPos.push(x);                // HBSAG
  x += 22; xPos.push(x);                // Hct
  x += 22; xPos.push(x);                // Hgb
  x += 45; xPos.push(x);                // TT date

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
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, pageNum, totalPages, totalPcs, opts) {
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

  // Lower left
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(smallFontSize)
    .text('TT' + opts.reportNum + '    -     ' + totalPcs, leftX, y);

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
  y += largeFontSize;
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFontSize)
    .text(str2, x, y);
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
  var vacTypeIds
    , pregIds
    , data
    ;
  return new Promise(function(resolve, reject) {
    // --------------------------------------------------------
    // First get the ids of the vaccinations we are interested in.
    // --------------------------------------------------------
    new VaccinationTypes().query()
      .where('name', 'LIKE', '%Tetanus%')
      .select(['id'])
      .then(function(vacTypes) {
        vacTypeIds = _.pluck(vacTypes, 'id');
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the pregnancy ids we need.
        // --------------------------------------------------------
        var query = new Vaccinations().query()
          .distinct('vaccination.pregnancy_id')
          .whereIn('vaccination.vaccinationType', vacTypeIds)
          .andWhere('vaccination.vacDate', '>=', dateFrom)
          .andWhere('vaccination.vacDate', '<=', dateTo)
          .andWhere('vaccination.administeredInternally', '=', 1);
        return query.select();
      })
      .then(function(list) {
        pregIds = _.pluck(list, 'pregnancy_id');

        // --------------------------------------------------------
        // If there are no matching records, we continue by using
        // a non-existent pregnancy id to allow the queries below
        // to continue though they will produce no records also.
        // This allows a report to be generated with no patient
        // data, which of course means that there are no records.
        // Otherwise, it blows up ... it is just easier this way.
        // --------------------------------------------------------
        if (pregIds.length === 0) {
          logInfo('Vaccination report with no matching records.');
          pregIds = [-1];
        }
      })
      .then(function() {
        // Now query the data restricted to those ids.
        // Note that this will get more than we need, but we need it
        // in order to determine if this is TT 1, 2, 3, 4, or 5.
        // The sort by pregnancy.id then vaccination.vacDate is important
        // for the processing to follow.
        var query = new Vaccinations().query()
          .column('vaccination.id', 'vaccination.vacDate', 'vaccination.vaccinationType', 'vaccination.note', 'vaccination.pregnancy_id')
          .join('vaccinationType', 'vaccination.vaccinationType', '=', 'vaccinationType.id')
          .column('vaccinationType.name', 'vaccinationType.description')
          .join('pregnancy', 'vaccination.pregnancy_id', '=', 'pregnancy.id')
          .column('pregnancy.lastname', 'pregnancy.firstname', 'pregnancy.lmp', 'pregnancy.gravida', 'pregnancy.para', 'pregnancy.address1', 'pregnancy.city')
          .join('patient', 'pregnancy.patient_id', '=', 'patient.id')
          .column('patient.dob')
          .whereIn('vaccination.vaccinationType', vacTypeIds)
          .whereIn('vaccination.pregnancy_id', pregIds)
          .orderByRaw('pregnancy.id ASC, vaccination.vacDate ASC');
        return query.select();
      })
      .then(function(list) {
        data = list;
        // --------------------------------------------------------
        // Add all of the placeholders for the data obtained below.
        // --------------------------------------------------------
        _.each(data, function(rec) {
          rec.prenatals = [];
          rec.labTestResults = [];
          rec.customFields = [];
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the prenatal exams sorted by date.
        // --------------------------------------------------------
        return new PrenatalExams().query()
          .column('prenatalExam.id', 'prenatalExam.date', 'prenatalExam.weight',
              'prenatalExam.systolic', 'prenatalExam.diastolic',
              'prenatalExam.cr', 'prenatalExam.respiratoryRate',
              'prenatalExam.temperature', 'prenatalExam.pregnancy_id')
          .innerJoin('pregnancy', 'pregnancy.id', 'prenatalExam.pregnancy_id')
          .whereIn('prenatalExam.pregnancy_id', pregIds)
          .orderByRaw('prenatalExam.pregnancy_id ASC, prenatalExam.date ASC')
          .select();
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Add the prenatal information to the records to be returned.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var preExams = _.where(data, {pregnancy_id: rec.pregnancy_id});
          _.each(preExams, function(pe) {
            pe.prenatals.push(_.omit(rec, ['pregnancy_id']));
          });
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the lab tests that are needed sorted by date.
        // --------------------------------------------------------
        return new LabTestResults().query()
          .column('labTestResult.id', 'labTestResult.testDate',
              'labTestResult.result', 'labTestResult.result2',
              'labTestResult.labTest_id', 'labTestResult.pregnancy_id',
              'labTest.name', 'labTest.abbrev', 'labTest.labSuite_id')
          .innerJoin('labTest', 'labTest.id', 'labTestResult.labTest_id')
          .whereIn('labTestResult.pregnancy_id', pregIds)
          .andWhere('labTest.abbrev', '=', 'wbc')
          .orWhere('labTest.abbrev', '=', 'rbc-urine')
          .orWhere('labTest.abbrev', '=', 'HBsAg')
          .orWhere('labTest.abbrev', '=', 'Blood type')
          .orWhere('labTest.abbrev', '=', 'Hct')
          .orWhere('labTest.abbrev', '=', 'Hgb')
          .orderByRaw('labTestResult.pregnancy_id ASC, labTestResult.testDate ASC')
          .select();
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Add the lab test results to the records to be returned.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var labResults = _.where(data, {pregnancy_id: rec.pregnancy_id});
          _.each(labResults, function(lr) {
            lr.labTestResults.push(_.omit(rec, ['pregnancy_id']));
          });
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
    , startY = 90 + (rowNum * rowHeight)
    , fontSize = 8
    , textY = startY + (rowHeight/2) - (fontSize/2) + 2
    , colPadLeft = 2
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
  tmpStr = moment(data.vacDate).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[0], colPos[1], textY);

  // Lastname
  doc.text(data.lastname.toUpperCase(), colPos[1] + colPadLeft, textY);

  // Firstname
  doc.text(data.firstname.toUpperCase(), colPos[2] + colPadLeft, textY);

  // Age
  if (data.dob && moment(data.dob).isValid()) {
    tmpStr = moment().diff(moment(data.dob), 'years');
    centerInCol(doc, tmpStr, colPos[3], colPos[4], textY);
  }

  // LMP
  if (_.isDate(data.lmp)) {
    tmpStr = moment(data.lmp).format('MM/DD/YYYY');
    centerInCol(doc, tmpStr, colPos[4], colPos[5], textY);
  }

  // GP
  tmpStr = _.isNull(data.gravida)? '0': data.gravida;
  tmpStr += '-';
  tmpStr += _.isNull(data.para)? '0': data.para;
  centerInCol(doc, tmpStr, colPos[5], colPos[6], textY);

  // --------------------------------------------------------
  // "Highlight" the address cell if the client resides in Agdao
  // per the custom fields. This really is not a PDFKit
  // hightlight - we draw a yellow filled rectangle in the cell
  // but it has the effect that we want.
  // --------------------------------------------------------
  if (data.customFields && data.customFields.length > 0 &&
      _.findWhere(data.customFields, {name: 'Agdao'})) {
    doc
      .rect(colPos[6] + 2, textY - 3, colPos[7] - colPos[6] - 5, rowHeight - 4)
      .fill('yellow');
    doc.fillColor('black');     // Set back to black.
  }

  // Address
  tmpStr = data.address1 + ', ' + data.city;
  tmpWidth = doc.widthOfString(tmpStr);   // address1 length
  tmpWidth2 = colPos[7] - colPos[6];      // column width
  if (tmpWidth > tmpWidth2) {
    tmpStr = tmpStr.slice(0, ((tmpStr.length * tmpWidth2)/tmpWidth) - 1);
  }
  doc.text(tmpStr, colPos[6] + colPadLeft, textY);

  // AOG calculated as of the from date of the report
  // TODO: does this need to be PUFT if 37 weeks or more like on the Phil Health
  // daily report?
  tmpStr = '';
  try {
    // Don't lose our heads if lmp field contains no date.
    tmpStr = 'PU ' + getGA(calcEdd(data.lmp), opts.fromDate);
  } catch (err) { }
  if (tmpStr.length > 2) {
    // Only print if we have actual data.
    centerInCol(doc, tmpStr, colPos[7], colPos[8], textY);
  }

  // Weight - we take the most recent prenatalExam
  // Note: if this report is run historically, the most recent
  // prenatal exam may be significantly after the tetanus shot.
  if (data.prenatals.length > 0) {
    pe = _.last(data.prenatals);
    tmpStr = pe.weight || '';
    centerInCol(doc, tmpStr, colPos[8], colPos[9], textY);
  }

  // Blood Pressure
  if (pe) {
    tmpStr = pe.systolic + '/' + pe.diastolic;
    centerInCol(doc, tmpStr, colPos[9], colPos[10], textY);
  }

  // CR
  if (pe) {
    tmpStr = pe.cr || '';
    centerInCol(doc, tmpStr, colPos[10], colPos[11], textY);
  }

  // RR - this is blank since we do not record it.
  if (pe) {
    tmpStr = pe.respiratoryRate || '';
    centerInCol(doc, tmpStr, colPos[11], colPos[12], textY);
  }

  // U/A WBC
  if (data.labTestResults.length > 0) {
    ltr = _.last(_.where(data.labTestResults, {abbrev: 'wbc'}));
    if (ltr) {
      tmpStr = ltr.result;
      if (ltr.result2) tmpStr += '-' + ltr.result2;
      centerInCol(doc, tmpStr, colPos[12], colPos[13], textY);
    }
  }

  // U/A RBC
  if (data.labTestResults.length > 0) {
    ltr = _.last(_.where(data.labTestResults, {abbrev: 'rbc-urine'}));
    if (ltr) {
      tmpStr = ltr.result;
      if (ltr.result2) tmpStr += '-' + ltr.result2;
      centerInCol(doc, tmpStr, colPos[13], colPos[14], textY);
    }
  }

  // Temp - this is blank since we do not record it.
  if (pe) {
    tmpStr = pe.temperature || '';
    centerInCol(doc, tmpStr, colPos[14], colPos[15], textY);
  }

  // Blood Type
  if (data.labTestResults.length > 0) {
    ltr = _.last(_.where(data.labTestResults, {abbrev: 'Blood type'}));
    if (ltr) {
      tmpStr = ltr.result;
      centerInCol(doc, tmpStr, colPos[15], colPos[16], textY);
    }
  }


  // HBSAG
  if (data.labTestResults.length > 0) {
    ltr = _.last(_.where(data.labTestResults, {abbrev: 'HBsAg'}));
    if (ltr) {
      tmpStr = '';
      if (ltr.result === '-') tmpStr = 'non-reactive';
      if (ltr.result === '+') tmpStr = 'reactive';
      centerInCol(doc, tmpStr, colPos[16], colPos[17], textY);
    }
  }

  // Hct
  if (data.labTestResults.length > 0) {
    ltr = _.last(_.where(data.labTestResults, {abbrev: 'Hct'}));
    if (ltr) {
      // --------------------------------------------------------
      // Actually Hct is in range 0 - .6 but it is commonly notated
      // as 0 - 60. In our database it is the later but this report
      // requires the more accurate version, so we divide by 100.
      // --------------------------------------------------------
      tmpStr = parseInt(ltr.result, 10)/100;
      centerInCol(doc, tmpStr, colPos[17], colPos[18], textY);
    }
  }

  // Hgb
  if (data.labTestResults.length > 0) {
    ltr = _.last(_.where(data.labTestResults, {abbrev: 'Hgb'}));
    if (ltr) {
      tmpStr = ltr.result;
      centerInCol(doc, tmpStr, colPos[18], colPos[19], textY);
    }
  }

  // TT - note that this is exactly the same as the date field.
  tmpStr = moment(data.vacDate).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[19], colPos[20], textY);
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
    , totalVaccinations = data.length
    , totalPages = Math.ceil(data.length / rowsPerPage)
    ;

  // --------------------------------------------------------
  // Do each row, adding pages as necessary. If there is no
  // data, still create a page with no data.
  // --------------------------------------------------------
  doSiteTitle(doc, 24);
  doReportName(doc, opts.title, 48);
  doFromTo(doc, opts.fromDate, opts.toDate);
  doColumnHeader(doc, opts);
  doFooter(doc, pageNum, totalPages, totalVaccinations, opts);
  _.each(data, function(rec) {
    doRow(doc, rec, opts, currentRow, 14);
    currentRow++;
    if (currentRow >= rowsPerPage) {
      doc.addPage();
      currentRow = 0;
      pageNum++;
      doSiteTitle(doc, 24);
      doReportName(doc, opts.title, 48);
      doFromTo(doc, opts.fromDate, opts.toDate);
      doColumnHeader(doc, opts);
      doFooter(doc, pageNum, totalPages, totalVaccinations, opts);
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
  var reportNum = parseInt(flds.report.slice(-1), 10) // hack: vaccine1 or vaccine2
    , options = {
        margins: {
          top: 18
          , right: 18
          , left: 18
          , bottom: 18
        }
        , layout: 'landscape'
        , size: 'letter'
        , info: {
            Title: 'TT' + reportNum + ' Report'
            , Author: 'Midwife-EMR Application'
            , Subject: 'Vaccination Given Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 31    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = flds.dateFrom;
  opts.toDate = flds.dateTo;
  opts.logisticsName = logisticsName;
  opts.title = options.info.Title;
  opts.margins = options.margins;
  opts.reportNum = reportNum;

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
        , fDate = moment(opts.fromDate, 'YYYY-MM-DD')
        , tDate = moment(opts.toDate, 'YYYY-MM-DD')
        ;

      // --------------------------------------------------------
      // Break out the vaccinations into order by pregnancy.
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
          recDate = moment(rec.vacDate);
          if ((recDate.isSame(fDate, 'day') || (recDate.isAfter(fDate, 'day'))) &&
              ((recDate.isSame(tDate, 'day')) || (recDate.isBefore(tDate, 'day')))) {
            data.push(rec);
          } else {
          }
        } else {
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
 * Run the vaccination report.
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
    console.log('Vaccination report: not all fields supplied.');
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
  res.setHeader('Content-Disposition', 'inline; VaccinationRpt.pdf');

  // --------------------------------------------------------
  // Get the displayName for the logistics in charge.
  // --------------------------------------------------------
  User.findDisplayNameById(Number(flds.inCharge), function(err, name) {
    if (err) throw err;
    // If the user has not set their displayName, don't die.
    if (! name) name = '';
    doReport(flds, writable, name);
  });
};


module.exports = {
  run: run
};



