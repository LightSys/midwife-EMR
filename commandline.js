/*
 * -------------------------------------------------------------------------------
 * commandline.js
 *
 * Configures and processes command line arguments and exports the configuration
 * found therein as well as the name of the configuration file, if found.
 * -------------------------------------------------------------------------------
 */

'use strict'


const fs = require('fs')
  , path = require('path')
  , program = require('commander')

let cfgFileName = ''
  , cfg = {}

const getAppName = () => {
  return 'Midwife-EMR'
}

const getVersion = () => {
  return fs.readFileSync(path.join(__dirname, './VERSION'))
}

// --------------------------------------------------------
// Process command-line parameters.
// --------------------------------------------------------
program
  .version(getAppName() + ' version ' + getVersion())
  .option('-c, --config <path>', 'Specify configuration file')
  .parse(process.argv)


// --------------------------------------------------------
// Load the configuration file, if available.
// --------------------------------------------------------
if (program.config && program.config.length > 0) {
  cfgFileName = program.config
  try {
    const contents = fs.readFileSync(cfgFileName)
    cfg = JSON.parse(contents)
  } catch (e) { }
}

module.exports = {
  cfgFileName,
  cfg
}
