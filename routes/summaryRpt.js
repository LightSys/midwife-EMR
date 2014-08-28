/*
 * -------------------------------------------------------------------------------
 * summaryRpt.js
 *
 * Generates the summary report for a single pregnancy/patient.
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
  , Patient = require('../models').Patient
  , Patients = require('../models').Patients
  , Vaccination = require('../models').Vaccination
  , Vaccinations = require('../models').Vaccinations
  , Medication = require('../models').Medication
  , Medications = require('../models').Medications
  , PrenatalExam = require('../models').PrenatalExam
  , PrenatalExams = require('../models').PrenatalExams
  , PregnancyHistory = require('../models').PregnancyHistory
  , PregnancyHistories = require('../models').PregnancyHistories
  , Referral = require('../models').Referral
  , Referrals = require('../models').Referrals
  , LabTestResult = require('../models').LabTestResult
  , LabTestResults = require('../models').LabTestResults
  , User = require('../models').User
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , formatDohID = require('../util').formatDohID
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , doSiteTitle = require('./reportGeneral').doSiteTitle
  , doReportName = require('./reportGeneral').doReportName
  , doCellBorders = require('./reportGeneral').doCellBorders
  , loadFontAwesome = require('./reportGeneral').loadFontAwesome
  , blackColor = '#000'
  , greyDarkColor = '#999'
  , greyLightColor = '#AAA'
  ;

/* --------------------------------------------------------
 * doReportDate()
 *
 * Write the date of the report.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doReportDate = function(doc, opts) {
  var pretext = 'Current as of: '
    , theDate = moment().format('MMM DD, YYYY h:mm a')
    , y = 70
    , pretextWidth
    , dateWidth
    , xpos1
    , xpos2
    ;
  doc
    .font(FONTS.Helvetica)
    .fontSize(10);
  pretextWidth = parseInt(doc.widthOfString(pretext), 10);
  dateWidth = parseInt(doc.widthOfString(theDate), 10);
  xpos1 = Math.round((doc.page.width/2) - ((pretextWidth + dateWidth)/2));
  xpos2 = xpos1 + pretextWidth;
  doc
    .text(pretext, xpos1, y)
    .font(FONTS.HelveticaBold)
    .fontSize(10)
    .text(theDate, xpos2, y);
};

/* --------------------------------------------------------
 * doSep()
 *
 * Draw a horizontal separator line at the specified y position.
 *
 * param      doc
 * param      opts
 * param      ypos
 * param      color     - e.g. '#995' or 'red'
 * return     undefined
 * -------------------------------------------------------- */
var doSep = function(doc, opts, ypos, color) {
  var left = opts.margins.left
    , right = doc.page.width - opts.margins.right
    ;
  doc
    .lineWidth(1)
    .moveTo(left, ypos)
    .lineTo(right, ypos)
    .stroke(color);
};

/* --------------------------------------------------------
 * doPageCommon()
 *
 * Write out to the report the things that are common to
 * every page of the report.
 *
 * param      doc     - the document
 * param      data    - the data
 * param      opts    - options
 * return     undefined
 * -------------------------------------------------------- */
var doPageCommon = function doPageCommon(doc, data, opts) {
  doSiteTitle(doc, 24);
  doReportName(doc, opts.title, 48);
  doReportDate(doc, opts);
};

/* --------------------------------------------------------
 * doVertFldVal()
 *
 * Write a field label and it's corresponding field value
 * directly underneath it. faint parameter affects how the
 * field is displayed.
 *
 * param      doc
 * param      label
 * param      value
 * param      x - position field should start horizontally
 * param      y - position label should start
 * param      faint - boolean whether label should be faint and smaller
 * return
 * -------------------------------------------------------- */
var doVertFldVal = function(doc, label, value, x, y, faint) {
  var val = value? value: ''
    , y2 = y + 10
    , lblColor = faint? greyDarkColor: blackColor
    , lblSize = faint? 8: 9
    ;
  doc
    .font(FONTS.Helvetica)
    .fontSize(lblSize)
    .fillColor(lblColor)
    .text(label, x, y)
    .fillColor(blackColor)
    .fontSize(9)
    .font(FONTS.HelveticaBold)
    .text(val, x, y2);
  return doc.y;
};

/* --------------------------------------------------------
 * doLabel()
 *
 * Writes out a field label.
 *
 * param      doc
 * param      label
 * param      x
 * param      y
 * return     undefined
 * -------------------------------------------------------- */
var doLabel = function(doc, label, x, y) {
  doc
    .font(FONTS.Helvetica)
    .fontSize(8)
    .fillColor(greyDarkColor)
    .text(label, x, y);
};

/* --------------------------------------------------------
 * doShortAnswer()
 *
 * Label comes first and value (answer) comes after on
 * same line.
 *
 * param      doc
 * param      label
 * param      value
 * param      x
 * param      y
 * param      faint
 * returns    undefined
 * -------------------------------------------------------- */
var doShortAnswer = function(doc, label, value, x, y, faint) {
  var x2
    , lblColor = faint? greyDarkColor: blackColor
    ;
  doc
    .font(FONTS.Helvetica)
    .fontSize(9)
    .fillColor(lblColor)
    .text(label, x, y);

  x2 = parseInt(doc.x + doc.widthOfString(label), 10) + 5;

  doc
    .font(FONTS.HelveticaBold)
    .fontSize(9)
    .fillColor(blackColor)
    .text(value, x2, y);
};


/* --------------------------------------------------------
 * doYesNo()
 *
 * Writes a label and data for a Yes/No short answer.
 *
 * param      doc
 * param      label
 * param      value
 * param      x
 * param      y
 * return     y - new y position
 * -------------------------------------------------------- */
var doYesNo = function(doc, label, value, x, y) {
  var val = ''
    ;
  if (value.toLowerCase() === 'y') val = 'Y';
  if (value.toLowerCase() === 'n') val = 'N';
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(9)
    .fillColor(blackColor)
    .text(val, x, y);
  doc
    .font(FONTS.Helvetica)
    .fontSize(9)
    .fillColor(blackColor)
    .text(label, x + 10, y);
  return doc.y;
};

/* --------------------------------------------------------
 * doCheckbox()
 *
 * Write a checkbox, either checked or not, and the label
 * that goes with it.
 *
 * Note: uses Font-Awesome fonts to display an empty or checked
 * checkbox. See characters available here.
 *
 * http://fortawesome.github.io/Font-Awesome/cheatsheet/
 *
 * param      doc
 * param      label
 * param      value - boolean for checked or not
 * param      x
 * param      y
 * return     y position at the end of writing
 * -------------------------------------------------------- */
var doCheckbox = function(doc, label, value, x, y) {
  var check = value? '\uf046': '\uf096'
    ;

  doc
    .font(FONTS.FontAwesome)
    .fontSize(9)
    .fillColor(blackColor)
    .text(check, x, y-1);   // y value compensate for look of FontAwesome char
  doc
    .font(FONTS.Helvetica)
    .fontSize(9)
    .fillColor(blackColor)
    .text(label, x + 10, y);
  return doc.y;
};

/* --------------------------------------------------------
 * doClientGeneral()
 *
 * Create the general information section for the client.
 *
 * param      doc
 * param      data
 * param      opts
 * param      ypos
 * return     y - new y position
 * -------------------------------------------------------- */
var doClientGeneral = function(doc, data, opts, ypos) {
  var x = opts.margins.left
    , y = ypos
    , age = moment().diff(moment(data.patient.dob), 'years')
    , dob = moment(data.patient.dob).format('MM/DD/YYYY')
    , dohID = formatDohID(data.patient.dohID)
    , clientIncome = ''
    , partnerIncome = ''
    ;
  if (data.pregnancy.clientIncome && data.pregnancy.clientIncomePeriod) {
    clientIncome = data.pregnancy.clientIncome + ' / ' +
      data.pregnancy.clientIncomePeriod;
  }
  if (data.pregnancy.partnerIncome && data.pregnancy.partnerIncomePeriod) {
    partnerIncome = data.pregnancy.partnerIncome + ' / ' +
      data.pregnancy.partnerIncomePeriod;
  }

  doSep(doc, opts, y, greyLightColor);

  // First line across
  y += 10;
  doVertFldVal(doc, 'Lastname', data.pregnancy.lastname, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Firstname', data.pregnancy.firstname, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Maidenname', data.pregnancy.maidenname, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Nickname', data.pregnancy.nickname, x, y, true);
  x += 100;
  doVertFldVal(doc, 'DOB (Age)', dob + ' (' + age + ')', x, y, true);
  x += 100;
  doVertFldVal(doc, 'MMC', dohID, x, y, true);
  // Second line
  x = opts.margins.left;
  y += 30;
  doVertFldVal(doc, 'Address', data.pregnancy.address, x, y, true);
  x += 200;
  doVertFldVal(doc, 'Barangay', data.pregnancy.barangay, x, y, true);
  x += 100;
  doVertFldVal(doc, 'City', data.pregnancy.city, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Postal', data.pregnancy.postalCode, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Telephone', data.pregnancy.telephone, x, y, true);
  // Third line
  x = opts.margins.left;
  y += 30;
  doVertFldVal(doc, 'Marital Status', data.pregnancy.maritalStatus, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Religion', data.pregnancy.religion, x, y, true);
  x += 200;
  doVertFldVal(doc, 'Education', data.pregnancy.education, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Client Work', data.pregnancy.work, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Client Income', clientIncome, x, y, true);
  // Fourth line
  x = opts.margins.left;
  y += 30;
  doVertFldVal(doc, 'Partner Firstname', data.pregnancy.partnerFirstname, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Partner Lastname', data.pregnancy.partnerLastname, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Partner Age', data.pregnancy.partnerAge, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Partner Education', data.pregnancy.partnerEducation, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Partner Work', data.pregnancy.partnerWork, x, y, true);
  x += 100;
  doVertFldVal(doc, 'Partner Income', partnerIncome, x, y, true);

  y += 30;
  return y;
};


/* --------------------------------------------------------
 * doNote()
 *
 * Creates the risk note section.
 *
 * param      doc
 * param      data
 * param      opts
 * param      ypos
 * return     y - new y position
 * -------------------------------------------------------- */
var doNote = function(doc, data, opts, ypos) {
  var x = opts.margins.left
    , y = ypos
    , riskNote = ''
    ;

  if (data.pregnancy.riskNote) {
    riskNote = data.pregnancy.riskNote.replace(/(?:\r\n|\r|\n)/g, ' ');
  }
  doSep(doc, opts, ypos, greyLightColor);

  y += 10;
  doVertFldVal(doc, 'Risk Notes', riskNote, x, y, true);

  y = doc.y + 10;
  return y;
}

/* --------------------------------------------------------
 * doMidwifeInterview()
 *
 * Writes the information gleaned from the initial midwife interview.
 *
 * param      doc
 * param      data
 * param      opts
 * param      ypos
 * return     y - new y position
 * -------------------------------------------------------- */
var doMidwifeInterview = function(doc, data, opts, ypos) {
  var x = opts.margins.left
    , y = ypos
    , midwifeNotes = ''
    , noneOfAbove = false
    , x2
    , x3
    ;

  if (data.pregnancy.note) {
    midwifeNotes = data.pregnancy.note.replace(/(?:\r\n|\r|\n)/g, ' ');
  }

  if (data.pregnancy.invertedNipples == 0 &&
      data.pregnancy.hasUS == 0 &&
      data.pregnancy.wantsUS == 0) {
    noneOfAbove = true;
  }

  doSep(doc, opts, ypos, greyLightColor);
  y += 10;
  doLabel(doc, 'Midwife Interview', x, y);

  y += 15;
  y = doCheckbox(doc, 'Inverted nipples?', data.pregnancy.invertedNipples, x, y);
  y = doCheckbox(doc, 'Client has U/S?', data.pregnancy.hasUS, x, y);
  y = doCheckbox(doc, 'Client wants U/S?', data.pregnancy.wantsUS, x, y);
  y = doCheckbox(doc, 'None of the above', noneOfAbove, x, y);

  x += 120;
  x3 = x;     // Save for notes below.
  y = ypos + 10;
  y = doVertFldVal(doc, 'Age of menarche?', data.patient.ageOfMenarche, x, y);

  x += 100;
  y = ypos + 10;
  doShortAnswer(doc, 'Gravida:', data.pregnancy.gravida, x, y, true);
  x = doc.x + 20;
  x2 = x;   // Save for term and preterm below.
  doShortAnswer(doc, 'Para:', data.pregnancy.para, x, y, true);
  x = doc.x + 80;
  doShortAnswer(doc, 'Abortions:', data.pregnancy.abortions, x, y, true);
  x = doc.x + 20;
  doShortAnswer(doc, 'Living:', data.pregnancy.living, x, y, true);
  x = doc.x + 20;
  doShortAnswer(doc, 'Still births:', data.pregnancy.stillBirths, x, y, true);

  y += 15;
  doShortAnswer(doc, 'Term:', data.pregnancy.term, x2, y, true);
  x2 = doc.x + 20;
  doShortAnswer(doc, 'Preterm:', data.pregnancy.preterm, x2, y, true);

  y += 15;
  y = doVertFldVal(doc, 'Midwife comments', midwifeNotes, x3, y, true);
  if (midwifeNotes.length < 200) {
    y += 30;   // Move it down enough if few notes.
  } else {
    y = doc.y + 15;
  }

  return y;
};

/* --------------------------------------------------------
 * doQuestionnaire()
 *
 * Creates the questionnaire section of the report.
 *
 * param      doc
 * param      data
 * param      opts
 * param      ypos
 * return     y - new y position
 * -------------------------------------------------------- */
var doQuestionnaire = function(doc, data, opts, ypos) {
  var x = opts.margins.left
    , y = ypos
    , questionnaireNote = ''
    ;

  if (data.pregnancy.questionnaireNote) {
    questionnaireNote = data.pregnancy.questionnaireNote.replace(/(?:\r\n|\r|\n)/g, ' ');
  }
  doSep(doc, opts, ypos, greyLightColor);
  y += 10;

  // --------------------------------------------------------
  // Present complaints.
  // --------------------------------------------------------
  doLabel(doc, 'Present complaints', x, y);
  y += 15;
  y = doCheckbox(doc, 'Been vomiting?', data.pregnancy.currentlyVomiting, x, y);
  y = doCheckbox(doc, 'Feeling dizzy?', data.pregnancy.currentlyDizzy, x, y);
  y = doCheckbox(doc, 'Have fainted?', data.pregnancy.currentlyFainting, x, y);
  y = doCheckbox(doc, 'Bleeding?', data.pregnancy.currentlyBleeding, x, y);
  y = doCheckbox(doc, 'Pain in urinating?', data.pregnancy.currentlyUrinationPain, x, y);
  y = doCheckbox(doc, 'Blurry vision?', data.pregnancy.currentlyBlurryVision, x, y);
  y = doCheckbox(doc, 'Swelling?', data.pregnancy.currentlySwelling, x, y);
  y = doCheckbox(doc, 'Vaginal pain?', data.pregnancy.currentlyVaginalPain, x, y);
  y = doCheckbox(doc, 'Vaginal itching?', data.pregnancy.currentlyVaginalItching, x, y);
  y = doCheckbox(doc, 'None of the above', data.pregnancy.currentlyNone, x, y);

  // --------------------------------------------------------
  // Present comments.
  // --------------------------------------------------------
  x += 135;
  y = ypos + 10;
  doLabel(doc, 'Present comments', x, y);
  y += 15;
  y = doYesNo(doc, 'Using iodized salt?', data.pregnancy.useIodizedSalt, x, y);
  y = doCheckbox(doc, 'Taking medication?', data.pregnancy.takingMedication, x, y);
  y = doCheckbox(doc, 'Plan to breastfeed?', data.pregnancy.planToBreastFeed, x, y);
  y += 5;
  y = doVertFldVal(doc, 'Where do you plan to give birth?', data.pregnancy.whereDeliver, x, y);
  y += 5;
  y = doVertFldVal(doc, 'Companion during childbirth?', data.pregnancy.birthCompanion, x, y);
  y += 5;
  y = doCheckbox(doc, 'Practiced family planning?', data.pregnancy.practiceFamilyPlanning, x, y);
  y -= 10;    // Family planning details - just put under checkbox quesion with no label.
  y = doVertFldVal(doc, '', data.pregnancy.practiceFamilyPlanningDetails, x, y);

  // --------------------------------------------------------
  // Family History.
  // --------------------------------------------------------
  x += 165;
  y = ypos + 10;
  doLabel(doc, 'Family History', x, y);
  y += 15;
  y = doCheckbox(doc, 'Twins?', data.pregnancy.familyHistoryTwins, x, y);
  y = doCheckbox(doc, 'High Blood Pressure?', data.pregnancy.familyHistoryHighBloodPressure, x, y);
  y = doCheckbox(doc, 'Diabetes?', data.pregnancy.familyHistoryDiabetes, x, y);
  y = doCheckbox(doc, 'Heart Problems?', data.pregnancy.familyHistoryHeartProblems, x, y);
  y = doCheckbox(doc, 'TB?', data.pregnancy.familyHistoryTB, x, y);
  y = doCheckbox(doc, 'Smoking?', data.pregnancy.familyHistorySmoking, x, y);
  y = doCheckbox(doc, 'None of the above', data.pregnancy.familyHistoryNone, x, y);

  // --------------------------------------------------------
  // Personal History.
  // --------------------------------------------------------
  x += 150;
  y = ypos + 10;
  doLabel(doc, 'Personal History', x, y);
  y += 15;
  y = doCheckbox(doc, 'Food allergy?', data.pregnancy.historyFoodAllergy, x, y);
  y = doCheckbox(doc, 'Medicine allergy?', data.pregnancy.historyMedicineAllergy, x, y);
  y = doCheckbox(doc, 'Asthma?', data.pregnancy.historyAsthma, x, y);
  y = doCheckbox(doc, 'Heart problems?', data.pregnancy.historyHeartProblems, x, y);
  y = doCheckbox(doc, 'Kidney problems?', data.pregnancy.historyKidneyProblems, x, y);
  y = doCheckbox(doc, 'Hepatitis?', data.pregnancy.historyHepatitis, x, y);
  y = doCheckbox(doc, 'Goiter?', data.pregnancy.historyGoiter, x, y);
  y = doCheckbox(doc, 'High blood pressure?', data.pregnancy.historyHighBloodPressure, x, y);
  y = doCheckbox(doc, 'Hospital operation?', data.pregnancy.historyHospitalOperation, x, y);
  y = doCheckbox(doc, 'Blood transfusion?', data.pregnancy.historyBloodTransfusion, x, y);
  y = doCheckbox(doc, 'Smoking?', data.pregnancy.historySmoking, x, y);
  y = doCheckbox(doc, 'Drinking?', data.pregnancy.historyDrinking, x, y);
  y = doCheckbox(doc, 'None of the above?', data.pregnancy.historyNone, x, y);

  // --------------------------------------------------------
  // Notes.
  // --------------------------------------------------------
  x = opts.margins.left;
  if (questionnaireNote.length > 0) {
    y = doVertFldVal(doc, 'Notes', questionnaireNote, x, y, true);
  }

  doc.moveDown(1);
  y = doc.y + 10;
  return y;
};

/* --------------------------------------------------------
 * doPregnancyHistory()
 *
 * Creates the historical pregnancy section from the midwife
 * interview.
 *
 * param      doc
 * param      data
 * param      opts
 * param      ypos
 * return     y - new y position
 * -------------------------------------------------------- */
var doPregnancyHistory = function(doc, data, opts, ypos) {
  var x = opts.margins.left
    , y = ypos
    , colNames = []
    , colData = []
    ;

  colNames.push('Date       ');
  colNames.push('GA      ');
  colNames.push('Sex');
  colNames.push('Location');
  colNames.push('Attendent');
  colNames.push('Delivery');
  colNames.push('Hours');
  colNames.push('Kg ');
  colNames.push('Epis');
  colNames.push('Repair');
  colNames.push('BreastFed');

  _.each(data.pregnancyHistories, function(row) {
    var data = [];
    if (row.month && row.day && row.year) {
      data.push(row.month + '-' + row.day + '-' + row.year);
    } else if (row.month && row.year) {
      data.push(row.month + '-' + row.year);
    } else if (row.year) {
      data.push(row.year);
    }
    if (row.FT) {
      data.push('FT');
    } else {
      data.push(row.finalGA + ' ' + row.finalGAPeriod);
    }
    data.push(row.sexOfBaby);
    data.push(row.placeOfBirth);
    data.push(row.attendant);
    data.push(row.typeOfDelivery);
    data.push(row.lengthOfLabor);
    data.push(row.birthWeight);
    data.push(row.episTear);
    data.push(row.repaired);
    data.push(row.howLongBFed + ' ' + row.howLongBFedPeriod);
    colData.push(data);
  });

  doLabel(doc, 'Pregnancy History', x, y);
  y += 10;
  y = doTable(doc, colNames, colData, opts, y);

};

/* --------------------------------------------------------
 * doTable()
 *
 * Write out a table across the full width of the page using
 * the columns passed. Assumes that the columns header tites
 * represent the width of the column. In other words, pad
 * columns with extra spaces should they need to be wider.
 *
 * param      columns - list of column names
 * param      opts
 * param      ypos
 * return     y - final y
 * -------------------------------------------------------- */
var doTable = function(doc, columns, rows, opts, ypos) {
  var x = opts.margins.left
    , y = ypos
    , pageWidth = opts.pageWidth - opts.margins.left - opts.margins.right
    , colWidth = {}
    , totalColWidth = 0
    ;

  doSep(doc, opts, y, greyLightColor);
  y += 5;

  // --------------------------------------------------------
  // Calculate the width of the columns names.
  // --------------------------------------------------------
  doc
    .font(FONTS.HelveticaBold)
    .fillColor(blackColor)
    .fontSize(10);
  _.each(columns, function(col) {
    var width = doc.widthOfString(col);
    colWidth[col] = width;
    totalColWidth += width;
  });

  // --------------------------------------------------------
  // Set the width of the columns.
  // --------------------------------------------------------
  _.each(columns, function(col) {
    colWidth[col] = colWidth[col] * (pageWidth/totalColWidth);
  });

  // --------------------------------------------------------
  // Write out the column headers.
  // --------------------------------------------------------
  _.each(columns, function(col) {
    doc.text(col, x, y);
    x += colWidth[col];
  });
  y += 12;
  doSep(doc, opts, y, greyLightColor);

  // --------------------------------------------------------
  // Write out the rows.
  // --------------------------------------------------------
  y += 10;
  doc
    .font(FONTS.Helvetica)
    .fontSize(9);
  x = opts.margins.left;
  _.each(rows, function(row) {
    _.each(row, function(fld, idx) {
      if (idx > 0) x += colWidth[columns[idx-1]];
      doc.text(fld, x, y);
    });
    x = opts.margins.left;
    y += 10;      // Move down a line.
    doSep(doc, opts, y, greyLightColor);
    y += 10;
  });

};


/* --------------------------------------------------------
 * doFooter()
 *
 * Write the footer for the report.
 *
 * param      doc
 * param      left
 * param      middle
 * param      right
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doFooter = function(doc, left, middle, right, opts) {
  var y = doc.page.height - opts.margins.bottom - 20
    , x1= opts.margins.left
    , x2
    , x3
    ;

  if (! left) left = '';
  if (! middle) middle = '';
  if (! right) right = '';

  doSep(doc, opts, y, greyLightColor);
  y += 5;

  // --------------------------------------------------------
  // Calculate horizontal positions.
  // --------------------------------------------------------
  doc
    .font(FONTS.Helvetica)
    .fontSize(9)
    .fillColor(blackColor);
  x2 = (doc.page.width/2) - (doc.widthOfString(middle)/2);
  x3 = doc.page.width - opts.margins.right - doc.widthOfString(right) - 2;

  // --------------------------------------------------------
  // Write out left, middle and right.
  // --------------------------------------------------------
  doc
    .text(left, x1, y)
    .text(middle, x2, y)
    .text(right, x3, y);
};

/* --------------------------------------------------------
 * doPage1()
 *
 * Write out the information for the first page.
 *
 * param      doc     - the document
 * param      data    - the data
 * param      opts    - options
 * return     undefined
 * -------------------------------------------------------- */
var doPage1 = function doPage1(doc, data, opts) {
  var y = 85
    ;
  doPageCommon(doc, data, opts);
  y = doClientGeneral(doc, data, opts, y);
  y = doNote(doc, data, opts, y);
  y = doQuestionnaire(doc, data, opts, y);
  y = doMidwifeInterview(doc, data, opts, y);
  y = doPregnancyHistory(doc, data, opts, y);
  doFooter(doc, 'Summary Report', 'Page 1', moment().format('MMM DD, YYYY h:mm a'), opts);
};

/* --------------------------------------------------------
 * doPages()
 *
 * Writes all the pages of the report.
 *
 * param      doc
 * param      data
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doPages = function(doc, data, opts) {
  var currentRow = 0
    , pageNum = 1
    ;

  doPage1(doc, data, opts);

};


/* --------------------------------------------------------
 * getData()
 *
 * Queries the database for the required information. Returns
 * a promise that resolves to an array of data.
 *
 * param      id
 * return     Promise
 * -------------------------------------------------------- */
var getData = function(id) {
  var data = {}
    ;
  return new Promise(function(resolve, reject) {
    Pregnancy.forge({id: id})
      // Pregnancy
      .fetch()
      .then(function(pregnancy) {
        data.pregnancy = pregnancy.toJSON();
      })
      // Patient
      .then(function() {
        return Patient.forge({id: data.pregnancy.patient_id})
          .fetch();
      })
      .then(function(patient) {
        data.patient = patient.toJSON();
      })
      // Vaccinations
      .then(function() {
        return new Vaccinations().query(function(qb) {
          qb.where('pregnancy_id', '=', data.pregnancy.id);
        })
        .fetch();
      })
      .then(function(vaccinations) {
        data.vaccinations = vaccinations.toJSON();
      })
      // Medications
      .then(function() {
        return new Medications().query(function(qb) {
          qb.where('pregnancy_id', '=', data.pregnancy.id);
        })
        .fetch();
      })
      .then(function(medications) {
        data.medications = medications.toJSON();
      })
      // PrenatalExams
      .then(function() {
        return new PrenatalExams().query(function(qb) {
          qb.where('pregnancy_id', '=', data.pregnancy.id);
        })
        .fetch();
      })
      .then(function(prenatalExams) {
        data.prenatalExams = prenatalExams.toJSON();
      })
      // PregnancyHistories
      .then(function() {
        return new PregnancyHistories().query(function(qb) {
          qb.where('pregnancy_id', '=', data.pregnancy.id);
        })
        .fetch();
      })
      .then(function(pregnancyHistories) {
        data.pregnancyHistories = pregnancyHistories.toJSON();
      })
      // Referrals
      .then(function() {
        return new Referrals().query(function(qb) {
          qb.where('pregnancy_id', '=', data.pregnancy.id);
        })
        .fetch();
      })
      .then(function(referrals) {
        data.referrals = referrals.toJSON();
      })
      // Risks
      .then(function() {
        return new Risks().query(function(qb) {
          qb.where('pregnancy_id', '=', data.pregnancy.id);
        })
        .fetch();
      })
      .then(function(risks) {
        data.risks = risks.toJSON();
      })
      // Lab Test Results
      .then(function() {
        return new LabTestResults().query(function(qb) {
          qb.where('pregnancy_id', '=', data.pregnancy.id);
        })
        .fetch();
      })
      .then(function(labTestResults) {
        data.labTestResults = labTestResults.toJSON();
      })
      // Return all of the data to the caller.
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
 * Create the summary report for the patient.
 *
 * param      id
 * param      writable
 * return     undefined
 * -------------------------------------------------------- */
var doReport = function doReport(id, writable) {
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
            Title: 'Summary Report: '
            , Author: 'Mercy Application'
            , Subject: 'Summary Report'
        }
      }
    , doc = new PDFDocument(options)
    , rowsPerPage = 33    // Number of rows per page of this report.
    , opts = {}
    ;

  opts.title = options.info.Title;
  opts.margins = options.margins;
  opts.pageWidth = doc.page.width;
  opts.pageHeight = doc.page.height;

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  getData(id)
    .then(function(data) {
      opts.title += data.pregnancy.lastname + ', ' + data.pregnancy.firstname;
      doPages(doc, data, opts);
    })
    .then(function() {
      doc.end();
    });
};

/* --------------------------------------------------------
 * run()
 *
 * Create the summary report for a patient.
 * -------------------------------------------------------- */
var run = function run(req, res) {
  var id = req.param('id')
    , filePath = path.join(cfg.site.tmpDir, 'rpt-' + (Math.random() * 9999999999) + '.pdf')
    , writable = fs.createWriteStream(filePath)
    , success = false
    , fieldsReady = true
    ;

  // --------------------------------------------------------
  // Check that required fields are in place.
  // --------------------------------------------------------
  if (! id) {
    fieldsReady = false;
    req.flash('error', req.gettext('The pregnancy id for the summary report was not specified.'));
  }
  if (! fieldsReady) {
    console.log('Summary report: not all fields supplied.');
    // TODO: better place to go than here?
    res.redirect(cfg.path.search);
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

  doReport(id, writable);
};

module.exports = {
  run: run
};

