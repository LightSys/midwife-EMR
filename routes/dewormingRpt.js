/*
 * -------------------------------------------------------------------------------
 * dewormingRpt.js
 *
 * Required report for health statistics regarding deworming.
 * -------------------------------------------------------------------------------
 */


var _ = require('underscore')
  , moment = require('moment')
  , PDFDocument = require('pdfkit')
  , fs = require('fs')
  , os = require('os')
  , path = require('path')
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , FONTS = require('./reportGeneral').FONTS
  ;


/* --------------------------------------------------------
 * centerText()
 *
 * Writes the specified text centered according to the
 * specified font and fontSize on the specified y coordinate.
 *
 * param      doc
 * param      text
 * param      font
 * param      fontSize
 * param      y
 * return     undefined 
 * -------------------------------------------------------- */
var centerText = function(doc, text, font, fontSize, y) {
  var textWidth
    , xpos
    ;
  doc.font(font);
  doc.fontSize(fontSize);
  textWidth = parseInt(doc.widthOfString(text), 10);
  xpos = Math.round((doc.page.width/2) - (textWidth/2));
  doc.text(text, xpos, y);
};

/* --------------------------------------------------------
 * doSiteTitle()
 *
 * Writes the site title at the y coordinate specified.
 *
 * param       doc
 * param       y
 * return      undefined
 * -------------------------------------------------------- */
var doSiteTitle = function(doc, y) {
  // TODO: put font and fontSize in a config file.
  centerText(doc, cfg.site.title, FONTS.Helvetica, 18, y);
};

/* --------------------------------------------------------
 * doReportName()
 *
 * Writes the report name at the specified y coordinate.
 *
 * param      doc
 * param      text
 * param      y
 * return     undefined
 * -------------------------------------------------------- */
var doReportName = function(doc, text, y) {
  // TODO: put font and fontSize in a config file.
  centerText(doc, text, FONTS.Helvetica, 20, y);
};

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
    .moveTo(x + 180, y)
    .lineTo(x + 180, y + height)
    .moveTo(x + 205, y)
    .lineTo(x + 205, y + height)
    .moveTo(x + 261, y)
    .lineTo(x + 261, y + height)
    .moveTo(x + 293, y)
    .lineTo(x + 293, y + height)
    .moveTo(x + 410, y)
    .lineTo(x + 410, y + height)
    .stroke();

  // Headings
  doc
    .font(FONTS.HelveticaBold)
    .fontSize(12)
    .text('Name', x + 72, y + 10)
    .text('Last', x + 36, y + 25)
    .text('First', x + 108, y + 25)
    .text('Age', x + 181, y + 10)
    .text('LMP', x + 220, y + 10)
    .text('GP', x + 268, y + 10)
    .text('Address', x + 326, y + 10)
    .text('Deworming', x + 461, y + 10)
    .text('Date/Type', x + 416, y + 25)
    .text('Remarks', x + 515, y + 25)
    ;
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
        , layout: 'portrait'
        , size: 'letter'
        , info: {
            Title: 'Deworming Report'
            , Author: 'Mercy Application'
            , Subject: 'Deworming Report'
        }
      }
    , doc = new PDFDocument(options)
    ;

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  // Build the parts of the document.
  doSiteTitle(doc, 24);
  doReportName(doc, 'DEWORMING', 48);
  doColumnHeader(doc);
  doc.end();
};

/* --------------------------------------------------------
 * run()
 *
 * Run the deworming report.
 * -------------------------------------------------------- */
var run = function(req, res) {
  var flds = _.omit(req.body, ['_csrf'])
    , filePath = path.join(cfg.site.tmpDir, 'rpt-' + (Math.random() * 9999999999) + '.pdf')
    , writable = fs.createWriteStream(filePath)
    , success = false
    ;

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



