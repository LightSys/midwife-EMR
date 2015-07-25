;(function(angular, window) {

  'use strict';

  /* --------------------------------------------------------
  * getViewportSize()
  *
  * Return the viewport size as w and h properties of an object.
  * Adapted from "Javascript: The Definitive Guide", example
  * 15-9.
  *
  * param      w - the window object
  * return     Object with w and h elements for width and height
  * -------------------------------------------------------- */
  var getViewportSize = function(w) {
    // Use the specified window or the current window if no argument
    w = w || window;

    // This works for all browsers except IE8 and before
    if (w.innerWidth != null) return {w: w.innerWidth, h:w.innerHeight};

    // For IE (or any browser) in Standards mode
    var d = w.document;
    if (document.compatMode == "CSS1Compat")        return { w: d.documentElement.clientWidth,
                h: d.documentElement.clientHeight };

    // For browsers in Quirks mode
    return { w: d.body.clientWidth, h: d.body.clientWidth };
  };
  var viewPort;


  angular.module('templateServiceModule', [])

    .factory('templateService', ['minPubSubNg',
      function(pubSub) {

        // Current viewport size.
        var viewPort;

        // Tracking resize event?
        var isTrackingResize = false;

        // Tracking callbacks to track.
        var registeredCallbacks = [];

        /* --------------------------------------------------------
         * onResize()
         *
         * Whenever the window.onresize event occurs, this is called.
         * -------------------------------------------------------- */
        var onResize = function() {
          // Save the new viewport sizes.
          viewPort = getViewportSize(window);
          console.log('Width: ' + viewPort.w + ', Height: ' + viewPort.h);

          // Notify any registered functions of the change.
          notifyCallbacks();
        };

        /* --------------------------------------------------------
        * notifyCallbacks()
        *
        * Notify all of the registered callbacks that the viewport
        * information has changed.
        * -------------------------------------------------------- */
        var notifyCallbacks = function() {
          _.each(registeredCallbacks, function(cbObj) {
            cbObj.func(viewPort);
          });
        };

        /* --------------------------------------------------------
        * getId()
        *
        * Returns an unique id for a registered callback.
        *
        * param       undefined
        * return      id
        * -------------------------------------------------------- */
        var getId = function() {
          return _.uniqueId();
        };

        /* --------------------------------------------------------
        * doRegister()
        *
        * Register a callback function that is called whenever the
        * current historical record changes.
        *
        * param       func
        * return      id - used to unregister
        * -------------------------------------------------------- */
        var doRegister = function(func) {
          if (! isTrackingResize) window.onresize = onResize;
          var funcObj = {
            id: getId(),
            func: func
          };
          if (func && _.isFunction(func)) {
            registeredCallbacks.push(funcObj);
            console.log('Register templateService: ' + funcObj.id);
            return funcObj.id;
          }
          return void 0;
        };

        /* --------------------------------------------------------
        * doUnregister()
        *
        * Unregister a previously registered callback. Requires that
        * the id originally returned from the register function be
        * passed so that the proper callback can be unregistered.
        *
        * param       id
        * return      boolean for success
        * -------------------------------------------------------- */
        var doUnregister = function(id) {
          console.log('Unregister templateService: ' + id);
          var len = registeredCallbacks.length;
          // Better way to do this?
          registeredCallbacks = _.reject(registeredCallbacks, function(c) {
            return c.id === id;
          });
          if (registeredCallbacks.length < len) {
            return true;
          }
          return false;
        };

        // ========================================================
        // ========================================================
        // Public API.
        // ========================================================
        // ========================================================

        /* --------------------------------------------------------
         * register()
         *
         * Register the function passed to be called for all resize
         * events and other template related events. Expects a key
         * that is listened on by the service in order to signal
         * that the registration should be cancelled.
         *
         * param       key
         * param       func
         * return      undefined
         * -------------------------------------------------------- */
        var register = function(key, func) {
          var id = doRegister(func);
          var pubSubKey;
          if (id) {
            // --------------------------------------------------------
            // Unregister the caller and unsubscribe the key afterwards.
            // --------------------------------------------------------
            pubSubKey = pubSub.subscribe(key, function() {
              doUnregister(id);
              pubSub.unsubscribe(pubSubKey);
            });
          }
        };

        return {
          register: register
        };
      }]);

})(angular, window);
