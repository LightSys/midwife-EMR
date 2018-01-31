/*
 * -------------------------------------------------------------------------------
 * database.js
 *
 * Creates and initializes the database, if necessary.
 * -------------------------------------------------------------------------------
 */

'use strict';

var Knex = require('knex')
  , fs = require('fs')
  , path = require('path')
  //, sqlite3 = require('sqlite3').verbose()
  , util = require('../util')
    // Note: file references from the perspective of the top-level directory.
  , sqliteCreateSchemaFile = './database/sql/create_sqlite_schema.sql'
  , sqliteLoadDataFile = './database/sql/load_default_data_sqlite.sql'
  ;


/* --------------------------------------------------------
 * init()
 *
 * Create the database if it does not already exist. Creates
 * a MySQL or a SQLite3 database based upon the settings
 * passed.
 *
 * param       cfg      - configuration object
 * return      cb       - (err, success) Node style
 * -------------------------------------------------------- */
const init = (cfg, cb) => {
  let settings = cfg.database
  let dbConn
  let databaseFile

  // Sanity check
  if (! settings.file && ! settings.db) return cb('Error: invalid configuration.', false)

  // --------------------------------------------------------
  // Sanity check MySQL settings passed.
  // --------------------------------------------------------
  if (util.dbType() === util.KnexMySQL) {
    if (! settings.host ||
        ! settings.port ||
        ! settings.dbUser ||
        ! settings.dbPass ||
        ! settings.db ||
        ! settings.charset) {
      return ('Error: invalid database settings passed for MySQL database connection.', false)
    }
  }

  // --------------------------------------------------------
  // Determine if SQLite3 database already exists, create it
  // if necessary, populate with proper schema, and load
  // default data.
  // --------------------------------------------------------
  if (util.dbType() === util.KnexSQLite3) {
    // --------------------------------------------------------
    // Put the database in the correct directory.
    // --------------------------------------------------------
    /*
    if (settings.directory.length === 0 ||
        ! fs.statSync(settings.directory).isDirectory()) {
      databaseFile = path.join(cfg.application.directory, settings.file)
    } else {
      databaseFile = path.join(settings.directory, settings.file)
    }

    // Open the database, creating it if necessary.
    console.log(`Opening the database: ${databaseFile}`)
    dbConn = new sqlite3.Database(databaseFile, sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE, (err) => {
      if (err) return cb(err, false)

      dbConn.serialize();

      // --------------------------------------------------------
      // Determine if the tables, triggers, etc. have been
      // created yet and create if necesary.
      // --------------------------------------------------------
      testForSQLiteSchema(dbConn, (err, success) => {
        if (err) return dbConn.close(() => {cb(err, false)})

        // --------------------------------------------------------
        // Create tables and triggers if necessary.
        // --------------------------------------------------------
        if (! success) {
          console.log('Creating database schema.')

          // Get the SQL as individual statements which are delimited by $$.
          runSQLiteSQL(dbConn, sqliteCreateSchemaFile, (err, success) => {
            if (err) return dbConn.close(() => {cb(err, false)})
            if (! success) return cb('Error: unable to create database schema.')

            // Load the default data.
            console.log('Loading default data.')
            runSQLiteSQL(dbConn, sqliteLoadDataFile, (err, success) => {
              if (err) return dbConn.close(() => {cb(err, false)})
              if (! success) return cb('Error: unable to load default data.')

              // --------------------------------------------------------
              // Close the database connection and invoke caller's callback.
              // --------------------------------------------------------
              dbConn.close((err) => {
                return cb(null, true)
              })
            })
          })
        } else {
          // The database was previously created so will use as is after we close it.
          dbConn.close((err) => {
            return cb(null, true)
          })
        }
      })
    })
    */
  } else {
    // --------------------------------------------------------
    // Handle a MySQL database.
    // --------------------------------------------------------
    // TODO: build out schema if necessary.
    return cb(null, true)
  }

}


/* --------------------------------------------------------
 * runSQLiteSQL()
 *
 * Runs all of the SQL defined in the file passed against
 * the database connection passed. Assumes that the file
 * contains SQL statements that are delimited by $$. Calls
 * the callback passed using standard NodeJS style with
 * error as the first parameter and a boolean for success
 * as the second.
 *
 * param       conn       - the database connection
 * param       sqlFile    - the SQL file
 * param       cb         - the callback
 * return      undefined
 * -------------------------------------------------------- */
const runSQLiteSQL = function(conn, sqlFile, cb) {
  const sqlArray = fs.readFileSync(sqlFile, 'utf-8')
    .replace(/^\s*$/gm, '')   // Remove blank lines.
    .split('$$')              // Split into SQL statements on delimiter.
    .slice(0, -1)             // Remove last entry after delimiter.

  const numSQL = sqlArray.length - 1   // Assumes delimiter at end.
  const lastSQL = sqlArray[numSQL]
  sqlArray.forEach((sql) => {
    conn.run(sql, (err) => {
      if (err) {
        // Called with error argument if there was an error in a SQL statement.
        console.log(err)
        console.log(sql)
      } else {
        // Always called without argument after each SQL statement.
        if (sql === lastSQL) {
          cb(null, true)
        }
      }
    })
  })
}

/* --------------------------------------------------------
 * testForSQLiteSchema()
 *
 * Test for the existence of a subset of the expected tables
 * as a means to determine if the database has already been
 * properly populated with the expected schema.
 *
 * Returns a Nodejs style callback with the 2nd param a boolean
 * success parameter.
 *
 * param       conn
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
const testForSQLiteSchema = function(conn, testCB) {
  var testSuccess = true
  var numProcessed = 0
  const tables = [
    'user',
    'patient',
    'pregnancy',
    'medication',
    'vaccination',
    'prenatalExam',
    'labSuite',
  ]

  tables.forEach((tbl) => {
    const sql = `SELECT COUNT(*) AS found FROM sqlite_master WHERE type="table" AND name="${tbl}" COLLATE NOCASE`
    conn.get(sql, [], (err, row) => {
      if (err || row.found === 0) {
        testSuccess = false
      }
      if (++numProcessed === tables.length) {
        testCB(null, testSuccess)
      }
    })
  })
}

module.exports = {
  init
}
