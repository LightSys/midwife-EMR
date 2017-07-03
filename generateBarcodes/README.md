# Generate Barcodes

**Note: this program is superceded by the routes/barcodes.js module that has
been incorporated directly into Midwife-EMR.**

Barcodes are used in conjunction with the priority system to insure that the
priority numbers input into the system upon client arrival are accurate. Using
barcodes insures that by accepting as input the barcodes, which are random 6
digit numbers, as opposed to the priority numbers themselves. The barcodes are
tied to the priority numbers that they represent by the priority table.

The ```generate_barcodes.js``` script can be used to populate the priority
table with records as well as generate the barcode images as PNG files which
can be printed and applied to tags or badges, etc.

## Usage

The program is meant to be run from the command line and it takes a number of
parameters.

    --numRecs         the number of priority records to generate up to
    --host            the database host
    --port            the database port
    --database        the database name
    --user            the database user
    --outputDir       the output directory where image files will be written
    --eTypeId         the priority type id to generate records for.

All parameters are required except for host which defaults to 'localhost' and
port which defaults to 3306. The program will prompt the user for the database
password.

Example usage:

    node generate_barcodes.js --numRecs 100 --host localhost --port 3306 \
    --database mercy1 --user mercy1user --outputDir ~/barcodesDir --eTypeId 5

## Program logic

The directory specified in the outputDir parameter is where the barcode image
files will be written so that they can be easily printed. Each barcode will be
written as a separate PNG file. Each image file will be named in
x-yyy-zzzzzz.png format where x is the event type id, yy is the priority
number, and zzzzzz is the barcode number.

In addition and as a convenience for the user, the program will also generate
a PDF document that includes all of the images within it so that the barcodes
can be printed and attached to badges, etc. No attempt was made to adhere to a
specific label stock template though. Each PDF is generated in a file with a
date/time stamp so that subsequent runs of the program do not overwrite the
prior PDF documents.

The program will not overwrite priority records that already exist. For
example, if there already are 50 eType 5 records in the priority table and the
program is run with numRecs set to 100, the program will add another 50
records to the table with an eType set to 5. It will then populate the barcode
field with a random number between 100,000 and 999,999 inclusive for the
records in the table that already do not have the barcode field populated. In
other words, it will not overwrite the barcode field if it already has content
in it.

## Third-party Libs

The ```generate_barcodes.js``` script uses the [Barcode Writer in Pure
Javascript](https://code.google.com/p/bwip-js/) library to generate the images
themselves. A copy of this excellent library in included in the ```bwip-js```
subdirectory for convenience and because it is the version of the library that
```generate_barcodes.js``` has been tested against, which is currently
```0.5```.


