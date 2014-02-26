/* 
 * -------------------------------------------------------------------------------
 * cluster.js
 *
 * Provide a wrapper around the application that provides support for clusters.
 * ------------------------------------------------------------------------------- 
 */

var fs = require('fs')
  , config = {
      readyWhen: 'listening'
    }
  ;

var recluster = require('recluster'),
    path = require('path');

var cluster = recluster(path.join(__dirname, 'index.js'), config);
cluster.run();

process.on('SIGUSR2', function() {
    console.log('Got SIGUSR2, reloading cluster...');
    cluster.reload();
});

console.log("spawned cluster, kill -s SIGUSR2", process.pid, "to reload");

// Write the pid to a file for reloading via scripts easily.
fs.writeFile('process.pid', '' + process.pid, function(err) {
  if (err) throw err;
});


