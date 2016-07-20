/*
 * -------------------------------------------------------------------------------
 * commandline.js
 *
 * Configures and processes command line arguments and exports the specified options.
 * -------------------------------------------------------------------------------
 */

'use strict'


const fs = require('fs')
  , program = require('commander')


const getVersion = () => {
  return fs.readFileSync('./VERSION')
}

/* --------------------------------------------------------
 * getUserHome()
 *
 * Returns the user's home directory according to the
 * platform being used.
 *
 * Adapted from:
 * https://medium.com/developers-writing/building-a-desktop-application-with-electron-204203eeb658#.gw97r5fap
 * -------------------------------------------------------- */
const getUserHome = () => {
  return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME']
}

const getAppName = () => {
  return 'Midwife-EMR'
}

const defaultConfigFileLocation = () => {
  let cfgFile
  const home = getUserHome()
  const appName = getAppName()
  switch (process.platform) {
    case 'darwin':
      cfgFile = `${home}/Library/Application Support/${appName}/${appName}.json`
      break
    case 'freebsd':
      cfgFile = `${home}/.config/${appName}/${appName}.json`
      break
    case 'linux':
      cfgFile = `${home}/.config/${appName}/${appName}.json`
      break
    case 'sunos':
      cfgFile = `${home}/.config/${appName}/${appName}.json`
      break
    case 'win32':
      cfgFile = `${home}/%APPDATA%/${appName}/${appName}.json`
    default:
      cfgFile = `{appName}.json`
  }
  return cfgFile
}

// --------------------------------------------------------
// Process command-line parameters.
// --------------------------------------------------------
program
  .version(getAppName() + ' version ' + getVersion())
  .option('-c, --config <path>', 'Specify configuration file')
  .parse(process.argv)


// --------------------------------------------------------
// Load the configuration file, if available, and flag
// whether it is valid JSON.
// --------------------------------------------------------
let cfgFileName = program.config || defaultConfigFileLocation()
let cfg
try {
  const contents = fs.readFileSync(cfgFileName)
  cfg = JSON.parse(contents)
} catch (e) {
  console.log(e.toString())
  cfg = {}
}
const cfgValid = Object.keys(cfg).length > 0


module.exports = {
  cfgFileName,
  cfgValid,
  cfg
}
