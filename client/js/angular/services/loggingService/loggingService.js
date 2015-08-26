;(function(angular) {

  'use strict';

  angular.module('loggingServiceModule', [])
    .factory('loggingService', ['moment', 'DEBUG', function(moment, DEBUG) {

      /* --------------------------------------------------------
        * log()
        *
        * Simple logging to the console if DEBUG is true. DEBUG is
        * set as a constant of the application.
        *
        * param      msg        - the message
        * param      force      - ignore DEBUG and write anyway
        * return     undefined
        * -------------------------------------------------------- */
      var log = function(msg, force) {
        var time;
        if (force || DEBUG) {
          time = moment().format('HH:mm:ss.SSS: ');
          console.log(time + msg);
        }
      };

      /* --------------------------------------------------------
       * error()
       *
       * Log to the console without regard to DEBUG.
       *
       * param       msg
       * return      undefined
       * -------------------------------------------------------- */
      var error = function(msg) {
        log(msg, true);
      };

      /* --------------------------------------------------------
       * dir()
       *
       * If DEBUG is true, use console.dir to write to the console.
       *
       * param       msg - usually an object or array
       * return      undefined
       * -------------------------------------------------------- */
      var dir = function(msg) {
        if (DEBUG && console.dir) {
          console.dir(msg);
        }
      };

      return {
        log: log,
        error: error,
        dir: dir
      };
    }]);

})(angular);
