;(function(angular, _) {

  'use strict';

  angular.module('historyServiceModule', [])

    /* --------------------------------------------------------
     * historyService()
     *
     * Retrieves, caches, and serves historical data from the
     * pregnancy Log tables, e.g. pregnancyLog, patientLog,
     * riskLog and many others. These tables are under no
     * circumstances to be written to directly (that is handled
     * by triggers upon changes to the non-Log versions of the
     * respective tables).  Therefore, $resource class or
     * instances are not returned from this service - only the data.
     *
     * All actual pregnancy data is provided to clients through the
     * registered callbacks. Information about the current record
     * such as the current record number and total number of
     * records are returned by the info(), first(), prev(), next()
     * and last() functions.
     *
     * Methods exposed by historyService:
     *  - load(pregId)    - loads pregnancy data for the id passed
     *  - register(func)  - registers a callback for data changes
     *  - unregister(id)  - unregisters a callback
     *  - first()         - moves pointer to first record
     *  - next()          - moves pointer to next record
     *  - prev()          - moves pointer to previous record
     *  - last()          - moves pointer to last record
     *  - info()          - returns information about current record
     * -------------------------------------------------------- */
    .factory('historyService', [
        '$resource',
        '$cacheFactory',
        function($resource, $cacheFactory) {

      // Paths
      var baseUrl = '/api/history';;
      var pregnancyPath = 'pregnancy/:pregId';

      // Resources
      var pregnancyResource;

      // Caches and cache keys
      var PREGNANCY_CACHE = 'pregnancyCache';
      var PREGNANCY_CACHE_KEY = 'all';
      var pregnancyCache = $cacheFactory(PREGNANCY_CACHE);

      // Tracking callbacks to track.
      var registeredCallbacks = [];

      // Tracking meta information about the current pregnancy.
      var pregnancyId;
      var numRecs;
      var currRecNum;


      /* --------------------------------------------------------
       * load()
       *
       * Load a different pregnancy from the server, store it in
       * the cache (replacing what was there already, if anything),
       * and call the registered callbacks.
       *
       * param       pregId
       * return      undefined
       * -------------------------------------------------------- */
      var load = function(pregId) {
        var path;
        pregnancyId = pregId;
        pregnancyCache.removeAll();
        path = baseUrl + '/' + pregnancyPath;
        pregnancyResource = $resource(path, {pregId: '@pregId'});
        pregnancyResource
          .query({pregId: pregnancyId}, function(data) {
            var json = angular.fromJson(data);
            numRecs = json.length;
            currRecNum = numRecs - 1; // Set to last rec, zero based.
            pregnancyCache.put(PREGNANCY_CACHE_KEY, json);
            console.log('Loaded ' + numRecs + ' records.');
            notifyCallbacks();
          });
      };

      /* --------------------------------------------------------
       * notifyCallbacks()
       *
       * Notify all of the registered callbacks that the pregnancy
       * information has changed.
       * -------------------------------------------------------- */
      var notifyCallbacks = function() {
        var json = pregnancyCache.get(PREGNANCY_CACHE_KEY);
        var rec = json[currRecNum];
        _.each(registeredCallbacks, function(cbObj) {
          cbObj.func(rec);
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
       * register()
       *
       * Register a callback function that is called whenever the
       * current historical record changes.
       *
       * param       func
       * return      id - used to unregister
       * -------------------------------------------------------- */
      var register = function(func) {
        var funcObj = {
          id: getId(),
          func: func
        };
        if (func && _.isFunction(func)) {
          registeredCallbacks.push(funcObj);
          return funcObj.id;
        }
        return void 0;
      };


      /* --------------------------------------------------------
       * unregister()
       *
       * Unregister a previously registered callback. Requires that
       * the id originally returned from the register function be
       * passed so that the proper callback can be unregistered.
       *
       * param       id
       * return      boolean for success
       * -------------------------------------------------------- */
      var unregister = function(id) {
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


      /* --------------------------------------------------------
       * next()
       * prev()
       * first()
       * last()
       *
       * Sets the internal record pointer and calls notifyCallbacks().
       * Then returns an object via info() that carries meta data
       * about the new current record.
       * -------------------------------------------------------- */
      var next = function() {
        if (currRecNum < (numRecs - 1)) currRecNum++;
        notifyCallbacks();
        return info();
      };
      var prev = function() {
        if (currRecNum > 0) currRecNum--;
        notifyCallbacks();
        return info();
      };
      var first = function() {
        currRecNum = 0;
        notifyCallbacks();
        return info();
      };
      var last = function() {
        currRecNum = numRecs - 1;
        notifyCallbacks();
        return info();
      };

      /* --------------------------------------------------------
       * info()
       *
       * Returns an object with meta information about the current
       * record.
       * -------------------------------------------------------- */
      var info = function() {
        // Return non-zero based record numbers.
        return {
          numberRecords: numRecs,
          currentRecord: currRecNum + 1,
          pregnancyId: pregnancyId
        };
      };

      // ========================================================
      // ========================================================
      // Public API of historyService.
      // ========================================================
      // ========================================================
      return {
        load: load,
        register: register,
        unregister: unregister,
        next: next,
        prev: prev,
        first: first,
        last: last,
        info: info
      };

    }]);

})(angular, _);
