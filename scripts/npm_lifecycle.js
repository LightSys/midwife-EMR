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
      // --------------------------------------------------------
      // Run gulp to create all of the static files.
      // --------------------------------------------------------
      console.log('Running gulp ...')
      try {
        const buffSize = 1024 * 1024 * 50
        const output = execFileSync('./node_modules/.bin/gulp', [],
            {encoding: 'utf8', maxBuffer: buffSize})
        console.log(output)
      } catch (e) {
        console.log(e.toString())
      }
    }
    break
}

