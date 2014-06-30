/*
 * -------------------------------------------------------------------------------
 * generate_barcodes.js
 *
 * This is a stand-alone Nodejs script (not a part of the web application) that is
 * used to populate the priority table with priority numbers and their corresponding
 * Interleaved 2 of 5 (ITF) barcode numbers. It also generates the barcode images
 * for printing so that they can be attached to priority tags.
 *
 * The program is meant to be run from the command line and it takes a number of
 * parameters.
 *
 *  --numRecs         the number of priority records to generate up to
 *  --host            the database host
 *  --port            the database port
 *  --database        the database name
 *  --user            the database user
 *  --outputDir       the output directory where image files will be written
 *  --eTypeId         the priority type id to generate records for.
 *
 * All parameters are required except for host which defaults to 'localhost' and
 * port which defaults to 3306. The program will prompt the user for the database
 * password.
 *
 * Example usage:
 *  node generate_barcodes.js --numRecs 100 --host localhost --port 3306 \
 *  --database mercy1 --user mercy1user --outputDir ~/barcodesDir --eTypeId 5
 *
 * The directory specified in the outputDir parameter is where the barcode image
 * files will be written so that they can be easily printed. Each barcode will
 * be written as a separate PNG file. Each image file will be named in
 * x-yyy-zzzzzz.png format where x is the event type id, yy is the priority
 * number, and zzzzzz is the barcode number.
 *
 * In addition and as a convenience for the user, the program will also generate
 * a PDF document that includes all of the images within it so that the barcodes
 * can be printed and attached to badges, etc. No attempt was made to adhere to
 * a specific label stock template though. Each PDF is generated in a file with
 * a date/time stamp so that subsequent runs of the program do not overwrite the
 * prior PDF documents.
 *
 * The program will not overwrite priority records that already exist. For example,
 * if there already are 50 eType 5 records in the priority table and the program
 * is run with numRecs set to 100, the program will add another 50 records to the
 * table with an eType set to 5. It will then populate the barcode field with a
 * random number between 100,000 and 999,999 inclusive for the records in the
 * table that already do not have the barcode field populated. In other words, it
 * will not overwrite the barcode field if it already has content in it.
 * -------------------------------------------------------------------------------
 */

var program = require('commander')
  , mysql = require('mysql')
  , readline = require('readline')
  , fs = require('fs')
  , path = require('path')
  , url = require('url')
  , vm = require('vm')
  , _ = require('underscore')
  , PDFDocument = require('pdfkit')
  , moment = require('moment')
  , VERSION = '0.0.1'
  , dbPass
  , rl
  , dbConn
  , minBarcode = 100000
  , maxBarcode = 999999
  ;

program
  .version(VERSION)
  .option('-n, --numRecs <n>', 'number of priority records to generate up to', 0)
  .option('-h, --host <host>', 'the host the database is located in', 'localhost')
  .option('-p, --port <n>', 'the database port', 3306)
  .option('-d, --database <database>', 'the database name')
  .option('-u, --user <user>', 'the database user')
  .option('-o, --outputDir <dir>', 'the output directory where image files will be written')
  .option('-e, --eTypeId <n>', 'the priority type id to generate records for')
  .parse(process.argv);

/* --------------------------------------------------------
 * usage()
 *
 * Display help and exit.
 * -------------------------------------------------------- */
var usage = function() {
  program.help();
};

/* --------------------------------------------------------
 * error()
 *
 * Display error message to the console.
 * -------------------------------------------------------- */
var error = function(msg) {
  console.error('==========================================');
  console.error(msg);
  console.error('==========================================');
};

/* --------------------------------------------------------
 * errorDie()
 *
 * Display error message and exit the program.
 * -------------------------------------------------------- */
var errorDie = function(msg) {
  error(msg);
  process.exit(1);
};

/* --------------------------------------------------------
 * dbConnect()
 *
 * Connect to the database. Callback returns true upon
 * success, false otherwise.
 *
 * param      callback
 * -------------------------------------------------------- */
var dbConnect = function(cb) {
  dbConn = mysql.createConnection({
    host: program.host
    , user: program.user
    , password: dbPass
    , port: program.port
    , database: program.database
  });

  dbConn.on('error', function(err) {
    errorDie(err);
  });

  dbConn.connect(function(err) {
    if (err) {
      error(err);
      return cb(false);
    }
    return cb(true);
  });
};

/* --------------------------------------------------------
 * generateBarcode()
 *
 * Generate a random number between minBarcode and maxBarcode
 * variables defined at the top of the program.
 * -------------------------------------------------------- */
var generateBarcode = function() {
  return Math.floor(Math.random() * (maxBarcode - minBarcode + 1) + minBarcode);
};

/* --------------------------------------------------------
 * addRows()
 *
 * Add rows to the database populating the eType, priority,
 * barcode, updatedBy, and updatedAt fields.
 *
 * Callback returns the number of rows added.
 *
 * param      err
 * param      cb - the callback which returns number of rows added
 * -------------------------------------------------------- */
var addRows = function(cb) {
  dbConnect(function(success) {
    var cntQry
      , maxQry
      , insertQry
      , currRows
      , maxPriority
      ;
    if (! success) errorDie('Connection failure');

    // --------------------------------------------------------
    // Determine the number of rows for this event type now.
    // --------------------------------------------------------
    cntQry = dbConn.query('SELECT COUNT(*) AS cnt FROM priority WHERE eType = ?'
      , [program.eTypeId]);

    cntQry
      .on('error', function(err) {error(err); process.exit(1);})
      .on('result', function(row) {
        currRows = row.cnt;
      })
      .on('end', function() {console.log('Count query is done.');});


    // --------------------------------------------------------
    // Determine the next priority number to use for this event type.
    // --------------------------------------------------------
    maxQry = dbConn.query('SELECT MAX(priority) AS maxPriority FROM priority WHERE eType = ?'
        , [program.eTypeId]);
    maxQry
      .on('error', function(err) {errorDie(err);})
      .on('result', function(row) {
        maxPriority = row.maxPriority;
      })
      .on('end', function() {
        var numRows
          , currPri
          , newRec = {
              eType: program.eTypeId
              , updatedBy: 1
              , updatedAt: moment().format('YYYY-MM-DD')
            }
          , rowsAdded = 0
          ;
        console.log('Max query is done.');
        if (currRows < program.numRecs) {
          // --------------------------------------------------------
          // Add rows to the priority table.
          // --------------------------------------------------------
          numRows = program.numRecs - currRows;
          currPri = maxPriority + 1;
          console.log(numRows + ' rows need to be created starting with priority number ' + currPri + '.');

          for (var i = 0; i < numRows; i++) {
            newRec.barcode = generateBarcode();
            newRec.priority = currPri++;
            insertQry = dbConn.query('INSERT INTO priority SET ?', newRec);
            insertQry
              .on('error', function(err) {errorDie(err);})
              .on('result', function(row) {
                rowsAdded += row.affectedRows;
              })
              .on('end', function() {
                if (rowsAdded === numRows) {
                  console.log('Finished inserting new rows.');
                  return cb(null, rowsAdded);
                }
              });
          }
        } else {
          console.log('No new records need to be created.');
          return cb(null, 0);
        }
      });
  });
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
 * Note: assumes that the dbConn database object is already
 * initialized.
 *
 * param       cb - the callback
 * -------------------------------------------------------- */
var getBarcodeData = function(cb) {
  var allQry
    , results = []
    ;
  // --------------------------------------------------------
  // Get all records for event in priority number order.
  // --------------------------------------------------------
  allQry = dbConn.query('SELECT barcode, priority FROM priority WHERE eType = ? ORDER BY priority ASC', [program.eTypeId]);

  allQry
    .on('error', function(err) {error(err); process.exit(1);})
    .on('result', function(row) {
      results.push(row);
    })
    .on('end', function() {
      return cb(null, results);
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
    filename = path.join('bwip-js', filename);
    text = fs.readFileSync(filename);
    if (!text)
      throw new Error(filename + ": could not read file");
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
 * example in the bwip-js project. See README.md for details.
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

  load('./bwip.js');
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
 * getImageFilename()
 *
 * Returns the filename to use for the image based upon the
 * barcode, event type, and priority number.
 *
 * param      barcode
 * param      priority
 * return     filename
 * -------------------------------------------------------- */
getImageFilename = function(barcode, priority) {
  var pri = ('00' + priority).slice(-3)
    , sep = '-'
    , imagePath
    ;
  imagePath = path.join(program.outputDir, program.eTypeId + sep + pri + sep + barcode + '.png');
  return imagePath;
};

/* --------------------------------------------------------
 * saveImage()
 *
 * Saves the image passed to the file as specified by the
 * outputDir, the barcode, the event type, and priority number.
 *
 * File is saved in the output directory in this format:
 *
 *  x-yyy-zzzzzz.png
 *
 *  where x is the event type, y is the priority, and
 *  zzzzzz is the barcode.
 *
 * param      barcode
 * param      priority
 * param      png - the image data
 * -------------------------------------------------------- */
var saveImage = function(barcode, priority, png) {
  var fullpath
    ;
  fullpath = getImageFilename(barcode, priority);
  try {
    fs.writeFileSync(fullpath, png, {encoding: 'binary'});
  } catch (err) {
    errorDir(err);
  }
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
  var filename = path.join(program.outputDir, 'Barcodes-' + moment().format('YYYY-MM-DD_HHmmss') + '.pdf')
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
            Title: 'Barcodes'
            , Author: 'Mercy Application'
            , Subject: 'Barcodes'
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
    , image = getImageFilename(row.barcode, row.priority);
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
 * main()
 *
 * Start the main process that manages generating the image
 * files, etc.
 * -------------------------------------------------------- */
var main = function() {
  // --------------------------------------------------------
  // Increase the number of rows in the priority table if
  // necessary.
  // --------------------------------------------------------
  addRows(function(err, rowsAdded) {
    if (err) errorDie(err);

    // --------------------------------------------------------
    // Generate images in the output directory for the barcodes
    // in the priority table. This generates images for all of
    // the priority table records for the given eType, not just
    // the records that needed to be added to reach the specified
    // numRecs value.
    // --------------------------------------------------------
    getBarcodeData(function(err, rows) {
      var cnt = 0
        ;
      dbConn.end();
      _.each(rows, function(row) {
        generateImage(row.barcode, function(err, png) {
          if (err) errorDie(err);
          if (png) {
            saveImage(row.barcode, row.priority, png);
            cnt++;
          } else {
            console.log('WARNING: image was not generated for priority number ' + row.priority);
          }
        });
      });
      console.log('Wrote ' + cnt + ' image files.');

      // --------------------------------------------------------
      // Create a summary PDF document with all of the images
      // embedded in it so that it can easily be printed, etc.
      // --------------------------------------------------------
      makePDF(rows, function(err, filename) {
        console.log('PDF image file generated: ' + filename);
        process.exit(0);
      });
    });
  });
};

// --------------------------------------------------------
// Check for sane parameters.
// --------------------------------------------------------
if (program.numRecs === 0) usage();
if (! program.database) usage();
if (! program.user) usage();
if (! program.outputDir) usage();
if (! program.eTypeId) usage();

// --------------------------------------------------------
// Confirm that the output directory exists.
// --------------------------------------------------------
if (! fs.statSync(program.outputDir).isDirectory()) {
  error('--ouputDir must reference a directory that exists.');
  usage();
}

// --------------------------------------------------------
// Get the password from the user for the database.
// --------------------------------------------------------
rl = readline.createInterface({input: process.stdin, output: process.stdout});
rl.question('Enter the database password: ', function(password) {
  dbPass = password;
  rl.close();
});
rl.on('close', function() {
  main();
});

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


