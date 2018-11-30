const merge = require('webpack-merge');
var common = require('./webpack.common.js');

// This allows windows.onerror to report specific
// errors back to the server instead of just
// reporting 'Script error.' because the browser
// thinks that there is a cross-origin problem.
common.devtool = 'cheap-module-source-map';

module.exports = common;
