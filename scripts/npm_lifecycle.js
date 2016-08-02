#!/usr/bin/env node
/* 
 * -------------------------------------------------------------------------------
 * npm_lifecycle.js
 *
 * Handle various NPM life cycle events.
 * ------------------------------------------------------------------------------- 
 */

"use strict";

const fs = require('fs')
const execFileSync = require('child_process').execFileSync

const lcEvent = process.env.npm_lifecycle_event
console.log(`Processing ${lcEvent}.`)

switch (lcEvent) {
  case 'postinstall':
    if (true) {
      try {
        // --------------------------------------------------------
        // Rename a .babelrc file from an old version of Babel that
        // redux-optimist still uses because it caused the new
        // version of Babel that we are running to fail.
        // --------------------------------------------------------
        const oldFile = 'node_modules/redux-optimist/.babelrc'
        const newFile = 'node_modules/redux-optimist/.babelrc-renamed'
        if (fs.statSync(oldFile).isFile()) {
          fs.renameSync(oldFile, newFile)
          console.log(`Renamed ${oldFile} to ${newFile}.`)
        }
      } catch (e) {}

      // --------------------------------------------------------
      // Run gulp to create all of the static files.
      // --------------------------------------------------------
      console.log('Running gulp ...')
      const output = execFileSync('./node_modules/.bin/gulp', [], {encoding: 'utf8'})
      console.log(output)
    }
    break

}

