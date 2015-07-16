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


      // List of sources (tables) that contain the historical changes.
      var historicalSources = ['pregnancy', 'patient', 'prenatalExam',
        'healthTeaching', 'labTestResult', 'medication', 'vaccination',
        'referral', 'pregnancyHistory', 'risk'];

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
      var currRecNum;   // Based on 3rd array in input data.


      /* --------------------------------------------------------
       * load()
       *
       * Load a different pregnancy from the server, store it in
       * the cache (replacing what was there already, if anything),
       * and call the registered callbacks.
       *
       * The data comes from the server in the form of an array
       * with three elements.
       *
       * The first is an object that contains the element for each
       * data source, within each of which is an array of historical
       * records sorted in ascending order by the replacedAt field.
       *
       * The second is an object that contains an element for each
       * lookup table.
       *
       * The third is an array of changes in the form of objects,
       * each of which contain an element for each table that was
       * changed at that point in time, a datetime stamp, and an
       * indexes object that contains elements representing each
       * table with the value set to the index of the table that
       * should be used at that point in time in relation to the
       * objects of the first array returned by the server.
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
            numRecs = data[2].length;
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

      var getRecBySource = function(data, src, recNum) {
        var recs;
        _.each(data[2][recNum].indexes[src], function(idx) {
          // --------------------------------------------------------
          // Determine if the src is a detail table or not based upon
          // the presence of the pregnancy_id field.
          // --------------------------------------------------------
          if (data[0][src][idx]['pregnancy_id']) {
            if (! recs) recs = [];
            recs.push(data[0][src][idx]);
          } else {
            // --------------------------------------------------------
            // The main tables only have one record. For ease of use to
            // the client, we don't return it in an array.
            // --------------------------------------------------------
            recs = data[0][src][idx];
          }
        });
        return recs;
      };

      var getChangedBySource = function(data, src, recNum) {
        if (data[2][recNum][src]) {
          return data[2][recNum][src];
        }
        return {};
      };

      /* --------------------------------------------------------
       * getChangedBy()
       *
       * Return an object with updatedBy and supervisor elements
       * that contain the user ids of those responsible for the
       * specified changed.
       *
       * param       data
       * param       recNum
       * return      changedBy
       * -------------------------------------------------------- */
      var getChangedBy = function(data, recNum) {
        var changedBy = {updatedBy: void 0, supervisor: void 0};
        var tables = _.omit(data[2][recNum], ['replacedAt', 'indexes']);
        var tbl;
        var recId;
        var chgIdx;
        if (tables && _.size(tables) > 0) {
          tbl = _.keys(tables)[0];    // Take the first table.
          recId = parseInt(_.keys(tables[tbl])[0], 10);
          if (_.isNumber(recId)) {
            chgIdx = data[2][recNum].indexes[tbl][recId];
            changedBy.updatedBy = data[0][tbl][chgIdx].updatedBy;
            changedBy.supervisor = data[0][tbl][chgIdx].supervisor;
          }
        }
        return changedBy;
      };

      /* --------------------------------------------------------
       * prepareRecord()
       *
       * Format the data to conform to the expected format for
       * the record in question.
       *
       * param       data
       * param       recNum
       * return      rec
       * -------------------------------------------------------- */
      var prepareRecord = function(data, recNum) {
        var rec = {};

        // --------------------------------------------------------
        // Populate the tables for this record number.
        // --------------------------------------------------------
        _.each(historicalSources, function(src) {
          rec[src] = getRecBySource(data, src, recNum);
        });

        rec.replacedAt = data[2][recNum].replacedAt;

        // --------------------------------------------------------
        // Flag changed records at the field level.
        // --------------------------------------------------------
        rec.changed = {};
        _.each(historicalSources, function(src) {
          rec.changed[src] = getChangedBySource(data, src, recNum);
        });

        // --------------------------------------------------------
        // Raw tables with full history.
        //
        // TODO: remove this if the client views do not need it.
        // --------------------------------------------------------
        rec.sources = data[0];

        // --------------------------------------------------------
        // Lookup tables.
        // --------------------------------------------------------
        rec.lookup = data[1];

        // --------------------------------------------------------
        // Provide a record of the user ids of the user and, if
        // available, the supervisor that made this change.
        // --------------------------------------------------------
        rec.changedBy = getChangedBy(data, recNum);

        return rec;
      };

      /* --------------------------------------------------------
       * notifyCallbacks()
       *
       * Notify all of the registered callbacks that the pregnancy
       * information has changed. If called before initial load(),
       * does nothing.
       * -------------------------------------------------------- */
      var notifyCallbacks = function(recNum) {
        var recNum = recNum || currRecNum;
        var json = pregnancyCache.get(PREGNANCY_CACHE_KEY);
        var rec;
        if (json) {
          rec = prepareRecord(json, recNum);
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
       * findBySource()
       *
       * Find the "next" record that has changed for the source
       * specified in the direction specified, and pertaining to
       * the detail id passed, if specified.
       *
       * dir can be 'f' for first, 'l' for last, 'p' for previous
       * or 'n' for next.
       *
       * Returns the record number of the change found, or
       * currRecNum if nothing was found.
       *
       * param       source
       * param       dir - one of 'f', 'l', 'p', or 'n'
       * param       detId
       * return      recordNum
       * -------------------------------------------------------- */
      var findBySource = function(source, dir, detId) {
        var found = false;
        var newRecNum = currRecNum;
        var data;
        var i;
        var test;
        var op;

        // Sanity checks.
        if (! source || ! dir) {
          console.log('findBySource() warning: source and/or dir is not defined.');
          return currRecNum;
        }
        if (! dir || ! _.contains(['f','l','p','n'], dir)) {
          console.log('findBySource() error: dir is inappropriately defined.');
          return currRecNum;
        }

        // Setup.
        switch (dir) {
          case 'f':
          case 'n':
            test = function(x) {return x < numRecs;};
            op = function(x) {return x + 1;};
            break;
          case 'l':
          case 'p':
            test = function(x) {return x > -1;};
            op = function(x) {return x - 1;};
            break;
        }
        if (dir === 'f') i = 0;
        if (dir === 'l') i = numRecs - 1;
        if (dir === 'p') i = currRecNum - 1;
        if (dir === 'n') i = currRecNum + 1;

        // Find matching record if possible.
        data = pregnancyCache.get(PREGNANCY_CACHE_KEY);
        for (i; test(i) && ! found; i=op(i)) {
          if (_.has(data[2][i], source)) {
            if (detId) {
              if (_.has(data[2][i][source], detId)) {
                found = true;
                newRecNum = i;
              }
            } else {
              found = true;
              newRecNum = i;
            }
          }
        }
        return newRecNum;
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
      var next = function(source, detId) {
        var origRecNum = currRecNum;
        if (source) {
          currRecNum = findBySource(source, 'n', detId);
          if (origRecNum !== currRecNum) {
            notifyCallbacks();
          }
          return info();
        } else {
          if (currRecNum < (numRecs - 1)) currRecNum++;
          notifyCallbacks();
          return info();
        }
      };
      var prev = function(source, detId) {
        var origRecNum = currRecNum;
        if (source) {
          currRecNum = findBySource(source, 'p', detId);
          if (origRecNum !== currRecNum) {
            notifyCallbacks();
          }
          return info();
        } else {
          if (currRecNum > 0) currRecNum--;
          notifyCallbacks();
          return info();
        }
      };
      var first = function(source, detId) {
        var origRecNum = currRecNum;
        if (source) {
          currRecNum = findBySource(source, 'f', detId);
          if (origRecNum !== currRecNum) {
            notifyCallbacks();
          }
          return info();
        } else {
          currRecNum = 0;
          notifyCallbacks();
          return info();
        }
      };
      var last = function(source, detId) {
        var origRecNum = currRecNum;
        if (source) {
          currRecNum = findBySource(source, 'l', detId);
          if (origRecNum !== currRecNum) {
            notifyCallbacks();
          }
          return info();
        } else {
          currRecNum = numRecs - 1;
          notifyCallbacks();
          return info();
        }
      };
      var curr = function() {
        notifyCallbacks();
        return info();
      };

      /* --------------------------------------------------------
       * getChangedByNum()
       *
       * Returns the changed tables and fields for the specified
       * record number according to the output of
       * getChangedBySource() for each of the historicalSources.
       * Does not notify callbacks or change the internal current
       * record number.
       *
       * Note: expects that the recNum passed is *not* a zero-based
       * record number, but rather the record number from the user
       * perspective that starts with 1.
       *
       * param       recNum
       * return      record - per the output of prepareRecord()
       * -------------------------------------------------------- */
      var getChangedByNum = function(recNum) {
        var json = pregnancyCache.get(PREGNANCY_CACHE_KEY);
        var changed = {};

        // --------------------------------------------------------
        // Sanity checks.
        // --------------------------------------------------------
        if (isNaN(parseInt(recNum, 10))) return changed;
        if (recNum > numRecs) return changed;
        if (recNum < 1) return changed;
        if (! json) return changed;

        // --------------------------------------------------------
        // Build the changed object for this record number.
        // --------------------------------------------------------
        _.each(historicalSources, function(src) {
          changed[src] = getChangedBySource(json, src, recNum - 1);
        });

        return changed;
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
          lookups = json[1];
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
        lookup: lookup,
        getChangedByNum: getChangedByNum
      };

    }]);

})(angular, _);
