/*
 * -------------------------------------------------------------------------------
 * cluster.js
 *
 * Provide a wrapper around the application that provides support for clusters.
 * -------------------------------------------------------------------------------
 */

var fs = require('fs')
  , _ = require('underscore')
  , cfg = require('./config')
  , config = {
      readyWhen: 'listening'
    }
  ;

// --------------------------------------------------------
// Adjust the CPU cores used if specified to do so.
// --------------------------------------------------------
if (cfg.cpu && cfg.cpu.workers && ! isNaN(parseInt(cfg.cpu.workers))) {
  config.workers = cfg.cpu.workers;
}

var recluster = require('recluster')
  , path = require('path')
  ;


var cluster = recluster(path.join(__dirname, 'index.js'), config);
cluster.run();

process.on('SIGUSR1', function() {
    console.log('Got SIGUSR1, reloading cluster...');
    cluster.reload();
});

// --------------------------------------------------------
// Rebroadcast all messages from the workers to all
// workers (including the original sender).
// --------------------------------------------------------
_.each(cluster.workers, function(worker) {
  // For each worker, listen for messages.
  worker.process.on('message', function(msg) {
    // For each message received, rebroadcast it to all workers.
    _.each(cluster.workers, function(worker) {
      worker.process.send(msg);
    });
  });
});

console.log("spawned cluster, kill -s SIGUSR1", process.pid, "to reload");

// Write the pid to a file for reloading via scripts easily.
fs.writeFile('process.pid', '' + process.pid, function(err) {
  if (err) throw err;
});


