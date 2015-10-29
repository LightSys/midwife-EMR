/*
 * -------------------------------------------------------------------------------
 * midwife-emr-sockets.js
 *
 * This is the interface to the server over Socket.io.
 * -------------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------
 * Testing
 *
 * param       
 * -------------------------------------------------------------------- */
(function(window, io) {

  'use strict';

  var ioSystem = io.connect(window.location.origin + '/system');
  var ioData = io.connect(window.location.origin + '/data');
  var ioSite = io.connect(window.location.origin + '/site');

  console.log('Running midwife-emr-sockets.js');

  // Site communications are server to client. Just write it to the console for now.
  ioSite.on('site', function(data) {
    console.dir(data);
  });

})(window, io);
