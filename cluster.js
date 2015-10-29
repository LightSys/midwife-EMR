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
// Adjust the CPU cores used if specified to do so. Otherwise
// use only one worker even if there are multiple cores.
// This is the safe default because if more workers are used,
// the installation also needs a reverse proxy like Nginx in
// front that implements sticky sessions. This is required
// due to the use of Socket.io.
// --------------------------------------------------------
if (cfg.cpu && cfg.cpu.workers && ! isNaN(parseInt(cfg.cpu.workers))) {
  config.workers = cfg.cpu.workers;
} else {
  config.workers = 1;
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
  console.log('Setting up listener for worker.id: ' + worker.id);
  worker.process.on('message', function(msg) {
    // For each message received, rebroadcast it to all workers.
    console.log('Master: received msg');
    _.each(cluster.workers, function(worker) {
      console.log('Master: sending message to worker.id: ' + worker.id);
      worker.process.send(msg);
    });
  });
});

console.log("spawned cluster, kill -s SIGUSR1", process.pid, "to reload");

// Write the pid to a file for reloading via scripts easily.
fs.writeFile('process.pid', '' + process.pid, function(err) {
  if (err) throw err;
});


