/*
 * -------------------------------------------------------------------------------
 * dohMasterListRpt.js
 *
 * Required report for the Department of Health Master List.
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
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , Medication = require('../models').Medication
  , Medications = require('../models').Medications
  , MedicationType = require('../models').MedicationType
  , MedicationTypes = require('../models').MedicationTypes
  , Risk = require('../models').Risk
  , Risks = require('../models').Risks
  , RiskCode = require('../models').RiskCode
  , RiskCodes = require('../models').RiskCodes
  , PrenatalExam = require('../models').PrenatalExam
  , PrenatalExams = require('../models').PrenatalExams
  , Vaccination = require('../models').Vaccination
  , Vaccinations = require('../models').Vaccinations
  , LabTestResult = require('../models').LabTestResult
  , LabTestResults = require('../models').LabTestResults
  , CustomField = require('../models').CustomField
  , CustomFields = require('../models').CustomFields
  , CustomFieldType = require('../models').CustomFieldType
  , CustomFieldTypes = require('../models').CustomFieldTypes
  , User = require('../models').User
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
  var data
    , pregIds
    ;
  return new Promise(function(resolve, reject) {
    // --------------------------------------------------------
    // Get the list of clients that are being reported on
    // which consists of the clients that came for prenatal
    // exams during the dates specified.
    // --------------------------------------------------------
    new PrenatalExams().query()
      .select(['pregnancy_id'])
      .where('date', '>=', dateFrom)
      .andWhere('date', '<=', dateTo)
      .then(function(list) {
        pregIds = _.pluck(list, 'pregnancy_id');

        // --------------------------------------------------------
        // Get the relevant information from the pregnancy and
        // patient tables.
        // --------------------------------------------------------
        return new Pregnancies().query()
          .column('pregnancy.id', 'pregnancy.firstname','pregnancy.lastname',
           'pregnancy.address', 'pregnancy.barangay', 'pregnancy.city',
           'pregnancy.gravida', 'pregnancy.para', 'pregnancy.abortions',
           'pregnancy.stillBirths', 'pregnancy.edd', 'pregnancy.alternateEdd',
           'pregnancy.useAlternateEdd', 'pregnancy.doctorConsultDate',
           'pregnancy.dentistConsultDate', 'pregnancy.mbBook', 'pregnancy.lmp',
           'pregnancy.whereDeliver', 'pregnancy.birthCompanion',
           'pregnancy.philHealthMCP', 'pregnancy.philHealthNCP',
           'pregnancy.useIodizedSalt', 'patient.dohID', 'patient.dob',
           'patient.generalInfo', 'patient.ageOfMenarche')
          .innerJoin('patient', 'patient.id', 'pregnancy.patient_id')
          .whereIn('pregnancy.id', pregIds)
          .select();
      })
      .then(function(pregs) {
        data = pregs;
        // --------------------------------------------------------
        // Add all of the placeholders for the data obtained below.
        // --------------------------------------------------------
        _.each(data, function(rec) {
          rec.risks = [];
          rec.prenatalExams = [];
          rec.vaccinations = [];
          rec.labTests = [];
          rec.medications = [];
          rec.customFields = [];
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the date of registration which we derive by finding
        // the date that the first pregnancy record was updated.
        //
        // Note: set the order of the final data here due to the
        // merge of data in the next step.
        // --------------------------------------------------------
        var knex = Bookshelf.DB.knex
          , sql
          ;
        sql = 'SELECT id, MIN(updatedAt) AS registeredDate FROM pregnancyLog ';
        sql += 'WHERE id IN (' + pregIds.join(',') + ') GROUP BY id ';
        sql += 'ORDER BY lastname asc, firstname asc';
        return knex.raw(sql);
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Merge the registration dates into the pregnancy records.
        // --------------------------------------------------------
        var data2 = [];
        _.each(list[0], function(rec) {
          data2.push(_.extend(_.findWhere(data, {id: rec.id}),
              {registeredDate: rec.registeredDate}));
        })
        data = data2;
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the risk codes.
        // --------------------------------------------------------
        return new Risks().query()
          .column('risk.pregnancy_id', 'risk.updatedAt AS riskUpdatedAt',
            'riskCode.name AS riskName')
          .innerJoin('riskCode', 'risk.riskCode', 'riskCode.id')
          .whereIn('risk.pregnancy_id', pregIds)
          .select();
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Add the risks found to the records to be returned.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var d = _.findWhere(data, {id: rec.pregnancy_id});
          d.risks.push(_.omit(rec, ['pregnancy_id']));
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the prenatalExams.
        // --------------------------------------------------------
        return new PrenatalExams().query()
          .column('prenatalExam.pregnancy_id', 'prenatalExam.date AS prenatalExamDate')
          .whereIn('prenatalExam.pregnancy_id', pregIds)
          .orderBy('prenatalExam.date')
          .select();
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Add the prenatal exam dates to the records to be returned.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var d = _.findWhere(data, {id: rec.pregnancy_id});
          d.prenatalExams.push(_.omit(rec, ['pregnancy_id']));
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the vaccination data.
        // --------------------------------------------------------
        return new Vaccinations().query()
          .column('vaccination.pregnancy_id', 'vaccination.vacDate',
            'vaccination.vacMonth', 'vaccination.vacYear',
            'vaccination.administeredInternally', 'vaccinationType.name')
          .innerJoin('vaccinationType', 'vaccination.vaccinationType',
            'vaccinationType.id')
          .whereIn('vaccination.pregnancy_id', pregIds)
          .andWhere('vaccinationType.name', 'LIKE', '%Tetanus%')
          .select();
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Add the vaccinations to the records to be returned.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var d = _.findWhere(data, {id: rec.pregnancy_id});
          d.vaccinations.push(_.omit(rec, ['pregnancy_id']));
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the laboratory results.
        // --------------------------------------------------------
        return new LabTestResults().query()
          .column('labTestResult.testDate', 'labTestResult.result',
            'labTestResult.result2', 'labTestResult.pregnancy_id', 'labTest.name')
          .innerJoin('labTest', 'labTest.id', 'labTestResult.labTest_id')
          .whereIn('labTestResult.pregnancy_id', pregIds)
          .whereIn('labTest.name',
            ['Hemoglobin', 'Blood Type', 'Red Blood Cells', 'White Blood Cells'])
          .select();
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Add the labs to the records to be returned.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var d = _.findWhere(data, {id: rec.pregnancy_id});
          d.labTests.push(_.omit(rec, ['pregnancy_id']));
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the medication data.
        // --------------------------------------------------------
        return new Medications().query()
          .column('medication.pregnancy_id', 'medication.date',
            'medication.numberDispensed', 'medicationType.name')
          .innerJoin('medicationType', 'medication.medicationType',
            'medicationType.id')
          .whereIn('medication.pregnancy_id', pregIds)
          .select();
      })
      .then(function(list) {
        // --------------------------------------------------------
        // Add the medications to the records to be returned.
        // --------------------------------------------------------
        _.each(list, function(rec) {
          var d = _.findWhere(data, {id: rec.pregnancy_id});
          d.medications.push(_.omit(rec, ['pregnancy_id']));
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
          var d = _.findWhere(data, {id: rec.pregnancy_id});
          d.customFields.push(_.omit(rec, ['pregnancy_id']));
        });
      })
      .then(function() {
        // --------------------------------------------------------
        // Return the data to the caller.
        // --------------------------------------------------------

        return resolve(data);
      });
  });
};

/* --------------------------------------------------------
 * replaceNull()
 *
 * Return a new dictionary with the same keys as the passed
 * dictionary but with the keys within the list of keys
 * passed that evaluate to null being set to the passed
 * replacement value instead.
 *
 * param      hash - the dictionary
 * param      keys - a list of key names
 * param      replacement - what nulls will be replaced with
 * return     new hash
 * -------------------------------------------------------- */
var replaceNull = function(hash, keys, replacement) {
  var dict = _.clone(hash);
  _.each(keys, function(key) {
    if (_.isNull(hash[key])) {
      dict[key] = replacement;
    } else {
      dict[key] = hash[key];
    }
  });
  return dict;
};


/* --------------------------------------------------------
 * centerInCol()
 *
 * Centers the specified text within the column boundaries
 * passed. Assumes that font and fontSize have already
 * been appropriately applied to the doc object.
 *
 * param      doc
 * param      str
 * param      colLeft
 * param      colRight
 * param      y
 * return     undefined
 * -------------------------------------------------------- */
var centerInCol = function(doc, str, colLeft, colRight, y) {
  var center = ((colRight - colLeft)/2) + colLeft
    , tmpStr = '' + str      // convert to a string
    , strWidth = doc.widthOfString(tmpStr)
    ;
  doc.text(tmpStr, center - (strWidth/2), y);
};


/* --------------------------------------------------------
 * doRowPage1()
 *
 * Writes a row of data to the report (the lines already exist).
 *
 * param      doc
 * param      data
 * param      rec
 * param      rowNum
 * return     undefined
 * -------------------------------------------------------- */
var doRowPage1 = function(doc, opts, rec, rowNum) {
  var rowHeight = 45
    , startX = doc.page.margins.left
    , startY = opts.margins.top + 108 + ((rowNum - 1) * rowHeight)
    , colPos = getColXposPage1(opts)
    , largeFont = 13
    , smallFont = 9
    , smallLineHgt = 12
    , colPadLeft = 6
    , colPadTop = 12
    , tmpX
    , tmpY
    , tmpWidth
    , tmpHeight
    , tmpStr
    , lmp
    , tri1 = []
    , tri2 = []
    , tri3 = []
    ;

  // --------------------------------------------------------
  // Replace nulls with sensible defaults for certain fields.
  // --------------------------------------------------------
  rec = replaceNull(rec, ['gravida', 'para', 'abortions', 'stillBirths'], ' ');
  rec = replaceNull(rec, ['doctorConsultDate', 'dentistConsultDate'], '');

  // --------------------------------------------------------
  // Date of Registration
  // --------------------------------------------------------
  tmpStr = moment(rec.registeredDate).format('MM/DD/YYYY');
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[0], colPos[1], startY + colPadTop);

  // --------------------------------------------------------
  // Name
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(largeFont)
    .text(rec.lastname, colPos[1] + colPadLeft, startY + colPadTop);
  tmpX = colPos[1] + (colPos[2] - colPos[1]) / 2;
  doc.text(rec.firstname, tmpX, startY + colPadTop);

  // --------------------------------------------------------
  // "Highlight" the address cell if the client resides in Agdao
  // per the custom fields. This really is not a PDFKit
  // hightlight - we draw a yellow filled rectangle in the cell
  // but it has the effect that we want.
  // --------------------------------------------------------
  if (rec.customFields && rec.customFields.length > 0 &&
      _.findWhere(rec.customFields, {name: 'Agdao'})) {
    tmpX = colPos[2] + colPadLeft - 1;
    tmpY = startY + colPadTop - 3;
    tmpWidth = colPos[3] - colPos[2] - (2 * colPadLeft) + 2;
    tmpHeight = rowHeight - colPadTop + 2;
    doc
      .rect(tmpX, tmpY, tmpWidth, tmpHeight)
      .fill('yellow');
    doc.fillColor('black');     // Set back to black.
  }
  // --------------------------------------------------------
  // Address
  // --------------------------------------------------------
  tmpWidth = colPos[3] - colPos[2] - colPadLeft;
  tmpHeight = rowHeight - colPadTop;
  tmpStr = rec.address + ', ' + rec.city + '  ' + rec.barangay;
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont)
    .text(tmpStr, colPos[2] + colPadLeft, startY + colPadTop,
        {width: tmpWidth, height: tmpHeight});

  // --------------------------------------------------------
  // Age and DOB
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpStr = moment().diff(moment(rec.dob), 'years');
  centerInCol(doc, tmpStr, colPos[3], colPos[4], startY + colPadTop);
  tmpStr = moment(rec.dob).format('MM/DD/YYYY');
  centerInCol(doc, tmpStr, colPos[3], colPos[4],
      startY + colPadTop + smallLineHgt);

  // --------------------------------------------------------
  // LMP and GPAS
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpStr = rec.lmp && rec.lmp !== '0000-00-00'? moment(rec.lmp).format('MM/DD/YYYY'): '';
  centerInCol(doc, tmpStr, colPos[4], colPos[5], startY + colPadTop);
  tmpStr = rec.gravida + '-' + rec.para + '-' + rec.abortions + '-' + rec.stillBirths;
  centerInCol(doc, tmpStr, colPos[4], colPos[5], startY + (rowHeight / 2));

  // --------------------------------------------------------
  // EDC
  // --------------------------------------------------------
  if (rec.useAlternateEdd && rec.alternateEdd) {
    tmpStr = moment(rec.alternateEdd).format('MM/DD/YYYY');
  } else {
    if (rec.edd) {
      tmpStr = moment(rec.edd).format('MM/DD/YYYY');
    } else {
      tmpStr = '';
    }
  }
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[5], colPos[6], startY + colPadTop);

  // --------------------------------------------------------
  // Prenatal Visits by trimester.
  // --------------------------------------------------------
  if (rec.lmp && rec.lmp !== '0000-00-00') {
    lmp = moment(rec.lmp);

    // --------------------------------------------------------
    // Split out the prenatal exam dates by trimester.
    // --------------------------------------------------------
    _.each(rec.prenatalExams, function(exam) {
      var diffWeeks = moment(exam.prenatalExamDate).diff(lmp, 'weeks');
      if (diffWeeks < 12) {
        tri1.push(moment(exam.prenatalExamDate).format('MM/DD/YYYY'));
      }
      if (diffWeeks >= 12 && diffWeeks < 27) {
        tri2.push(moment(exam.prenatalExamDate).format('MM/DD/YYYY'));
      }
      if (diffWeeks >= 27) {
        tri3.push(moment(exam.prenatalExamDate).format('MM/DD/YYYY'));
      }
    });

    // 1st Trimester.
    doc
      .font(FONTS.Helvetica)
      .fontSize(smallFont);
    tmpY = startY + 6;
    _.each(tri1, function(dte) {
      centerInCol(doc, dte, colPos[6], colPos[7], tmpY);
      tmpY += 8;
    });

    // 2nd Trimester.
    doc
      .font(FONTS.Helvetica)
      .fontSize(smallFont);
    tmpY = startY + 6;
    _.each(tri2, function(dte) {
      centerInCol(doc, dte, colPos[7], colPos[8], tmpY);
      tmpY += 8;
    });

    // 3rd Trimester.
    doc
      .font(FONTS.Helvetica)
      .fontSize(smallFont);
    tmpY = startY + 6;
    _.each(tri3, function(dte) {
      centerInCol(doc, dte, colPos[8], colPos[9], tmpY);
      tmpY += 8;
    });
  }

  // --------------------------------------------------------
  // Risk Codes.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpY = startY + 6;
  _.each(rec.risks, function(risk) {
    var at = moment(risk.riskUpdatedAt).format('MM/DD/YYYY')
      , name = risk.riskName.length === 1 ? '  ' + risk.riskName: risk.riskName
      , str = name + ': ' + at
      ;
    centerInCol(doc, str, colPos[9], colPos[10], tmpY);
    tmpY += 8;
  });

  // --------------------------------------------------------
  // Seen by doctor.
  // --------------------------------------------------------
  tmpStr = rec.doctorConsultDate && rec.doctorConsultDate !== '0000-00-00' ?
    moment(rec.doctorConsultDate).format('MM/DD/YYYY'): '';
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[10], colPos[11], startY + colPadTop);

  // --------------------------------------------------------
  // Seen by dentist.
  // --------------------------------------------------------
  tmpStr = rec.dentistConsultDate && rec.dentistConsultDate !== '0000-00-00' ?
    moment(rec.dentistConsultDate).format('MM/DD/YYYY'): '';
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  centerInCol(doc, tmpStr, colPos[11], colPos[12], startY + colPadTop);
};


/* --------------------------------------------------------
 * doRowPage2()
 *
 * Writes out the data for a row on page 2.
 *
 * param      doc
 * param      data
 * param      rec
 * param      rowNum
 * return     undefined
 * -------------------------------------------------------- */
var doRowPage2 = function(doc, opts, rec, rowNum) {
  var rowHeight = 45
    , startX = doc.page.margins.left
    , startY = opts.margins.top + 108 + ((rowNum - 1) * rowHeight)
    , colPos = getColXposPage2(opts)
    , largeFont = 13
    , smallFont = 9
    , smallLineHgt = 12
    , colPadLeft = 6
    , colPadTop = 12
    , tmpX
    , tmpWidth
    , tmpHeight
    , tmpStr
    , tmpList = []
    , cntPrevTT
    , cntTri1 = 0
    , cntTri2 = 0
    , cntTri3 = 0
    , cntIron = 0
    , cntHemo = 0
    , cntBT = 0
    , cntUri = 0
    , tmpRec
    ;

  // --------------------------------------------------------
  // Mother and child book.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(largeFont);
  tmpStr = '';
  if (rec.mbBook === 1) tmpStr = 'Yes';
  if (rec.mbBook === 0) tmpStr = 'No';
  centerInCol(doc, tmpStr, colPos[0], colPos[1], startY + colPadTop);

  // --------------------------------------------------------
  // Where is delivery.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpStr = rec.whereDeliver.slice(0, 10);
  centerInCol(doc, tmpStr, colPos[1], colPos[2], startY + colPadTop);

  // --------------------------------------------------------
  // Partner during delivery.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpStr = rec.birthCompanion.slice(0, 10);
  centerInCol(doc, tmpStr, colPos[2], colPos[3], startY + colPadTop);

  // --------------------------------------------------------
  // Phil Health member.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpStr = rec.philHealthMCP || rec.philHealthNCP ? 'Yes': 'No';
  centerInCol(doc, tmpStr, colPos[3], colPos[4], startY + colPadTop);

  // --------------------------------------------------------
  // Previous Tetanus.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpY = startY + 6;
  // Pull out the externally administered vaccinations.
  tmpList = [];
  _.each(rec.vaccinations, function(vac) {
    if (vac.administeredInternally === 0) {
      tmpList.push(vac);
    }
  });
  cntPrevTT = tmpList.length;
  if (tmpList.length > 0) {
    // Sort tmpList in place.
    tmpList.sort(function(a, b) {
      function convertToMoment(obj) {
        if (obj.vacDate && moment(obj.vacDate).isValid()) {
          return moment(obj.vacDate);
        } else if (obj.vacYear) {
          if (obj.vacMonth) {
            return moment({year: obj.vacYear, month: obj.vacMonth});
          } else {
            return moment({year: obj.vacYear});
          }
        }
        return void 0;
      }
      var ma = convertToMoment(a)
        , mb = convertToMoment(b)
        ;
      if (! ma) return 1;
      if (! mb) return -1;
      return ma.unix() - mb.unix();
    });

    // Write to the column.
    tmpY = startY + 6;
    _.each(tmpList, function(vac) {
      var str
        ;
      if (vac.vacDate) {
        str = moment(vac.vacDate).format('MM/DD/YY');
      } else if (vac.vacYear) {
        str = vac.vacYear;
        if (vac.vacMonth) str = vac.vacMonth + '-' + str;
      }
      centerInCol(doc, str, colPos[4], colPos[5], tmpY);
      tmpY += 8;
    });
  }

  // --------------------------------------------------------
  // Tetanus immunizations given.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpY = startY + 6;
  // Pull out the internally administered vaccinations.
  tmpList = [];
  _.each(rec.vaccinations, function(vac) {
    if (vac.administeredInternally === 1) {
      tmpList.push(vac);
    }
  });
  if (tmpList.length > 0) {
    // Sort tmpList in place.
    tmpList.sort(function(a, b) {
      function convertToMoment(obj) {
        if (obj.vacDate && moment(obj.vacDate).isValid()) {
          return moment(obj.vacDate);
        } else if (obj.vacYear) {
          if (obj.vacMonth) {
            return moment({year: obj.vacYear, month: obj.vacMonth});
          } else {
            return moment({year: obj.vacYear});
          }
        }
        return void 0;
      }
      var ma = convertToMoment(a)
        , mb = convertToMoment(b)
        ;
      if (! ma) return 1;
      if (! mb) return -1;
      return ma.unix() - mb.unix();
    });

    // If for some strange reason there are more than 5 Tetanus shots
    // given, only report on the first 5 because that is all the space
    // on the report that there is.
    if (tmpList.length > 5) tmpList.splice(5);

    // Write to the column but move down according to the
    // number of prior Tetanus shots given externally.
    tmpY = startY + 6 + (cntPrevTT * 8);
    _.each(tmpList, function(vac) {
      var str
        ;
      if (vac.vacDate) {
        str = moment(vac.vacDate).format('MM/DD/YY');
      } else if (vac.vacYear) {
        str = vac.vacYear;
        if (vac.vacMonth) str = vac.vacMonth + '-' + str;
      }
      centerInCol(doc, str, colPos[5], colPos[6], tmpY);
      tmpY += 8;
    });
  }

  // --------------------------------------------------------
  // Hemoglobin 1st and 2nd dates.
  // --------------------------------------------------------
  tmpList = _.filter(rec.labTests, function(lt) {
    return lt.name.toLowerCase() === 'hemoglobin';
  });
  if (tmpList.length > 0) {
    tmpList = _.sortBy(tmpList, 'testDate');
    tmpStr = moment(tmpList[0].testDate).format('MM/DD/YY');
    tmpY = startY + colPadTop;
    centerInCol(doc, tmpStr, colPos[6], colPos[7], tmpY);
    tmpStr = '' + tmpList[0].result;
    tmpY += 20;
    centerInCol(doc, tmpStr, colPos[6], colPos[7], tmpY);

    if (tmpList.length > 1) {
      tmpStr = moment(tmpList[1].testDate).format('MM/DD/YY');
      tmpY = startY + colPadTop;
      centerInCol(doc, tmpStr, colPos[7], colPos[8], tmpY);
      tmpStr = '' + tmpList[1].result;
      tmpY += 20;
      centerInCol(doc, tmpStr, colPos[7], colPos[8], tmpY);
    }
  }

  // --------------------------------------------------------
  // Blood type.
  // --------------------------------------------------------
  tmpList = _.filter(rec.labTests, function(lt) {
    return lt.name.toLowerCase() === 'blood type';
  });
  if (tmpList.length > 0) {
    tmpList = _.sortBy(tmpList, 'testDate');
    tmpStr = moment(tmpList[0].testDate).format('MM/DD/YY');
    tmpY = startY + colPadTop;
    centerInCol(doc, tmpStr, colPos[8], colPos[9], tmpY);
    tmpStr = '' + tmpList[0].result;
    tmpY += 20;
    centerInCol(doc, tmpStr, colPos[8], colPos[9], tmpY);
  }

  // --------------------------------------------------------
  // Urinalysis.
  // --------------------------------------------------------
  // wbc
  tmpList = _.filter(rec.labTests, function(lt) {
    return lt.name.toLowerCase() === 'white blood cells';
  });
  if (tmpList.length > 0) {
    tmpList = _.sortBy(tmpList, 'testDate');
    tmpRec = tmpList[tmpList.length - 1];   // Use most recent result.
    tmpStr = moment(tmpRec.testDate).format('MM/DD/YY');
    tmpY = startY + colPadTop;
    centerInCol(doc, tmpStr, colPos[9], colPos[10], tmpY);
    tmpStr = tmpRec.result;
    if (tmpRec.result2) tmpStr += ' - ' + tmpRec.result2;
    tmpY += 8;
    centerInCol(doc, tmpStr, colPos[9], colPos[10], tmpY);
  }
  // rbc
  tmpList = _.filter(rec.labTests, function(lt) {
    return lt.name.toLowerCase() === 'red blood cells';
  });
  if (tmpList.length > 0) {
    tmpList = _.sortBy(tmpList, 'testDate');
    tmpRec = tmpList[tmpList.length - 1];   // Use most recent result.
    tmpStr = moment(tmpRec.testDate).format('MM/DD/YY');
    tmpY = startY + colPadTop + 20;
    centerInCol(doc, tmpStr, colPos[9], colPos[10], tmpY);
    tmpStr = tmpRec.result;
    if (tmpRec.result2) tmpStr += ' - ' + tmpRec.result2;
    tmpY += 8;
    centerInCol(doc, tmpStr, colPos[9], colPos[10], tmpY);
  }


  // --------------------------------------------------------
  // RTI / STI.
  // --------------------------------------------------------
  // TODO: do this field.

  // --------------------------------------------------------
  // Iron with folic in three columns.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpList = _.filter(rec.medications, function(med) {
    return med.name.toLowerCase().indexOf('ferrous') !== -1;
  });
  tmpList = _.sortBy(tmpList, 'date');
  if (tmpList.length > 0) {
    // 1st Column.
    tmpStr = '' + tmpList[0].numberDispensed;
    tmpY = startY + colPadTop + 4;
    centerInCol(doc, tmpStr, colPos[11], colPos[12], tmpY);
    tmpY += 12;
    tmpStr = moment(tmpList[0].date).format('MM-DD-YY');
    centerInCol(doc, tmpStr, colPos[11], colPos[12], tmpY);

    // 2nd Column.
    if (tmpList.length > 1) {
      tmpStr = '' + tmpList[1].numberDispensed;
      tmpY = startY + colPadTop + 4;
      centerInCol(doc, tmpStr, colPos[12], colPos[13], tmpY);
      tmpY += 12;
      tmpStr = moment(tmpList[1].date).format('MM-DD-YY');
      centerInCol(doc, tmpStr, colPos[12], colPos[13], tmpY);

      // 3rd Column.
      if (tmpList.length > 2) {
        tmpStr = '' + tmpList[2].numberDispensed;
        tmpY = startY + colPadTop + 4;
        centerInCol(doc, tmpStr, colPos[13], colPos[14], tmpY);
        tmpY += 12;
        tmpStr = moment(tmpList[2].date).format('MM-DD-YY');
        centerInCol(doc, tmpStr, colPos[13], colPos[14], tmpY);
      }
    }
  }

  // --------------------------------------------------------
  // Use Iodized Salt.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  if (rec.useIodizedSalt === 'Y') tmpStr = 'Yes';
  if (rec.useIodizedSalt === 'N') tmpStr = 'No';
  if (! rec.useIodizedSalt) tmpStr = '';
  tmpY = startY + colPadTop;
  centerInCol(doc, tmpStr, colPos[14], colPos[15], tmpY);

  // --------------------------------------------------------
  // Quality Prenatal Care.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(largeFont);
  tmpStr = '';
  if (rec.doctorConsultDate && moment(rec.doctorConsultDate).isValid() &&
      rec.dentistConsultDate && moment(rec.dentistConsultDate).isValid()) {

    // Determine if the proper number and timing of prenatal exams occurred.
    _.each(rec.prenatalExams, function(exam) {
      var diffWeeks = moment(exam.prenatalExamDate).diff(moment(rec.lmp), 'weeks');
      if (diffWeeks < 12) {
        cntTri1++;
      }
      if (diffWeeks >= 12 && diffWeeks < 27) {
        cntTri2++;
      }
      if (diffWeeks >= 27) {
        cntTri3++;
      }
    });

    // Determine if the proper amount of iron suppliments were given.
    tmpList = _.filter(rec.medications, function(med) {
      return med.name.toLowerCase().indexOf('ferrous') !== -1;
    });
    tmpList = _.pluck(tmpList, 'numberDispensed');
    cntIron = _.reduce(tmpList, function(memo, val) {return memo + val;});

    // Determine if the proper labs were done.
    cntHemo = _.filter(rec.labTests, function(lt) {
      return lt.name.toLowerCase() === 'hemoglobin';
    }).length;
    cntBT = _.filter(rec.labTests, function(lt) {
      return lt.name.toLowerCase() === 'blood type';
    }).length;
    cntUri = _.filter(rec.labTests, function(lt) {
      return lt.name.toLowerCase() === 'red blood cells' ||
        lt.name.toLowerCase() === 'white blood cells';
    }).length;


    if (cntTri1 >= 1 && cntTri2 >= 1 && cntTri3 >= 2 && cntHemo > 0 &&
        cntBT > 0 && cntUri > 0 && cntIron >= 180 && rec.mbBook === 1) {
      tmpStr = 'Yes';
      tmpY = startY + colPadTop;
      centerInCol(doc, tmpStr, colPos[15], colPos[16], tmpY);
    }
  }

  // --------------------------------------------------------
  // Remarks: pull whether deworming was given.
  // Note: remarks are limited in lines, just 2 deworming
  // records are used.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmpList = _.filter(rec.medications, function(med) {
    return med.name.toLowerCase().indexOf('mebendazole') !== -1 ||
      med.name.toLowerCase().indexOf('albendazole') !== -1;
  });
  if (tmpList.length > 2) tmpList = tmpList.slice(0, 2);  // Limit what is printed.
  tmpY = startY + colPadTop - 4;
  _.each(tmpList, function(med) {
    var str1 = moment(med.date).format('MM/DD/YY') + ': ' + med.numberDispensed +
        ' tablet(s)'
      , str2 = med.name
      ;
    doc.text(str1, colPos[16] + colPadLeft, tmpY);
    tmpY += 10;
    doc.text(str2, colPos[16] + colPadLeft, tmpY);
    tmpY += 12;
  });

};


/* --------------------------------------------------------
 * doHeaderPage1()
 *
 * Write out the header on page 1.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doHeaderPage1 = function(doc, opts) {
  var len
    , y = opts.margins.top
    ;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(22);
  len = doc.widthOfString(opts.title) + 10;
  doc.text(opts.title, doc.page.width - opts.margins.right - len, y);
};



/* --------------------------------------------------------
 * doFooterPage1()
 *
 * Write out the footer on page 1.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFooterPage1 = function(doc, opts) {
  var x = opts.margins.left
    , y = doc.page.height - opts.margins.bottom - 95
    , headingFontSize = 12
    , textFontSize = 8
    , lineHgt = 10
    , yTop = y
    , tmpX
    ;

  // --------------------------------------------------------
  // Column 1
  // --------------------------------------------------------
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(headingFontSize)
    .text('1/ Risk Codes:', x, y, {underline: true});
  y += 20;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(textFontSize)
    .text('A = ', x, y);
  tmpX = x + doc.widthOfString('A = ');
  doc.text('(1) Too old (>35 years old)', tmpX, y); y += lineHgt;
  doc.text('(2) Too young (<18 years old)', tmpX, y); y += lineHgt;
  doc.text('B = (1) Height less than 145 cm (4\'9") tall', x, y); y += lineHgt;
  doc.text('(2) Less than ideal weight', tmpX, y); y += lineHgt;
  doc.text('(3) More than ideal weight', tmpX, y); y += lineHgt;
  doc.text('C = Too many (4 or more children)', x, y); y += lineHgt;

  // --------------------------------------------------------
  // Column 2
  // --------------------------------------------------------
  x += 210;
  y = yTop;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(textFontSize)
    .text('D = Poor obsterical history', x, y); y += lineHgt;
  doc.text('(1) previous delivery/ies by ceasarian section', x, y); y += lineHgt;
  doc.text('(2) previous baby born dead or died during the 7 days of life', x, y); y += lineHgt;
  doc.text('(3) prior pregnancy/ies with spotting/bleeding', x, y); y += lineHgt;
  doc.text('(4) prior delivery/ies with heavy bleeding', x, y); y += lineHgt;
  doc.text('(5) prior pregnancy/ies or delivery/ies with convulsions', x, y); y += lineHgt;
  doc.text('(6) prior delivery/ies by forceps or vacuum', x, y); y += lineHgt;
  doc.text('(7) prior pregnancy/ies transverse lie or malpresentation', x, y); y += lineHgt;

  // --------------------------------------------------------
  // Column 3
  // --------------------------------------------------------
  x += 290;
  y = yTop;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(textFontSize)
    .text('E = Poor medical history', x, y); y += lineHgt;
  doc.text('(1) Tuberculosis', x, y); y += lineHgt;
  doc.text('(2) Heart disease', x, y); y += lineHgt;
  doc.text('(3) Diabetes', x, y); y += lineHgt;
  doc.text('(4) Bronchial Asthma', x, y); y += lineHgt;
  doc.text('(5) Goiter', x, y); y += lineHgt;
  doc.text('(6) Hypertensive', x, y); y += lineHgt;
  doc.text('(7) Malaria', x, y); y += lineHgt;
  doc.text('(8) Parasitism, schisto, hetero, etc.', x, y); y += lineHgt;

  // --------------------------------------------------------
  // Column 4
  // --------------------------------------------------------
  x += 190;
  y = yTop;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(textFontSize)
    .text('F = Too close (<3 years birth spacing)', x, y); y += lineHgt;
  doc.text('G = Risky Lifestyle', x, y); y += lineHgt;
  doc.text('(1) Smoking', x, y); y += lineHgt;
  doc.text('(2) Drink alcohol', x, y); y += lineHgt;
  doc.text('(3) Multiple partners', x, y); y += lineHgt;
  doc.text('(4) Living with persons having AIDS/HIV', x, y); y += lineHgt;
  doc.text('(5) Exposure to communicable diseases/areas', x, y); y += lineHgt;
  tmpX = x + doc.widthOfString('(5) ');
  doc.text('(ex. malaria, TB, Schistosomiasis, etc.)', tmpX, y); y += lineHgt;
  doc.text('(6) VAW victim', x, y); y += lineHgt;
};


/* --------------------------------------------------------
 * doFooterPage2()
 *
 * Write out the footer on page 2.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFooterPage2 = function(doc, opts) {
  var x = opts.margins.left
    , y = doc.page.height - opts.margins.bottom - 95
    , headingFontSize = 12
    , textFontSize = 8
    , lineHgt = 10
    , yTop = y
    , tmpX
    , tmpX2
    , tmpStr
    , tmpStr2
    ;

  // --------------------------------------------------------
  // Column 1
  // --------------------------------------------------------
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(headingFontSize)
    .text('2/ Birth Plan:', x, y, {underline: true});
  y += 20;
  doc
    .font(FONTS.Helvetica)
    .fontSize(textFontSize)
    .text('11 A = Y / N', x, y);
  y += lineHgt; doc.text('11 B = Home, Hospital, Clinic', x, y);
  y += lineHgt; doc.text('11 C = Husband, hilot, MW, PHN', x, y);
  y += lineHgt; doc.text('11 D = Y / N', x, y);
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(textFontSize);
  y += lineHgt; doc.text('3/ 1st Hemoglobin', x, y);
  y += lineHgt; doc.text('4/ 2nd Hemoglobin', x, y);

  // --------------------------------------------------------
  // Column 2
  // --------------------------------------------------------
  x += 234;
  y = yTop;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(textFontSize);
  tmpStr = '5/ ';
  tmpStr2 = 'Reproductive Tract infection (RTI)/ Sexually Transmitted Infection (STI) - ';
  tmpX = x + doc.widthOfString(tmpStr);
  tmpX2 = tmpX + doc.widthOfString(tmpStr2);
  doc.text(tmpStr + tmpStr2, x, y);
  doc.font(FONTS.Helvetica);
  doc.text('Syphillix, HIV, Gram Stain, KOH mount, Wet mount', tmpX2, y);
  y += lineHgt; doc.text('& PaP Smear. If positive, list the pregnant woman in the TCL for STD/HIV/AIDS.', tmpX, y);
  y += (lineHgt * 1.5);
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(textFontSize);
  tmpStr = '6/ ';
  tmpStr2 = 'Iron Supplementation / Multiple Micronutrient Supplementation/ Multivitamis = ';
  tmpX = x + doc.widthOfString(tmpStr);
  tmpX2 = tmpX + doc.widthOfString(tmpStr2);
  doc.text(tmpStr + tmpStr2, x, y);
  doc.font(FONTS.Helvetica);
  doc.text('60 mg elemental iron with 400 mcg Folic Acid -', tmpX2, y);
  doc.font(FONTS.HelveticaBold);
  y += lineHgt; doc.text('1 tablet once a day (Start upon diagnosis of pregnancy, 180 tablets for 6 months).', tmpX, y);
  tmpStr = '7/ ';
  tmpStr2 = 'Quality Prenatal Care';
  tmpX = x + doc.widthOfString(tmpStr);
  tmpX2 = x + 324;
  y += lineHgt; doc.text(tmpStr + tmpStr2, x, y);
  y += lineHgt; doc.text('(1) Seen be a doctor', tmpX, y);
  doc.text('(4) 3 basic laboratory exams: hemoglobin, blood typing, urinalysis', tmpX2, y);
  y += lineHgt; doc.text('(2) Seen be a dentist', tmpX, y);
  doc.text('(5) Complete iron supplementation for 6 months (180 tabs)', tmpX2, y);
  y += lineHgt; doc.text('(3) 4 or more PNV: 1 in 1st Tri, 1 in 2nd Tri and 2 in 3rd Tri', tmpX, y);
  doc.text('(6) Provided with health info, counseling, etc.', tmpX2, y);
  tmpStr = '8/ REMARKS - ex.: ';
  tmpStr2 = 'Provided health info, given deworming tablet / Insecticide Treated Nets in malaria endemic areas, etc.';
  tmpX = x + doc.widthOfString(tmpStr);
  y += lineHgt; doc.text(tmpStr, x, y);
  doc.font(FONTS.Helvetica);
  doc.text(tmpStr2, tmpX, y);
};


/* --------------------------------------------------------
 * doColHeaderPage1()
 *
 * Write the column headers out for page 1.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doColHeaderPage1 = function(doc, opts) {
  var x = opts.margins.left
    , y = opts.margins.top + 22
    , yTop = y
    , yBottom = y + 90
    , yColNum = yBottom - 12
    , yMid = yBottom - 45
    , fontSizeLarge = 10
    , fontSizeSmall = 7
    , colPos
    , centerX
    , widths = []
    , maxWidth
    , texts = []
    ;

  // --------------------------------------------------------
  // Outer box around the column header.
  // --------------------------------------------------------
  doc
    .moveTo(x, y)
    .lineTo(doc.page.width - opts.margins.right, y)
    .lineTo(doc.page.width - opts.margins.right, y + 72)
    .lineTo(x, y + 72)
    .lineTo(x, y)
    .stroke();

  // --------------------------------------------------------
  // Small box under the outer box.
  // --------------------------------------------------------
  doc
    .moveTo(x, y + 72)
    .lineTo(x, y + 72 + 18)
    .lineTo(doc.page.width - opts.margins.right, y + 72 + 18)
    .lineTo(doc.page.width - opts.margins.right, y + 72)
    .stroke();

  // --------------------------------------------------------
  // Draw column vertical dividers.
  // --------------------------------------------------------
  colPos = getColXposPage1(opts);
  _.each(colPos, function(x, idx) {
    y = yTop;
    if (idx === 7 || idx === 8 || idx === 11) y = yMid;
    doc
      .moveTo(x, y)
      .lineTo(x, yBottom)
      .stroke();
  });

  // --------------------------------------------------------
  // Draw the horizontal dividers in a couple columns.
  // --------------------------------------------------------
  doc
    .moveTo(colPos[6], yMid)
    .lineTo(colPos[9], yMid)
    .moveTo(colPos[10], yMid)
    .lineTo(colPos[12], yMid)
    .stroke();

  // --------------------------------------------------------
  // Text in Column 1 (Date of Registration).
  // --------------------------------------------------------
  centerX = ((colPos[1] - colPos[0])/2) + colPos[0];
  y = yTop + 18;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Date of');
  texts.push('Regis-');
  texts.push('tration');
  texts.push('(1)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 14;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 14;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text in Column 2 (Name).
  // --------------------------------------------------------
  centerX = ((colPos[2] - colPos[1])/2) + colPos[1];
  y = yTop + 25;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Name');
  texts.push('Last                      First');
  texts.push('(2)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 27;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yColNum;
  doc.text(texts[2], centerX - (widths[2]/2), y);

  // --------------------------------------------------------
  // Text in Column 3 (Address).
  // --------------------------------------------------------
  centerX = ((colPos[3] - colPos[2])/2) + colPos[2];
  y = yTop + 25;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Address');
  texts.push('(3)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y = yColNum;
  doc.text(texts[1], centerX - (widths[1]/2), y);

  // --------------------------------------------------------
  // Text in Column 4 (Age and DOB).
  // --------------------------------------------------------
  centerX = ((colPos[4] - colPos[3])/2) + colPos[3];
  y = yTop + 15;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Age &');
  texts.push('Date of');
  texts.push('Birth');
  texts.push('(4)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 22;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 14;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text for Column 5 (LMP and GPAS).
  // --------------------------------------------------------
  centerX = ((colPos[5] - colPos[4])/2) + colPos[4];
  y = yTop + 8;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('LMP');
  texts.push('G (Gravida)');
  texts.push('P (Para)');
  texts.push('A (Abortion)');
  texts.push('S (Stillbirth)');
  texts.push('(5)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  maxWidth = _.max(widths);
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 16;
  doc.text(texts[1], centerX - (maxWidth/2), y);
  y += 11;
  doc.text(texts[2], centerX - (maxWidth/2), y);
  y += 11;
  doc.text(texts[3], centerX - (maxWidth/2), y);
  y += 11;
  doc.text(texts[4], centerX - (maxWidth/2), y);
  y = yColNum;
  doc.text(texts[5], centerX - (widths[5]/2), y);

  // --------------------------------------------------------
  // Text for Column 6 (EDC).
  // --------------------------------------------------------
  centerX = ((colPos[6] - colPos[5])/2) + colPos[5];
  y = yTop + 25;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('EDC');
  texts.push('(6)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y = yColNum;
  doc.text(texts[1], centerX - (widths[1]/2), y);

  // --------------------------------------------------------
  // Text for Column 7 (Prenatal visits, not sub-columns).
  // --------------------------------------------------------
  centerX = ((colPos[9] - colPos[6])/2) + colPos[6];
  y = yTop + 5;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Pre-natal Visits');
  texts.push('(Date)');
  texts.push('(7)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yMid - 12;
  doc.text(texts[2], centerX - (widths[2]/2), y);

  // --------------------------------------------------------
  // Text for Column 7A (1st Trim).
  // --------------------------------------------------------
  centerX = ((colPos[7] - colPos[6])/2) + colPos[6];
  y = yMid + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('1st TRIM');
  widths.push(doc.widthOfString(texts[0]));
  doc.fontSize(fontSizeSmall);
  texts.push('up to 12th wk');
  widths.push(doc.widthOfString(texts[1]));
  doc.fontSize(fontSizeLarge);
  texts.push('(7A)');
  widths.push(doc.widthOfString(texts[2]));
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 9;
  doc.fontSize(fontSizeSmall);
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yColNum;
  doc.fontSize(fontSizeLarge);
  doc.text(texts[2], centerX - (widths[2]/2), y);

  // --------------------------------------------------------
  // Text for Column 7B (2nd Trim).
  // --------------------------------------------------------
  centerX = ((colPos[8] - colPos[7])/2) + colPos[7];
  y = yMid + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('2nd TRIM');
  widths.push(doc.widthOfString(texts[0]));
  doc.fontSize(fontSizeSmall);
  texts.push('13th to 27th wk');
  widths.push(doc.widthOfString(texts[1]));
  doc.fontSize(fontSizeLarge);
  texts.push('(7B)');
  widths.push(doc.widthOfString(texts[2]));
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 9;
  doc.fontSize(fontSizeSmall);
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yColNum;
  doc.fontSize(fontSizeLarge);
  doc.text(texts[2], centerX - (widths[2]/2), y);

  // --------------------------------------------------------
  // Text for Column 7C (3rd Trim).
  // --------------------------------------------------------
  centerX = ((colPos[9] - colPos[8])/2) + colPos[8];
  y = yMid + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('3rd TRIM');
  widths.push(doc.widthOfString(texts[0]));
  doc.fontSize(fontSizeSmall);
  texts.push('28th wk & up');
  widths.push(doc.widthOfString(texts[1]));
  doc.fontSize(fontSizeLarge);
  texts.push('(7C)');
  widths.push(doc.widthOfString(texts[2]));
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 9;
  doc.fontSize(fontSizeSmall);
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yColNum;
  doc.fontSize(fontSizeLarge);
  doc.text(texts[2], centerX - (widths[2]/2), y);

  // --------------------------------------------------------
  // Text for Column 8 (Risk Codes).
  // --------------------------------------------------------
  centerX = ((colPos[10] - colPos[9])/2) + colPos[9];
  y = yTop + 15;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Risk');
  texts.push('Codes');
  texts.push('Date');
  texts.push('Detected');
  texts.push('(8)');
  texts.push('1/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 13;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 13;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y += 13;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  y = yColNum;
  doc.text(texts[4], centerX - (widths[4]/2), y);
  y = yTop + 22;
  doc.text(texts[5], colPos[10] - widths[5] - 10, y);

  // --------------------------------------------------------
  // Text for header of Columns 9 & 10 (Seen by).
  // --------------------------------------------------------
  centerX = ((colPos[12] - colPos[10])/2) + colPos[10];
  y = yTop + 15;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Seen by a');
  widths.push(doc.widthOfString(texts[0]));
  doc.text(texts[0], centerX - (widths[0]/2), y);

  // --------------------------------------------------------
  // Text for Column 9 (Doctor).
  // --------------------------------------------------------
  centerX = ((colPos[11] - colPos[10])/2) + colPos[10];
  y = yMid + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Doctor');
  texts.push('Date');
  texts.push('(9)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yColNum;
  doc.text(texts[2], centerX - (widths[2]/2), y);

  // --------------------------------------------------------
  // Text for Column 10 (Dentist).
  // --------------------------------------------------------
  centerX = ((colPos[12] - colPos[11])/2) + colPos[11];
  y = yMid + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Dentist');
  texts.push('Date');
  texts.push('(10)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yColNum;
  doc.text(texts[2], centerX - (widths[2]/2), y);
};


/* --------------------------------------------------------
 * doColHeaderPage2()
 *
 * Write the column headers out for page 2.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doColHeaderPage2 = function(doc, opts) {
  var x = opts.margins.left
    , y = opts.margins.top + 22
    , yTop = y
    , yBottom = y + 90
    , yColNum = yBottom - 12
    , yMidUpper = yTop + 18
    , yMidLower = yBottom - 55
    , fontSizeLarge = 9
    , fontSizeSmall = 7
    , colPos
    , midColsLower = [1, 2, 3, 7, 14]
    , midColsUpper = [8, 9, 10]
    , bottomCols = [12, 13]
    , centerX
    , widths = []
    , maxWidth
    , texts = []
    ;

  // --------------------------------------------------------
  // Outer box around the column header.
  // --------------------------------------------------------
  doc
    .moveTo(x, y)
    .lineTo(doc.page.width - opts.margins.right, y)
    .lineTo(doc.page.width - opts.margins.right, y + 72)
    .lineTo(x, y + 72)
    .lineTo(x, y)
    .stroke();

  // --------------------------------------------------------
  // Small box under the outer box.
  // --------------------------------------------------------
  doc
    .moveTo(x, y + 72)
    .lineTo(x, y + 72 + 18)
    .lineTo(doc.page.width - opts.margins.right, y + 72 + 18)
    .lineTo(doc.page.width - opts.margins.right, y + 72)
    .stroke();

  // --------------------------------------------------------
  // Draw column vertical dividers.
  // --------------------------------------------------------
  colPos = getColXposPage2(opts);
  _.each(colPos, function(x, idx) {
    y = yTop;
    if (_.contains(midColsLower, idx)) y = yMidLower;
    if (_.contains(midColsUpper, idx)) y = yMidUpper;
    if (_.contains(bottomCols, idx)) y = yBottom;
    doc
      .moveTo(x, y)
      .lineTo(x, yBottom)
      .stroke();
  });

  // --------------------------------------------------------
  // Draw the horizontal dividers in some columns.
  // --------------------------------------------------------
  doc
    .moveTo(colPos[0], yMidLower)
    .lineTo(colPos[4], yMidLower)
    .moveTo(colPos[6], yMidLower)
    .lineTo(colPos[8], yMidLower)
    .moveTo(colPos[11], yMidLower)
    .lineTo(colPos[15], yMidLower)
    .stroke();

  doc
    .moveTo(colPos[0], yMidUpper)
    .lineTo(colPos[4], yMidUpper)
    .moveTo(colPos[6], yMidUpper)
    .lineTo(colPos[11], yMidUpper)
    .stroke();


  // --------------------------------------------------------
  // Text in Column 1 (Mother and Child book).
  // --------------------------------------------------------
  centerX = ((colPos[1] - colPos[0])/2) + colPos[0];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Mother');
  texts.push('& Child-');
  texts.push('Book');
  texts.push('(11A)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text in Column 2 (Where to deliver).
  // --------------------------------------------------------
  centerX = ((colPos[2] - colPos[1])/2) + colPos[1];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Where');
  texts.push('to');
  texts.push('deliver');
  texts.push('(11B)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text in Column 3 (Partner during deliver).
  // --------------------------------------------------------
  centerX = ((colPos[3] - colPos[2])/2) + colPos[2];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Partner');
  texts.push('during');
  texts.push('deliver');
  texts.push('(11C)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text in Column 4 (Phil Health).
  // --------------------------------------------------------
  centerX = ((colPos[4] - colPos[3])/2) + colPos[3];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Phil');
  texts.push('Health');
  texts.push('Member');
  texts.push('(11D)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text over Columns 1 to 4.
  // --------------------------------------------------------
  centerX = ((colPos[4] - colPos[0])/2) + colPos[0];
  y = yTop + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Birth Plan');
  texts.push('(11)');
  texts.push('2/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 18;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yTop + 4;
  doc.fontSize(fontSizeSmall);
  doc.text(texts[2], centerX + (widths[0]/2) + 3, y);

  // --------------------------------------------------------
  // Text in Column 5 (Previous TT Received).
  // --------------------------------------------------------
  centerX = ((colPos[5] - colPos[4])/2) + colPos[4];
  y = yTop + 8;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Previous');
  texts.push('TT Imm\'n');
  texts.push('Received');
  texts.push('(Date');
  texts.push('Received)');
  texts.push('(12)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y += 11;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  y += 11;
  doc.text(texts[4], centerX - (widths[4]/2), y);
  y = yColNum;
  doc.text(texts[5], centerX - (widths[5]/2), y);

  // --------------------------------------------------------
  // Text in Column 6 (TT Immunization given).
  // --------------------------------------------------------
  centerX = ((colPos[6] - colPos[5])/2) + colPos[5];
  y = yTop + 8;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('TT Immuni');
  texts.push('zation');
  texts.push('given');
  texts.push('(Date');
  texts.push('Given)');
  texts.push('(13)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y += 11;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  y += 11;
  doc.text(texts[4], centerX - (widths[4]/2), y);
  y = yColNum;
  doc.text(texts[5], centerX - (widths[5]/2), y);

  // --------------------------------------------------------
  // Text in Column 7 (Hemoglobin 1).
  // --------------------------------------------------------
  centerX = ((colPos[7] - colPos[6])/2) + colPos[6];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('1st');
  texts.push('Date');
  texts.push('Result');
  texts.push('(14)');
  texts.push('3/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  doc.fontSize(fontSizeSmall);
  y = yMidLower + 2;
  doc.text(texts[4], centerX + (widths[0]/2) + 3, y);

  // --------------------------------------------------------
  // Text in Column 8 (Hemoglobin 2).
  // --------------------------------------------------------
  centerX = ((colPos[8] - colPos[7])/2) + colPos[7];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('2nd');
  texts.push('Date');
  texts.push('Result');
  texts.push('(15)');
  texts.push('4/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  doc.fontSize(fontSizeSmall);
  y = yMidLower + 2;
  doc.text(texts[4], centerX + (widths[0]/2) + 3, y);

  // --------------------------------------------------------
  // Text in Column 9 (Blood Type).
  // --------------------------------------------------------
  centerX = ((colPos[9] - colPos[8])/2) + colPos[8];
  y = yMidUpper + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Blood');
  texts.push('Type');
  texts.push('Date');
  texts.push('Result');
  texts.push('(16)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yMidLower + 15; // Line up on these 4 columns.
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y += 11;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  y = yColNum;
  doc.text(texts[4], centerX - (widths[4]/2), y);

  // --------------------------------------------------------
  // Text in Column 10 (Urinalysis).
  // --------------------------------------------------------
  centerX = ((colPos[10] - colPos[9])/2) + colPos[9];
  y = yMidUpper + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Urinalysis');
  texts.push('Date');
  texts.push('Result');
  texts.push('(17)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y = yMidLower + 15; // Line up on these 4 columns.
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text in Column 11 (RTI STI).
  // --------------------------------------------------------
  centerX = ((colPos[11] - colPos[10])/2) + colPos[10];
  y = yMidUpper + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('RTI');
  texts.push('STI');
  texts.push('Date');
  texts.push('Result');
  texts.push('(18)');
  texts.push('5/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y = yMidLower + 15; // Line up on these 4 columns.
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y += 11;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  y = yColNum;
  doc.text(texts[4], centerX - (widths[4]/2), y);
  doc.fontSize(fontSizeSmall);
  y = yMidUpper + 6;
  doc.text(texts[5], centerX + (widths[0]/2) + 3, y);

  // --------------------------------------------------------
  // Text over Columns 7 to 8.
  // --------------------------------------------------------
  centerX = ((colPos[8] - colPos[6])/2) + colPos[6];
  y = yMidUpper + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Hemoglobin');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);

  // --------------------------------------------------------
  // Text over Columns 6 to 11.
  // --------------------------------------------------------
  centerX = ((colPos[11] - colPos[6])/2) + colPos[6];
  y = yTop + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Laboratory Examinations');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);

  // --------------------------------------------------------
  // Text in Column 12 to 14 (Iron with Folic).
  // --------------------------------------------------------
  centerX = ((colPos[14] - colPos[11])/2) + colPos[11];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Iron with Folic');
  texts.push('No. of Tablets/');
  texts.push('Date Given');
  texts.push('(19)');
  texts.push('6/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  doc.fontSize(fontSizeSmall);
  y = yMidLower + 2;
  doc.text(texts[4], centerX + (widths[0]/2) + 3, y);

  // --------------------------------------------------------
  // Text in Column 15 (Iodized Salt).
  // --------------------------------------------------------
  centerX = ((colPos[15] - colPos[14])/2) + colPos[14];
  y = yMidLower + 4;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Using');
  texts.push('Iodized');
  texts.push('Salt (Y/N)');
  texts.push('(20)');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 11;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 11;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y = yColNum;
  doc.text(texts[3], centerX - (widths[3]/2), y);

  // --------------------------------------------------------
  // Text over Columns 12 to 15.
  // --------------------------------------------------------
  centerX = ((colPos[15] - colPos[11])/2) + colPos[11];
  y = yTop + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('MicroNutrient Supplementation');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);

  // --------------------------------------------------------
  // Text in Column 15 (Quality Prenatal Care).
  // --------------------------------------------------------
  centerX = ((colPos[16] - colPos[15])/2) + colPos[15];
  y = yTop + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Quality');
  texts.push('Prenatal');
  texts.push('Care');
  texts.push('(Yes/No)');
  texts.push('(21)');
  texts.push('7/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 19;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  y += 19;
  doc.text(texts[2], centerX - (widths[2]/2), y);
  y += 19;
  doc.text(texts[3], centerX - (widths[3]/2), y);
  y = yColNum;
  doc.text(texts[4], centerX - (widths[4]/2), y);
  doc.fontSize(fontSizeSmall);
  y = yTop + 3;
  doc.text(texts[5], centerX + (widths[0]/2) + 2, y);

  // --------------------------------------------------------
  // Text in Column 16 (Remarks).
  // --------------------------------------------------------
  centerX = ((colPos[17] - colPos[16])/2) + colPos[16];
  y = yTop + 6;
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(fontSizeLarge);
  texts = []; widths = [];
  texts.push('Remarks');
  texts.push('(22)');
  texts.push('8/');
  _.each(texts, function(s) {
    widths.push(doc.widthOfString(s));
  });
  doc.text(texts[0], centerX - (widths[0]/2), y);
  y += 19;
  y = yColNum;
  doc.text(texts[1], centerX - (widths[1]/2), y);
  doc.fontSize(fontSizeSmall);
  y = yTop + 3;
  doc.text(texts[2], centerX + (widths[0]/2) + 2, y);
};


/* --------------------------------------------------------
 * doRowsGridPage()
 *
 * Write out the lines for the rows on page one without the
 * data.
 *
 * param      doc
 * param      opts
 * param      page - 1 or 2
 * return     undefined
 * -------------------------------------------------------- */
var doRowsGridPage = function(doc, opts, page) {
  var xLeft = opts.margins.left
    , xRight = doc.page.width - opts.margins.right
    , yTop = opts.margins.top + 22 + 90
    , rowHeight = 45
    , colPos = page === 1 ? getColXposPage1(opts): page === 2 ? getColXposPage2(opts): void 0
    , numRows = 8
    , y = yTop + rowHeight    // Skip top line because already there.
    , i
    ;

  // --------------------------------------------------------
  // Draw the row lines.
  // --------------------------------------------------------
  for (i = 0; i < numRows; i++) {
    doc
      .moveTo(xLeft, y)
      .lineTo(xRight, y)
      .stroke();
    y += rowHeight;
  }

  // --------------------------------------------------------
  // Draw the column lines.
  // --------------------------------------------------------
  _.each(colPos, function(x, idx) {
    var y;
    if (page === 2 && idx === 5) {
      // Special: this has numbers for the column divider.
      for (var i = 0; i < numRows; i++) {
        y = yTop + (rowHeight * i) + 3;
        doc.text('1', x - 1, y);
        y += 8; doc.text('2', x - 1, y);
        y += 8; doc.text('3', x - 1, y);
        y += 8; doc.text('4', x - 1, y);
        y += 8; doc.text('5', x - 1, y);
      }
    } else {
      // Normal processing.
      doc
        .moveTo(x, yTop)
        .lineTo(x, yTop + (rowHeight * numRows))
        .stroke();
    }
  });
};


/* --------------------------------------------------------
 * doPageNumber()
 *
 * Write the page number of the report out including info
 * about whether this is side A or B. Includes the date
 * as well.
 *
 * param      doc
 * param      opts
 * param      side
 * param      page
 * return     undefined
 * -------------------------------------------------------- */
var doPageNumber = function(doc, opts, side, page) {
  var xStr1 = opts.margins.left
    , xStr2
    , y = opts.margins.top + 10
    , from = moment(opts.fromDate).format('ddd MMM DD, YYYY')
    , to = moment(opts.toDate).format('ddd MMM DD, YYYY')
    , str1 = 'Page ' + page + ' - ' + side
    , str2 = 'Reporting for: ' + from + ' to ' + to
    ;

  if (moment(opts.fromDate).isSame(moment(opts.toDate), 'day')) {
    str2 = 'Reporting for: ' + from;
  }
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(10);
  xStr2 = xStr1 + doc.widthOfString(str1) + 20;

  doc
    .text(str1, xStr1, y)
    .text(str2, xStr2, y);
};


/* --------------------------------------------------------
 * getColXposPage1()
 *
 * Returns an array with the x value of each of the 13 lines
 * that make up the columns of page 1.
 *
 * param      opts
 * return     array of x positions
 * -------------------------------------------------------- */
var getColXposPage1 = function(opts) {
  var xPos = []
    , x
    ;
  x = opts.margins.left; xPos.push(x);  // left margin
  x += 60; xPos.push(x);                // Date of registration
  x += 170; xPos.push(x);               // Name
  x += 112; xPos.push(x);               // Address
  x += 61; xPos.push(x);                // Age & DOB
  x += 61; xPos.push(x);                // LMP & GPAS
  x += 66; xPos.push(x);                // EDC
  x += 58; xPos.push(x);                // 1st TRIM
  x += 58; xPos.push(x);                // 2nd TRIM
  x += 58; xPos.push(x);                // 3rd TRIM
  x += 80; xPos.push(x);                // Risk codes
  x += 58; xPos.push(x);                // Doctor
  x += 58; xPos.push(x);                // Dentist
  return xPos;
};


/* --------------------------------------------------------
 * getColXposPage2()
 *
 * Returns an array with the x value of each of the 18 lines
 * that make up the columns of page 2.
 *
 * param       opts
 * return      array of x positions
 * -------------------------------------------------------- */
var getColXposPage2 = function(opts) {
  var xPos = []
    , x
    ;
  x = opts.margins.left; xPos.push(x);  // left margin
  x += 36; xPos.push(x);                // Mother and Child book
  x += 51; xPos.push(x);                // Where to deliver
  x += 54; xPos.push(x);                // Partner
  x += 36; xPos.push(x);                // Phil Health
  x += 48; xPos.push(x);                // Previous TT
  x += 51; xPos.push(x);                // TT Immunizations
  x += 48; xPos.push(x);                // Lab 1
  x += 48; xPos.push(x);                // Lab 2
  x += 48; xPos.push(x);                // Blood type
  x += 51; xPos.push(x);                // Urinalysis
  x += 54; xPos.push(x);                // RTI STI
  x += 48; xPos.push(x);                // Iron 1
  x += 48; xPos.push(x);                // Iron 2
  x += 48; xPos.push(x);                // Iron 3
  x += 48; xPos.push(x);                // Salt
  x += 48; xPos.push(x);                // Quality Prenatal
  x += 135; xPos.push(x);               // Remarks
  return xPos;
};


/* --------------------------------------------------------
 * doStaticPage1()
 *
 * Write out the static (non-data) elements of page 1.
 *
 * param      doc
 * param      opts
 * param      currPage - the current page number
 * return     undefined
 * -------------------------------------------------------- */
var doStaticPage1 = function(doc, opts, currPage) {
  if (currPage > 1) doc.addPage();
  doPageNumber(doc, opts, 'A', currPage);
  doHeaderPage1(doc, opts);
  doFooterPage1(doc, opts);
  doColHeaderPage1(doc, opts);
  doRowsGridPage(doc, opts, 1);
};


/* --------------------------------------------------------
 * doStaticPage2()
 *
 * Write out the static (non-data) elements of page 2.
 *
 * param      doc
 * param      opts
 * param      currPage - the current page number
 * return     undefined
 * -------------------------------------------------------- */
var doStaticPage2 = function(doc, opts, currPage) {
  doc.addPage();
  doPageNumber(doc, opts, 'B', currPage);
  doFooterPage2(doc, opts);
  doColHeaderPage2(doc, opts);
  doRowsGridPage(doc, opts, 2);
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
  var currentRow = 1
    , pageNum = 1
    , totalPcs = _.reduce(_.pluck(data, 'numberDispensed'),
        function(memo, num) {return memo + num;}, 0)
    , totalPages = Math.ceil(data.length / rowsPerPage) * 2
    , dataPage2 = []
    ;


  // --------------------------------------------------------
  // Do each row, adding pages as necessary.
  // --------------------------------------------------------
  _.each(data, function(rec) {
    if (currentRow === 1) {
      dataPage2 = [];
      doStaticPage1(doc, opts, pageNum);
    }
    // Write out the row for page 1.
    doRowPage1(doc, opts, rec, currentRow);

    // Save the row for page 2.
    dataPage2.push(rec);

    // Last row written for page 1, not do all of page 2.
    if (currentRow === rowsPerPage) {
      currentRow = 1;
      // Write out the static and data for page 2.
      doStaticPage2(doc, opts, pageNum);
      _.each(dataPage2, function(rec) {
        doRowPage2(doc, opts, rec, currentRow);
        currentRow++;
      });
      pageNum++;
      currentRow = 1;
    } else {
      currentRow++;
    }
  });
  // Write out the last page 2.
  if (currentRow > 1) {
    currentRow = 1;
    doStaticPage2(doc, opts, pageNum);
    _.each(dataPage2, function(rec) {
      doRowPage2(doc, opts, rec, currentRow);
      currentRow++;
    });
  }


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
          , right: 18
          , left: 18
          , bottom: 18
        }
        , layout: 'landscape'
        , size: 'folio'     // folio is Asia Legal, 8.5"x13"
        , info: {
            Title: 'MASTERLIST FOR PRENATAL'
            , Author: 'Mercy Application'
            , Subject: 'DOH Masterlist for Prenatal Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 8    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.fromDate = moment(flds.dateFrom).format('YYYY-MM-DD');
  opts.toDate = moment(flds.dateTo).format('YYYY-MM-DD');
  opts.title = options.info.Title;
  opts.margins = options.margins;

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  // Build the parts of the document.
  getData(opts.fromDate, opts.toDate)
    .then(function(list) {
      var partitioned
        , data
        ;
      // --------------------------------------------------------
      // Sort all of the custom field 'Agdao' records to the front.
      // The getData() function already returns records in
      // lastname, firstname order which will apply to the
      // remainder of the data.
      // --------------------------------------------------------
      partitioned = _.partition(list, function(rec) {
        return !! (rec.customFields && rec.customFields.length > 0 &&
            _.findWhere(rec.customFields, {name: 'Agdao'}));
      });
      data = partitioned[0];
      _.each(partitioned[1], function(rec) { data.push(rec); });

      doPages(doc, data, rowsPerPage, opts);
    })
    .then(function() {
      doc.end();
    });
};

/* --------------------------------------------------------
 * run()
 *
 * Run the master list report.
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
  // Note: logistics in charge is not necessary for this report.
  // --------------------------------------------------------
  if (! flds.dateFrom || flds.dateFrom.length == 0 || ! moment(flds.dateFrom).isValid()) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must supply a FROM date for the report.'));
  }
  if (! flds.dateTo || flds.dateTo.length == 0 || ! moment(flds.dateTo).isValid()) {
    fieldsReady = false;
    req.flash('error', req.gettext('You must supply a TO date for the report.'));
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

  doReport(flds, writable);
};


module.exports = {
  run: run
};


