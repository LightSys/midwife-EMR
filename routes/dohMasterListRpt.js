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
  return new Promise(function(resolve, reject) {

    // STUB
    var list = [{id: 1, firstname: 'Test', lastname: 'Record'}];
    return resolve(list);

  });
};

/* --------------------------------------------------------
 * doRowPage1()
 *
 * Writes a row on the report including borders and text.
 *
 * param      doc
 * param      data
 * param      rowNum
 * param      rowHeight
 * return     undefined
 * -------------------------------------------------------- */
var doRowPage1 = function(doc, data, rowNum, rowHeight) {
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
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
  y = yBottom - 15;
  doc.text(texts[2], centerX - (widths[2]/2), y);
};


/* --------------------------------------------------------
 * doRowsGridPage1()
 *
 * Write out the lines for the rows on page one without the
 * data.
 *
 * param      doc
 * param      opts
 * return     undefined
 * -------------------------------------------------------- */
var doRowsGridPage1 = function(doc, opts) {
  var xLeft = opts.margins.left
    , xRight = doc.page.width - opts.margins.right
    , yTop = opts.margins.top + 22 + 90
    , rowHeight = 45
    , colPos = getColXposPage1(opts)
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
  _.each(colPos, function(x) {
    doc
      .moveTo(x, yTop)
      .lineTo(x, yTop + (rowHeight * numRows))
      .stroke();
  });
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
    , totalPages = Math.ceil(data.length / rowsPerPage) * 2
    ;


  // --------------------------------------------------------
  // Do each row, adding pages as necessary.
  // --------------------------------------------------------
  _.each(data, function(rec) {
    if (currentRow === 0) {
      doHeaderPage1(doc, opts);
      doFooterPage1(doc, opts);
      doColHeaderPage1(doc, opts);
      doRowsGridPage1(doc, opts);
    }
    //if (currentRow >= rowsPerPage) {
      //doc.addPage();
      //currentRow = 0;
      //pageNum++;
    //}

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
  opts.logisticsName = logisticsName;
  opts.title = options.info.Title;
  opts.margins = options.margins;

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

      // ???

      doPages(doc, list, rowsPerPage, opts);
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



