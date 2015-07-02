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
     *  - loadAsNeeded(pregId) - loads pregnancy data if preg id different
     *  - register(func)  - registers a callback for data changes
     *  - unregister(id)  - unregisters a callback
     *  - first()         - moves pointer to first record/forces cb/returns info
     *  - next()          - moves pointer to next record/forces cb/returns info
     *  - prev()          - moves pointer to previous record/forces cb/returns info
     *  - last()          - moves pointer to last record/forces cb/returns info
     *  - curr()          - forces callback/returns info
     *  - info()          - returns information about current record
     * -------------------------------------------------------- */
    .factory('historyService', [
        '$http',
        '$cacheFactory',
        function($http, $cacheFactory) {

      // Paths
      var baseUrl = '/api/history';;
      var pregnancyPath = 'pregnancy/:pregId';

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
        path = baseUrl + '/' + pregnancyPath.replace(/:pregId/, pregId);
        $http.get(path, {responseType: 'json'})
          .success(function(data, sts, headers, config) {
            numRecs = data[0].length;
            currRecNum = numRecs - 1;   // zero-based
            pregnancyCache.put(PREGNANCY_CACHE_KEY, data);
            console.log('Loaded ' + numRecs + ' records.');
            console.dir(data);
            notifyCallbacks();
          })
          .error(function(data, sts, headers, config) {
            console.log('Error: ' + sts);
          });
      };

      /* --------------------------------------------------------
       * loadAsNeeded()
       *
       * Loads a different pregnancy from the server if the load
       * has not yet occurred or if the pregnancy id passed is
       * different than the one already loaded.
       *
       * param       pregId
       * return      undefined
       * -------------------------------------------------------- */
      var loadAsNeeded = function(pregId) {
        if (! pregnancyId || pregnancyId !== pregId) {
          load(pregId);
        }
      };

      /* --------------------------------------------------------
       * formatData()
       *
       * Format the data to conform to the expected format.
       *
       * param       data
       * return      rec
       * -------------------------------------------------------- */
      var formatData = function(data) {
        var rec = {};
        // First record in array are main tables collated/merged.
        rec.pregnancy = data[0][currRecNum].pregnancy;
        rec.patient = data[0][currRecNum].patient;
        rec.prenatalExam = data[0][currRecNum].prenatalExam;

        rec.whatChanged = data[0][currRecNum].whatChanged;  // Table level what changed.
        rec.replacedAt = data[0][currRecNum].replacedAt;

        // --------------------------------------------------------
        // Flag changed records at the field level - PROOF of Concept.
        // TODO: clean this up.
        // TODO: figure out how to handle secondary tables.
        // TODO: determine if this is worth the effort.
        //
        // Note: table-level changes are recorded in the whatChanged
        // field by mergeRecs in util.js on the server. Maybe both
        // of these are not necessary or table level change information
        // could be leveraged here to improve performance. Or all of
        // this could be done on the server.
        // --------------------------------------------------------
        rec.changed = {};
        rec.changed.pregnancy = {};
        rec.changed.patient = {};
        if (currRecNum > 0) {
          _.each(['pregnancy', 'patient'], function(table) {
            var pRec = data[0][currRecNum - 1][table];
            var cRec = data[0][currRecNum][table];
            _.each(cRec, function(val, fld) {
              if (val !== pRec[fld]) rec.changed[table][fld] = true;
            });
          });
        }

        // Secondary tables which are not collated/merged.
        rec.secondary = data[1];

        return rec;
      };

      /* --------------------------------------------------------
       * notifyCallbacks()
       *
       * Notify all of the registered callbacks that the pregnancy
       * information has changed. If called before initial load(),
       * does nothing.
       * -------------------------------------------------------- */
      var notifyCallbacks = function() {
        var json = pregnancyCache.get(PREGNANCY_CACHE_KEY);
        var rec;
        if (json) {
          rec = formatData(json);   //json[0][currRecNum];
          _.each(registeredCallbacks, function(cbObj) {
            cbObj.func(rec);
          });
        }
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
          console.log('Register: ' + funcObj.id);
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
        console.log('Unregister: ' + id);
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
      var curr = function() {
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

      /* --------------------------------------------------------
       * lookup()
       *
       * Return the record as specified per the table, key field
       * name, and key field value passed. Returns undefined if
       * the record is not found or if anything else does not
       * align as expected.
       *
       * param      table
       * param      key
       * param      val
       * return     record or undefined
       * -------------------------------------------------------- */
      var lookup = function(table, key, val) {
        var json = pregnancyCache.get(PREGNANCY_CACHE_KEY);
        var search = {};
        var lookups;
        if (json) {
          lookups = json[2];
          if (_.has(lookups, table)) {
            search[key] = val;
            return _.findWhere(lookups[table], search);
          }
        }
        return undefined;
      };

      // ========================================================
      // ========================================================
      // Public API of historyService.
      // ========================================================
      // ========================================================
      return {
        load: load,
        loadAsNeeded: loadAsNeeded,
        register: register,
        unregister: unregister,
        next: next,
        prev: prev,
        first: first,
        last: last,
        curr: curr,
        info: info,
        lookup: lookup
      };

    }]);

})(angular, _);
