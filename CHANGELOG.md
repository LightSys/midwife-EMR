# Change Log

## Phase2 branch

- Assumes that Redis is installed to allow efficient inter-process
  communication between node server processes. This is necessary
  to facilitate "push" to the clients.
- Upgraded bcrypt to current (assumes use of NodeJS 4.x).
- Installed Socket.io.
- Cluster workers now listen on different ports.
   - If more than one worker is used, requires a reverse proxy
     like Nginx that implements sticky sessions.

## 0.6.3

- Does not show inactive users in health teaching teacher selection.

## 0.6.2

*See docs/upgrades/0.6.2.md for upgrade instructions.*

- Replaces the session table with sessions as required by the
  express-mysql-sessions module.
   - This updates table creation script and drops the unused session table.
- Handle an occasional error due to uninitialized object while adding a pregnancy.
- Downgrade Bcrypt back to 0.7.8 because it would not compile on the ODroid.
- Remove Grunt dependencies.
- Adds an invoice worksheet for midwives to use.
- Shows EDD instead of LMP on drop down to switch between multiple pregnancies.

## 0.6.1

- Fixed gulpfile.js to properly process priorityList.js.

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
- Summary report only shows checked items in questionnaire section.
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

