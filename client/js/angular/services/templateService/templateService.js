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
    if (document.compatMode == "CSS1Compat") {
      return {w: d.documentElement.clientWidth, h: d.documentElement.clientHeight};
    }

    // For browsers in Quirks mode
    return {w: d.body.clientWidth, h: d.body.clientWidth};
  };

  angular.module('templateServiceModule', [])

    .factory('templateService', ['$http', '$templateCache', '$q', 'minPubSubNg',
          function($http, $templateCache, $q, pubSub) {

        // Initialize the viewport size.
        var viewPort = getViewportSize(window);

        // Tracking callbacks to track.
        var registeredCallbacks = [];

        // Template breakpoints in pixels.
        var SMALL = '480';
        var MEDIUM = '600';
        var LARGE = '992';

        /* --------------------------------------------------------
         * getTemplateSize()
         *
         * Return the template breakpoint in use, e.g. SMALL, MEDIUM,
         * or LARGE, based upon the width passed.
         *
         * param       width in pixels
         * return      SMALL, MEDIUM or LARGE constant
         * -------------------------------------------------------- */
        var getTemplateSize = function(width) {
          if (width < MEDIUM) {
            return SMALL;
          } else if (width < LARGE) {
            return MEDIUM;
          } else {
            return LARGE;
          }
        };

        // Template size in current use.
        var currentTemplateSize = getTemplateSize(viewPort.w);

        /* --------------------------------------------------------
         * setTemplateSize()
         *
         * Set the template size to use based upon the current
         * size of the viewport.
         * -------------------------------------------------------- */
        var setTemplateSize = function() {
          currentTemplateSize = getTemplateSize(viewPort.w);
        };

        /* --------------------------------------------------------
         * onResize()
         *
         * Whenever the window.onresize event occurs, this is called.
         * -------------------------------------------------------- */
        var onResize = function() {
          // Save the new viewport sizes and set the current template
          // in use.
          viewPort = getViewportSize(window);
          setTemplateSize();
          console.log('Width: ' + viewPort.w + ', Height: ' + viewPort.h);

          // Notify any registered functions of the change.
          notifyCallbacks();
        };

        // Track resize events.
        window.onresize = onResize;

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
        * resize and related events occur.
        *
        * param       func
        * return      id - used to unregister
        * -------------------------------------------------------- */
        var doRegister = function(func) {
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
            // Listen for unsubscribe event, then unregister the caller
            // and unsubscribe the key afterwards.
            // --------------------------------------------------------
            pubSubKey = pubSub.subscribe(key, function() {
              doUnregister(id);
              pubSub.unsubscribe(pubSubKey);
            });
          }
        };

        /* --------------------------------------------------------
         * getTemplate()
         *
         * Return the actual template based upon the template name
         * which should contain a RES placeholder that will be
         * replaced with the appropriate template width per the
         * established breakpoints. Retrieves the appropriate
         * template from the server if it is not already cached
         * and caches it. Serves the template contents back to the
         * caller in the form of a promise.
         *
         * param       templateName
         * return      promise
         * -------------------------------------------------------- */
        var getTemplate = function(templateName) {
          var template = getTemplateUrl(templateName);
          return $q(function(resolve, reject) {
            var templateContents = $templateCache.get(template);
            if (! templateContents) {
              $http.get(template)
                .success(function(data) {
                  $templateCache.put(template, data);
                  resolve(data);
                });
            } else {
              resolve(templateContents);
            }
          });
        };

        /* --------------------------------------------------------
         * getTemplateUrl()
         *
         * Return the appropriate templateUrl based upon the generic
         * template name passed and the current viewport width and height.
         *
         * This module assumes that:
         * 1. templates are named in TEMPLATENAME.WIDTH.html format, e.g.
         *    'prenatal.960.html'.
         * 2. the valid breakpoints are: 480, 600, and 992.
         *
         * Usage:
         *    getTemplateUrl('prenatalExam');
         *
         * TODO: pre-load the templates into $templateCache and
         * retrieve from there instead of forcing a server call.
         *
         * param      templateName
         * return     templateUrl 
         * -------------------------------------------------------- */
        var getTemplateUrl = function(templateName) {
          return templateName.replace(/RES/, currentTemplateSize);
        };

        /* --------------------------------------------------------
         * needTemplateChange()
         *
         * Returns true if the template needs to be changed based
         * upon a comparison of the former viewport and the current
         * viewport width settings in light of the breakpoints that
         * this service knows about.
         *
         * param       oldViewport
         * return      boolean
         * -------------------------------------------------------- */
        var needTemplateChange = function(oldViewport) {
          var oldSize = getTemplateSize(oldViewport.w);
          if (oldSize === currentTemplateSize) return false;
          return true;
        };

        return {
          register: register,
          getTemplate: getTemplate,
          getTemplateUrl: getTemplateUrl,
          getViewportSize: getViewportSize,
          needTemplateChange: needTemplateChange
        };
      }]);

})(angular, window);
