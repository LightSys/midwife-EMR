# Change Log

## 0 9.0

- Labor, Delivery and Postpartum care
   - Elm client for medical roles for labor, delivery, postpartum
- Uses Docker for build of Elm medical client.

## 0.8.2

- Refactored build of Elm admin client to use Docker.
- Retired the React admin client and enabled Elm admin client by default.
- Uses shmig for database migrations.
- Allows configuration settings via Elm admin client to affect the server.
- Cleaned up NPM settings and scripts.
- Pinned Angular to 1.5.8 for history viewing.
- Numerous bug fixes.

## 0.8.1

- No user visible changes.

## 0.8.0

- Uses Elm on the client for the administrator role, but not as default.
  - React administrator role is no longer used.
  - React guard role could be used if user comment field starts with PHASE2REACT.
  - Admin user with comment field starting with PHASE2ELM will activate Elm client.

## 0.7.0

- Assumes use of Node 6.x line.
- Upgraded many third-party packages to current or near current.
- Installed Socket.io for use with experimental client (see below).
- Cluster workers now listen on different ports.
   - If more than one worker is used, requires a reverse proxy
     like Nginx that implements sticky sessions.
- Exposes an experimental React/Redux client that uses Socket.io.
   - Users that start their comment field in the user record with 'PHASE2' will
     be able to use the new client in the administrator, guard, or supervisor
     roles. The supervisor role implementation is far from complete.
- Experimental support for SQLite3 as an alternative database.
- Experimental support for JSON configuration file passed on command line with defaults.
- Removed Bower requirement/dependency.

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


