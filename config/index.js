/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Exports a configuration object that is obtained from either the configuration
 * file passed on the command line, the configuration file found in the default
 * location, or the default application settings.
 *
 * Appends all routes on the configuration object as well as the applications
 * default directory and configuration file locations.
 *
 * Creates, if neccesary, the application directory.
 * -------------------------------------------------------------------------------
 */

'use strict'

const fs = require('fs')
  , path = require('path')
  , _ = require('underscore')
  , KEY_VALUE_UPDATE = require('../constants').KEY_VALUE_UPDATE
  , defaultConfigFilename = path.join(__dirname, 'config.default.json')
  , NodeCache = require('node-cache')
  , KEY_VALUE = 'keyValue'
  ;

let cfg = {}
  , usingDefaultSettings = false
  , longCache = new NodeCache({stdTTL: 0, checkperiod: 0})

const getAppName = () => {
  return 'Midwife-EMR'
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


const defaultAppDirectory = () => {
  const appName = getAppName()
  const home = getUserHome()
  let defaultDir
  switch (process.platform) {
    case 'darwin':
      defaultDir = `${home}/Library/Application Support/${appName}`
      break
    case 'freebsd':
      defaultDir = `${home}/.config/${appName}`
      break
    case 'linux':
      defaultDir = `${home}/.config/${appName}`
      break
    case 'sunos':
      defaultDir = `${home}/.config/${appName}`
      break
    case 'win32':
      defaultDir = `${home}/%APPDATA%/${appName}`
    default:
      defaultDir = ''
  }
  return defaultDir
}

const defaultConfigFileLocation = () => {
  let cfgFile
  const appName = getAppName()
  const defaultDir = defaultAppDirectory()
  cfgFile = path.join(defaultDir, `${appName}.json`)
  return cfgFile
}

// --------------------------------------------------------
// First load the settings passed on the command line, if any.
// --------------------------------------------------------
let cmdLineSettings = require('../commandline')

// --------------------------------------------------------
// If configuration settings were not passed on command line,
// try a couple other locations.
// --------------------------------------------------------
if (! cmdLineSettings ||
    ! cmdLineSettings.cfg ||
    ! Object.keys(cmdLineSettings.cfg).length > 0) {

  // First try the default configuration file location.
  const defaultFile = defaultConfigFileLocation()
  try {
    const contents = fs.readFileSync(defaultFile)
    cfg = JSON.parse(contents)
  } catch (e) { }

  // --------------------------------------------------------
  // Next, if neccessary, load the default settings.
  // --------------------------------------------------------
  if (Object.keys(cfg).length === 0) {
    try {
      const contents = fs.readFileSync(defaultConfigFilename)
      cfg = JSON.parse(contents)
      console.log('Using default configuration values.')
      usingDefaultSettings = true
    } catch (e) {
      cfg = {}
    }
  } else {
    console.log('Using ' + defaultFile)
  }
} else {
  // Command line settings found so pick them up.
  cfg = cmdLineSettings.cfg
  console.log('Using ' + cmdLineSettings.cfgFileName)
}

// --------------------------------------------------------
// Establish an application settings in the config if there
// is not one already. Set the default directory and the
// configuration file.
// --------------------------------------------------------
if (! cfg.application) cfg.application = {}
if (! cfg.application.directory) {
  cfg.application.directory = defaultAppDirectory()
}
if (! cfg.application.configurationFile) {
  if (cmdLineSettings.cfgFileName && ! usingDefaultSettings) {
    cfg.application.configurationFile = cmdLineSettings.cfgFileName
  } else {
    cfg.application.configurationFile = defaultConfigFileLocation()
  }
}

// --------------------------------------------------------
// Attempt to create the application directory if it does
// not exist already.
// --------------------------------------------------------
if (cfg.application.directory) {
  let dirFound = false
  try {
    dirFound = fs.statSync(cfg.application.directory).isDirectory()
  } catch (e) { }
  if (! dirFound) {
    try {
      fs.mkdirSync(cfg.application.directory)
      console.log('Created application directory: ' + cfg.application.directory)
    } catch (e) { }
  }
}

// --------------------------------------------------------
// Write out the configuration file no file was found and
// default settings are being used.
// --------------------------------------------------------
if (usingDefaultSettings && cfg.application.configurationFile) {
  try {
    fs.writeFileSync(cfg.application.configurationFile, JSON.stringify(cfg))
  } catch (e) {
    console.log(e.toString())
  }
}

// --------------------------------------------------------
// Add the routes onto the config object for convenience.
// --------------------------------------------------------
cfg.path = require('./config.global').path

// --------------------------------------------------------
// Set the data in the keyValue table into a cache for this
// process that is accessible via getKeyValue() by key.
// --------------------------------------------------------
cfg.setKeyValue = function(data) {
  longCache.set(KEY_VALUE, data);
}

// --------------------------------------------------------
// Return the specified key within the keyValue data object.
// --------------------------------------------------------
cfg.getKeyValue = function(key) {
  var data = longCache.get(KEY_VALUE);
  if (_.isObject(data)) {
    return data[key];
  } else {
    return void 0;
  }
}

// --------------------------------------------------------
// The keyValues were changed by this or another process so
// update accordingly. See routes/comm/lookupTables.js as
// the initiator based upon changes from the user.
// --------------------------------------------------------
process.on('message', function(msg) {
  if (_.isObject(msg) && _.has(msg, KEY_VALUE_UPDATE)) {
    var data = msg[KEY_VALUE_UPDATE];
    cfg.setKeyValue(data);
  }
});

module.exports = cfg

