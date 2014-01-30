/* 
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Loads the global config and then the appropriate environment specific config
 * based upon the value of NODE_ENV in the environment.
 *
 * Reference:
 * http://www.chovy.com/node-js/managing-config-variables-inside-a-node-js-application/
 * ------------------------------------------------------------------------------- 
 */

var env = process.env.NODE_ENV || 'development'
  , cfg = require('./config.' + env)
  ;

module.exports = cfg;

