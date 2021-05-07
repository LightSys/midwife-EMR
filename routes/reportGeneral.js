var _ = moment = require('moment')
  ;

/* 
 * -------------------------------------------------------------------------------
 * reportGeneral.js
 *
 * Common definitions for the reports.
 * ------------------------------------------------------------------------------- 
 */

var cfg = require('../config')
  , fontAwesomeFile = 'static/font-awesome/fonts/fontawesome-webfont.ttf'
  ;


/* --------------------------------------------------------
 * generateReportFilename()
 *
 * Returns a filename to use that has the prefix plus the
 * current date/time plus the extension.
 *
 * param       prefix
 * param       ext - without the period
 * return      string - the filename
 * -------------------------------------------------------- */
var generateReportFilename = function(prefix, ext) {
  var current = moment().format('YYYY-MM-DD_HHmm');

  return prefix + '_' + current + '.' + ext;
};



/* --------------------------------------------------------
 * clipToFit()
 *
 * Clip the specified text until it fits into the width
 * specified, return the text that fits.
 *
 * param       doc
 * param       text
 * param       width - in points
 * return      undefined
 * -------------------------------------------------------- */
var clipToFit = function(doc, text, width) {
  var str = text;
  while (doc.widthOfString(str) > width) {
    str = str.substring(0, str.length -1);
  }
  return str;
};

/* --------------------------------------------------------
 * calcNumLines()
 *
 * Return the number of lines necessary to write the given
 * text in full.
 *
 * param       doc
 * param       text
 * param       width - in points
 * return      int
 * -------------------------------------------------------- */
var calcNumLines = function(doc, text, width) {
  if (_.isNull(text) || text.length === 0) return 0;
  return Math.ceil(doc.widthOfString(text) / width);
};

/* --------------------------------------------------------
 * splitLine()
 *
 * Return an array of strings which represents the lines to
 * print within the given width.
 *
 * param       doc
 * param       text
 * param       width - in points
 * return      array of string
 * -------------------------------------------------------- */
var splitLine = function(doc, text, width) {
  var lines = []
    , numLines = calcNumLines(doc, text, width)
    , tmpStr = text
    ;

  for (let i = 0; i < numLines; i++) {
    lines.push(clipToFit(doc, tmpStr, width));
    tmpStr = text.slice(lines.join('').length);
  }

  return lines;
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
 * colClipped()
 *
 * Writes the specified text within the column boundaries
 * passed while clipping it if it is too long to fit. Assumes
 * that font and fontSize have already been set.
 *
 * param      doc
 * param      str
 * param      colLeft
 * param      colRight
 * param      y
 * return     undefined
 * -------------------------------------------------------- */
var colClipped = function(doc, str, colLeft, colRight, y) {
  var width = colRight - colLeft
    , tmpStr = clipToFit(doc, '' + str, width)
    ;
  doc.text(tmpStr, colLeft, y);
};

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
  var siteTitle = cfg.getKeyValue('siteShortName');
  centerText(doc, siteTitle, FONTS.Helvetica, 18, y);
};

/* --------------------------------------------------------
 * doSiteTitleLong()
 *
 * Writes the site title at the y coordinate specified using
 * siteLongName instead of siteShortName.
 *
 * param       doc
 * param       y
 * return      undefined
 * -------------------------------------------------------- */
var doSiteTitleLong = function(doc, y) {
  var siteTitle = cfg.getKeyValue('siteLongName');
  centerText(doc, siteTitle, FONTS.Helvetica, 18, y);
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
  centerText(doc, text, FONTS.Helvetica, 20, y);
};

/* --------------------------------------------------------
 * doCellBorders()
 *
 * Write a single cell's border on the page.
 *
 * param      doc
 * param      x
 * param      y
 * param      width
 * param      height
 * return     undefined
 * -------------------------------------------------------- */
var doCellBorders = function(doc, x, y, width, height) {
  doc
    .moveTo(x, y)
    .lineTo(x + width, y)
    .lineTo(x + width, y + height)
    .lineTo(x, y + height)
    .lineTo(x, y)
    .stroke();
};



// --------------------------------------------------------
// 14 Standard fonts that all PDF documents can render.
// --------------------------------------------------------
var FONTS = {
  Courier: 'Courier'
  , CourierBold: 'Courier-Bold'
  , CourierObliqu: 'Courier-Oblique'
  , CourierBoldOblique: 'Courier-BoldOblique'
  , Helvetica: 'Helvetica'
  , HelveticaBold: 'Helvetica-Bold'
  , HelveticaOblique: 'Helvetica-Oblique'
  , HelveticaBoldOblique: 'Helvetica-BoldOblique'
  , TimesRoman: 'Times-Roman'
  , TimesBold: 'Times-Bold'
  , TimesItalic: 'Times-Italic'
  , TimesBoldItalic: 'Times-BoldItalic'
  , Symbol: 'Symbol'
  , ZapfDingbats: 'ZapfDingbats'
  , FontAwesome: fontAwesomeFile
};


module.exports = {
  FONTS: FONTS
  , centerText: centerText
  , centerInCol: centerInCol
  , colClipped: colClipped
  , doSiteTitle: doSiteTitle
  , doSiteTitleLong: doSiteTitleLong
  , doReportName: doReportName
  , doCellBorders: doCellBorders
  , calcNumLines: calcNumLines
  , splitLine: splitLine
  , generateReportFilename: generateReportFilename
};



