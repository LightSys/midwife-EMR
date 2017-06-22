/*
 * -------------------------------------------------------------------------------
 * barcodes.js
 *
 * Generate prenatal priority barcodes.
 * -------------------------------------------------------------------------------
 */


var _ = require('underscore')
  , util = require('util')
  , vm = require('vm')
  , fs = require('fs')
  , path = require('path')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Bookshelf = require('bookshelf')
  , PDFDocument = require('pdfkit')
  , cfg = require('../config')
  , outputDir = 'static/barcodes'
  , outputFile = 'PrenatalBarcodes.pdf'
  , numPrenatalPriorityNumbers = 400
  , priorityEType = 5
  , minBarcode = 100000
  , maxBarcode = 999999
  ;


/* --------------------------------------------------------
 * generateBarcode()
 *
 * Generate a random number between minBarcode and maxBarcode
 * variables defined at the top of the program.
 * -------------------------------------------------------- */
var getRandomBarcode = function() {
  return Math.floor(Math.random() * (maxBarcode - minBarcode + 1) + minBarcode);
};

/* --------------------------------------------------------
 * getBarcodeData()
 *
 * Queries the database on the priority table for all records
 * of the specified event type. Returns an array of objects
 * to the caller via the callback. Objects will have these
 * fields:
 *
 *  barcode
 *  priority
 *
 * param       etype - the event type
 * param       cb - the callback
 * -------------------------------------------------------- */
var getBarcodeData = function(etype, cb) {
  var knex = Bookshelf.DB.knex
    , sql1
    , results = []
    ;

  sql1 = 'SELECT barcode, priority FROM priority WHERE etype = ? ORDER BY priority ASC';
  knex
    .raw(sql1, etype)
    .then(function(resp) {
      // Data we need is in the first element of array.
      return resp[0];
    })
    .then(function(data) {
      // Create and return a simple array of objects.
      _.each(data, function(row) {
        results.push({barcode: row.barcode, priority: row.priority});
      });
      return cb(null, results);
    });
};

/* --------------------------------------------------------
 * doAddRows()
 *
 * Add rows to the priority table of the specified event type
 * if needed in order to bring the total row count to the max
 * number of rows passed.
 *
 * param       maxRows
 * param       etype
 * param       cb
 * -------------------------------------------------------- */
var doAddRows = function(maxRows, etype, cb) {
  var knex = Bookshelf.DB.knex
    , numRows = 0
    , maxPriority
    , sql1
    , sql2
    ;

  // --------------------------------------------------------
  // Determine if we need to add any more rows.
  // --------------------------------------------------------
  sql1 = "SELECT COUNT(*) AS cnt FROM priority WHERE etype = ?";
  knex
    .raw(sql1, etype)
    .then(function(resp) {
      currNumRows = resp[0][0].cnt;

      sql2 = "SELECT MAX(priority) AS maxPriority FROM priority WHERE etype = ?";
      knex
        .raw(sql2, etype)
        .then(function(resp) {
          maxPriority = resp[0][0].maxPriority;

          if (currNumRows < numPrenatalPriorityNumbers) {
            // Need to add rows to the priority table and then regenerate the
            // PDF file of barcodes for the use to print if desired.

            // --------------------------------------------------------
            // Build an array of records to insert.
            // --------------------------------------------------------
            var numRowsToAdd = numPrenatalPriorityNumbers - currNumRows;
            var currPri = maxPriority + 1;
            var newRec = {
              eType: priorityEType
              , updatedBy: 1
              , updatedAt: moment().format('YYYY-MM-DD')
            };
            var newRecs = [];
            for (var i = 0; i < numRowsToAdd; i++) {
              newRecs.push({
                eType: priorityEType
                , updatedBy: 1
                , updatedAt: moment().format('YYYY-MM-DD')
                , barcode: getRandomBarcode()
                , priority: currPri++
              });
            }
              knex('priority')
                .insert(newRecs)
                .then(function(resp) {
                  return cb(null, numRowsToAdd);
                });
          } else {
            // Nothing to do.
            return cb(null, 0);
          }
        });
    });
};

/* --------------------------------------------------------
 * load()
 *
 * Adapted from node-bwipjs.js in the bwip-js project.
 *
 * param       path
 * -------------------------------------------------------- */
function load(filename) {
  var text
    ;
  try {
    text = fs.readFileSync(filename);
  } catch (e) {}
	if (!text) {
    // --------------------------------------------------------
    // If this is loading a barcode interface file, that file
    // will be located one directory farther down, so try
    // again.
    // --------------------------------------------------------
    if (path.basename(filename) === 'bwip.js') {
      filename = path.join('generateBarcodes/bwip-js', path.basename(filename));
    } else {
      filename = path.join('generateBarcodes/bwip-js/bwipp', path.basename(filename));
    }
    try {
      text = fs.readFileSync(filename);
    } catch (e) {}
    if (!text)
      // --------------------------------------------------------
      // Finally, try the fonts directory, which is one up.
      // --------------------------------------------------------
      filename = path.join('generateBarcodes/bwip-js/fonts', path.basename(filename));
      try {
        text = fs.readFileSync(filename);
      } catch (e) {}
      if (!text) throw new Error(filename + ": could not read file");
  }

	vm.runInThisContext(text, filename);
}

/* --------------------------------------------------------
 * generateImage()
 *
 * Generates an image file for the specified text.
 *
 * Callback returns the PNG image upon success.
 *
 * Processing here is adapted from the node-bwipjs.js
 * example in the bwip-js project.
 *
 * param      text - the barcode text, in the case a number
 * param      cb - the callback
 * -------------------------------------------------------- */
var generateImage = function(text, cb) {
  var bw
    , opts = {}
	  , scale = 1
    , rot = 'N'
    , bcid = 'interleaved2of5'
    , png
    ;

  // Make sure text is a string.
  text = '' + text;

  load('generateBarcodes/bwip.js');
  BWIPJS.load = load;
	bw = new BWIPJS;

	opts.inkspread = bw.value(0);
  opts.includetext = bw.value(true);
	bw.bitmap(new Bitmap);
	bw.scale(scale, scale);
	bw.push(text);
	bw.push(opts);
	bw.call(bcid);

	png = bw.bitmap().getPNG(rot);

  return cb(null, png);
};

/* --------------------------------------------------------
 * makePDF()
 *
 * Write a PDF file with all of the images embedded in it
 * for ease of printing, etc.
 *
 * Callback returns the filename of the PDF.
 *
 * TODO: add options to specify different paper sizes, etc.
 *
 * param       rows - object with barcode and priority
 * param       cb - the callback
 * -------------------------------------------------------- */
var makePDF = function(rows, cb) {
  var filename = path.join(outputDir, outputFile)
    , writable = fs.createWriteStream(filename)
    , options = {
        margins: {
          top: 18
          , right: 18
          , left: 18
          , bottom: 18
        }
        , layout: 'portrait'
        , size: 'A4'
        , info: {
            Title: 'Prenatal Barcodes'
            , Author: 'Midwife-EMR'
            , Subject: 'Prenatal Barcodes'
        }
      }
    , doc = new PDFDocument(options)
    , pageWidth = doc.page.width
    , pageHeight = doc.page.height
    , bcPerRow = 4
    , rowsPerPage = 4
    , imageWidth = (pageWidth - options.margins.right - options.margins.left)/bcPerRow
    , imageHeight = (pageHeight - options.margins.top - options.margins.bottom)/rowsPerPage
    , currRow = 0
    , xPos
    , yPos
    ;

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  writable.on('finish', function() {
    return cb(null, filename);
  });

  // For each page
  for (var x = 0; x < (rows.length / (bcPerRow * rowsPerPage)); x++) {
    // For each row
    for (var y = 0; y < rowsPerPage; y++) {
      // For each row
      for (var z = 0; z < bcPerRow; z++) {
        currRow = ((x*rowsPerPage*bcPerRow)+(y*bcPerRow)+z);
        if (currRow < rows.length) {
          xPos = options.margins.right + (z * imageWidth);
          yPos = options.margins.top + (y * imageHeight);
          makePDFImage(doc, rows[currRow], xPos, yPos, imageWidth, imageHeight);
        }
      }
    }
    if (currRow < rows.length) doc.addPage();
  }
  doc.end();
};

/* --------------------------------------------------------
 * makePDFImage()
 *
 * Write the image and some human-readable information to
 * the PDF such as priority number and a rectangle around
 * each image.
 *
 * param      dow
 * param      row
 * param      xPos
 * param      yPos
 * param      width
 * param      height
 * -------------------------------------------------------- */
var makePDFImage = function(doc, row, xPos, yPos, width, height) {
  var pri = ('00' + row.priority).slice(-3)
    , sep = '-'
    , image = Buffer.from(row.png, 'binary')
    ;

  // --------------------------------------------------------
  // The outer rectangle around the image and other data.
  // --------------------------------------------------------
  doc.rect(xPos, yPos, width, height);
  doc.stroke();

  // --------------------------------------------------------
  // The priority number for human reference.
  // --------------------------------------------------------
  doc
    .fontSize(16)
    .text('Priority: ' + row.priority, xPos + 10, yPos + 10);

  // --------------------------------------------------------
  // The image itself (semi-arbitrarily placed).
  // --------------------------------------------------------
  doc
    .image(image, xPos + width/3, yPos + height/3);
};

/* --------------------------------------------------------
 * generateBarcodes()
 *
 * Check for and generate priority barcodes as well as the
 * PDF file of those barcodes if necessary. Designed to be
 * called upon startup.
 *
 * Will only operate if the process.env.WORKER_ID == 0, i.e.
 * if this is the first child process starting in the cluster.
 * This is to prevent data races between processes trying to
 * do the same thing.
 * -------------------------------------------------------- */
var generateBarcodes = function() {
  if (process.env.WORKER_ID != 0) return;

  console.log('Prenatal barcodes: Checking priority table and for ' + outputFile + ".");
  doAddRows(numPrenatalPriorityNumbers, priorityEType, function(err, rowsAdded) {
    var outputFileExists = fs.existsSync(path.join(outputDir, outputFile));

    if (rowsAdded > 0 || ! outputFileExists) {
      if (rowsAdded > 0) {
        console.log("Prenatal barcodes: Added " + rowsAdded + " new rows to the priority table.");
      }
      console.log("Prenatal barcodes: Recreating " + path.join(outputDir, outputFile) + ".");

      // Need to regenerate the PDF so collect the data.
      getBarcodeData(priorityEType, function(err, data) {
        var dataArray = [];
        if (err) return err;

        // Generate images and populate dataArray with image data.
        _.each(data, function(row) {
          generateImage(row.barcode, function(err, png) {
            row.png = png;
            dataArray.push(row);
          });
        });

        // Generate a single PDF for printing all of the barcodes.
        makePDF(dataArray, function(err, filename) {
          if (err) {
            console.log('Prenatal barcodes: ' + err);
          } else {
            console.log("Prenatal barcodes: Wrote new prenatal barcodes PDF: " + filename);
          }
        });
      });
    }
  });
};

// ========================================================
// ========================================================
// The following was copied without change from node-bwipjs.js
// in the bwip-js project.
// ========================================================
// ========================================================
function Bitmap() {
	var _clr  = 0;					// currently active color
	var _clrs = {};					// color map
	var _nclr = 0;					// color count
	var _bits = [];					// the x,y,c bits
	var _minx = Infinity;
	var _miny = Infinity;
	var _maxx = 0;
	var _maxy = 0;

	this.color = function(r,g,b) {
		var rgb = (r<<16) | (g<<8) | b;
		if (!_clrs[rgb])
			_clrs[rgb] = { n:_nclr++ };
		_clr = rgb;
	}

	this.set = function(x, y, b) {
		// postscript graphics work with floating-pt numbers
		x = Math.floor(x);
		y = Math.floor(y);

		if (_minx > x) _minx = x;
		if (_maxx < x) _maxx = x;
		if (_miny > y) _miny = y;
		if (_maxy < y) _maxy = y;

		_bits.push([x,y,_clr]);
	}

	this.getPNG = function(rot) {
		// determine image width and height
		if (rot == 'R' || rot == 'L') {
			var h = _maxx-_minx+1;
			var w = _maxy-_miny+1;
		} else {
			var w = _maxx-_minx+1;
			var h = _maxy-_miny+1;
		}

		var png = new PNGlib(w, h, 256);

		// make sure the default color (index 0) is white
		png.color(255,255,255,255);

		// map the colors
		var cmap = [];
		for (rgb in _clrs)
			cmap[rgb] = png.color(rgb>>16, (rgb>>8)&0xff, (rgb&0xff), 255);

		for (var i = 0; i < _bits.length; i++) {
			// PostScript builds bottom-up, we build top-down.
			var x = _bits[i][0] - _minx;
			var y = _bits[i][1] - _miny;
			var c = cmap[_bits[i][2]];

			if (rot == 'N') {
				y = h - y - 1; 	// Invert y
			} else if (rot == 'I') {
				x = w - x - 1;	// Invert x
			} else {
				y = w - y; 		// Invert y
				if (rot == 'L') {
					var t = y;
					y = h - x - 1;
					x = t - 1;
				} else {
					var t = x;
					x = w - y;
					y = t;
				}
			}

			png.set(x, y, c);
		}

		return png.render();
	}
}

/**
* pnglib.js
* @version 1.0
* @author Robert Eisele <robert@xarg.org>
* @copyright Copyright (c) 2010, Robert Eisele
* @link http://www.xarg.org/2010/03/generate-client-side-png-files-using-javascript/
* @license http://www.opensource.org/licenses/bsd-license.php BSD License
*/
// Modified by MRW for use with bwip-js.
function PNGlib(width,height,depth) {

	// helper functions for that ctx
	function write(buffer, offs) {
		for (var i = 2; i < arguments.length; i++) {
			for (var j = 0; j < arguments[i].length; j++) {
				buffer[offs++] = arguments[i].charAt(j);
			}
		}
	}

	function byte2(w) {
		return String.fromCharCode((w >> 8) & 255, w & 255);
	}

	function byte4(w) {
		return String.fromCharCode((w >> 24) & 255, (w >> 16) & 255, (w >> 8) & 255, w & 255);
	}

	function byte2lsb(w) {
		return String.fromCharCode(w & 255, (w >> 8) & 255);
	}

	this.width   = width;
	this.height  = height;
	this.depth   = depth;

	// pixel data and row filter identifier size
	this.pix_size = height * (width + 1);

	// deflate header, pix_size, block headers, adler32 checksum
	this.data_size = 2 + this.pix_size +
					5 * Math.floor((0xfffe + this.pix_size) / 0xffff) + 4;

	// offsets and sizes of Png chunks
	this.ihdr_offs = 0;
	this.ihdr_size = 4 + 4 + 13 + 4;
	this.plte_offs = this.ihdr_offs + this.ihdr_size;
	this.plte_size = 4 + 4 + 3 * depth + 4;
	this.trns_offs = this.plte_offs + this.plte_size;
	this.trns_size = 4 + 4 + depth + 4;
	this.idat_offs = this.trns_offs + this.trns_size;
	this.idat_size = 4 + 4 + this.data_size + 4;
	this.iend_offs = this.idat_offs + this.idat_size;
	this.iend_size = 4 + 4 + 4;
	this.buffer_size  = this.iend_offs + this.iend_size;

	this.buffer  = new Array();
	this.palette = new Object();
	this.pindex  = 0;

	var _crc32 = new Array();

	// initialize buffer with zero bytes
	for (var i = 0; i < this.buffer_size; i++) {
		this.buffer[i] = "\x00";
	}

	// initialize non-zero elements
	write(this.buffer, this.ihdr_offs, byte4(this.ihdr_size - 12), 'IHDR',
					byte4(width), byte4(height), "\x08\x03");
	write(this.buffer, this.plte_offs, byte4(this.plte_size - 12), 'PLTE');
	write(this.buffer, this.trns_offs, byte4(this.trns_size - 12), 'tRNS');
	write(this.buffer, this.idat_offs, byte4(this.idat_size - 12), 'IDAT');
	write(this.buffer, this.iend_offs, byte4(this.iend_size - 12), 'IEND');

	// initialize deflate header
	var header = ((8 + (7 << 4)) << 8) | (3 << 6);
	header+= 31 - (header % 31);

	write(this.buffer, this.idat_offs + 8, byte2(header));

	// initialize deflate block headers
	for (var i = 0; (i << 16) - 1 < this.pix_size; i++) {
		var size, bits;
		if (i + 0xffff < this.pix_size) {
			size = 0xffff;
			bits = "\x00";
		} else {
			size = this.pix_size - (i << 16) - i;
			bits = "\x01";
		}
		write(this.buffer, this.idat_offs + 8 + 2 + (i << 16) + (i << 2),
					bits, byte2lsb(size), byte2lsb(~size));
	}

	/* Create crc32 lookup table */
	for (var i = 0; i < 256; i++) {
		var c = i;
		for (var j = 0; j < 8; j++) {
			if (c & 1) {
				c = -306674912 ^ ((c >> 1) & 0x7fffffff);
			} else {
				c = (c >> 1) & 0x7fffffff;
			}
		}
		_crc32[i] = c;
	}

	// used internally
	this.index = function(x,y) {
		var i = y * (this.width + 1) + x + 1;
		var j = this.idat_offs + 8+2+5 * Math.floor((i / 0xffff) + 1)+i;
		return j;
	}

	// set a pixel to the given color
	this.set = function(x,y,c) {
		var i = y * (this.width + 1) + x + 1;
		var j = this.idat_offs + 8+2+5 * Math.floor((i / 0xffff) + 1)+i;
		this.buffer[j] = c;
	}

	// convert a color and build up the palette
	this.color = function(red, green, blue, alpha) {

		alpha = alpha >= 0 ? alpha : 255;
		var color = (((((alpha << 8) | red) << 8) | green) << 8) | blue;

		if (typeof this.palette[color] == "undefined") {
			if (this.pindex == this.depth) return "\x00";

			var ndx = this.plte_offs + 8 + 3 * this.pindex;

			this.buffer[ndx + 0] = String.fromCharCode(red);
			this.buffer[ndx + 1] = String.fromCharCode(green);
			this.buffer[ndx + 2] = String.fromCharCode(blue);
			this.buffer[this.trns_offs+8+this.pindex] =
											String.fromCharCode(alpha);

			this.palette[color] = String.fromCharCode(this.pindex++);
		}
		return this.palette[color];
	}

	// output a PNG string
	this.render = function() {

		// compute adler32 of output pixels + row filter bytes
		// NMAX is the largest n such that 255n(n+1)/2 + (n+1)(BASE-1) <=
		// 2^32-1.
		var BASE = 65521; /* largest prime smaller than 65536 */
		var NMAX = 5552;
		var s1 = 1;
		var s2 = 0;
		var n = NMAX;

		for (var y = 0; y < this.height; y++) {
			for (var x = -1; x < this.width; x++) {
				s1+= this.buffer[this.index(x, y)].charCodeAt(0);
				s2+= s1;
				if ((n-= 1) == 0) {
					s1%= BASE;
					s2%= BASE;
					n = NMAX;
				}
			}
		}
		s1%= BASE;
		s2%= BASE;
		write(this.buffer, this.idat_offs + this.idat_size - 8,
				byte4((s2 << 16) | s1));

		// compute crc32 of the PNG chunks
		function crc32(png, offs, size) {
			var crc = -1;
			for (var i = 4; i < size-4; i += 1) {
				crc = _crc32[(crc ^ png[offs+i].charCodeAt(0)) & 0xff] ^ ((crc >> 8) & 0x00ffffff);
			}
			write(png, offs+size-4, byte4(crc ^ -1));
		}

		crc32(this.buffer, this.ihdr_offs, this.ihdr_size);
		crc32(this.buffer, this.plte_offs, this.plte_size);
		crc32(this.buffer, this.trns_offs, this.trns_size);
		crc32(this.buffer, this.idat_offs, this.idat_size);
		crc32(this.buffer, this.iend_offs, this.iend_size);

		// convert PNG to string
		return "\211PNG\r\n\032\n"+this.buffer.join('');
	}
}

module.exports = {
  generateBarcodes
};
