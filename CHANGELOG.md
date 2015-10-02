# Change Log

## 0.6.0

*See docs/upgrades/0.6.x.md for upgrade instructions.*

- Upgraded the following dependencies to current.
   - Express
   - Express-device
   - Underscore
   - Moment
   - Bcrypt
   - Bookshelf
   - Knex
   - Recluster
   - Cheerio
   - Should
   - Validator
   - Consolidate
   - Jade
   - Nodecache
   - Mysql
   - Bluebird
   - Supertest
   - Passport
   - Angularjs
- Removed the following dependencies
   - Heapdump
- Retired Grunt and replaced with Gulp.
- Increased field sizes of many notes fields.
- Bug fixes
   - Fixed the display of various radio/checkboxes
   - Fixed date handling issues with Moment
   - Better handling of LMP in labs page and iron report
   - Fixed summary report to add pages if necessary
   - Fixed caching issues
   - Fixed some tests
   - Removed unnecessary references to validator
   - Fixed caching issues
   - Fixed some tests
   - Corrected references to validator
   - Shortened title on questionnaire page to fit better
   - Better table layouts on screens
   - Guard cannot see summary report and other pregnancy options
- New Features
   - Allow adding another pregnancy to a patient
   - Shows if a patient has more than one pregnancy
   - Allows easy switching between pregnancies of a patient
   - Textareas auto resize per field contents w/o scrolling


