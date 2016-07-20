/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Exports a configuration object that is the composition of the JSON configuration
 * file passed on the command line and the routes of the application.
 * -------------------------------------------------------------------------------
 */

'use strict'

const fs = require('fs')
  , defaultConfigFilename = './config/config.default.json'

let cfgSettings = require('../commandline')

// --------------------------------------------------------
// Load the default configuration if configuration is
// invalid or not found.
// --------------------------------------------------------
if (! cfgSettings.cfgValid) {
  try {
    const contents = fs.readFileSync(defaultConfigFilename)
    cfgSettings.cfg = JSON.parse(contents)
    console.log('Using default configuration values.')
  } catch (e) {
    console.log(e.toString())
    cfgSettings.cfg = {}
  }
}

// --------------------------------------------------------
// Add the routes onto the config object for convenience.
// --------------------------------------------------------
cfgSettings.cfg.path = require('./config.global').path

module.exports = cfgSettings.cfg

