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
        'minPubSubNg',
        'loggingService',
        function($http, $cacheFactory, pubSub, log) {

      // List of sources (tables) that contain the historical changes.
      var historicalSources = ['pregnancy', 'patient', 'prenatalExam',
        'healthTeaching', 'labTestResult', 'medication', 'schedule',
        'vaccination', 'referral', 'pregnancyHistory', 'risk', 'customField',
        'pregnote'];

      // Paths
      var baseUrl = '/api/history';;
      var pregnancyPath = 'pregnancy/:pregId';

      // --------------------------------------------------------
      // Caches and cache keys
      // --------------------------------------------------------
      // Cache the data received from the server.
      var PREGNANCY_CACHE = 'pregnancyCache';
      var PREGNANCY_CACHE_KEY = 'all';
      var pregnancyCache = $cacheFactory(PREGNANCY_CACHE);
      // Cache the changed field mapping calculated by getChangedFields().
      var CHANGED_FIELDS_CACHE = 'changedFieldsCache';
      var changedFieldsCache = $cacheFactory(CHANGED_FIELDS_CACHE);

      // Tracking callbacks to track.
      var registeredCallbacks = [];

      // Tracking meta information about the current pregnancy.
      var pregnancyId;
      var numRecs;
      var currRecNum;   // Based on 3rd array in input data, zero based.

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
            //currRecNum = numRecs - 1;   // zero-based, set to last record
            currRecNum = 0;             // zero-based, set to first record
            pregnancyCache.put(PREGNANCY_CACHE_KEY, data);
            log.log('Loaded ' + numRecs + ' records.');
            log.dir(data);
            notifyCallbacks();
          })
          .error(function(data, sts, headers, config) {
            log.error('Error: ' + sts);
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
          var currRec = data[0][src][idx];
          if (currRec['pregnancy_id']) {
            // Don't show deleted records.
            if (currRec.op !== 'D') {
              if (! recs) recs = [];
              recs.push(currRec);
            }
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
        if (tables && _.size(tables) > 0) {
          // --------------------------------------------------------
          // Loop through the tables for updatedBy and optionally
          // supervisor fields. At least one table, customField, does
          // not contain these fields so we need to loop to insure that
          // we get a real value.
          // --------------------------------------------------------
          _.each(_.keys(tables), function(tbl) {
            if (changedBy.updatedBy) return;  // Ignore any other tables if success.
            var chgIdx;
            var recId = parseInt(_.keys(tables[tbl])[0], 10);
            if (_.isNumber(recId)) {
              chgIdx = data[2][recNum].indexes[tbl][recId];
              changedBy.updatedBy = data[0][tbl][chgIdx].updatedBy;
              changedBy.supervisor = data[0][tbl][chgIdx].supervisor;
            }
          });
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
        rec.currentRecordNumber = recNum;    // zero-based.

        // --------------------------------------------------------
        // Flag changed records at the field level.
        // --------------------------------------------------------
        rec.changed = {};
        _.each(historicalSources, function(src) {
          rec.changed[src] = getChangedBySource(data, src, recNum);
        });

        // --------------------------------------------------------
        // Raw tables with full history.
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
          log.log('Register historyService: ' + funcObj.id);
          return funcObj.id;
        }
        return void 0;
      };

      /* --------------------------------------------------------
       * registerPubSub()
       *
       * Register a callback function that is called whenever the
       * current historical record changes. Additionally listen
       * for a key published as an event to signal when to
       * unregister the caller.
       *
       * param       key
       * param       func
       * return      undefined
       * -------------------------------------------------------- */
      var registerPubSub = function(key, func) {
        var id = register(func);
        var pubSubKey;
        if (id) {
          // --------------------------------------------------------
          // Unregister the caller and unsubscribe the key afterwards.
          // --------------------------------------------------------
          pubSubKey = pubSub.subscribe(key, function() {
            unregister(id);
            pubSub.unsubscribe(pubSubKey);
          });
        }
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
        log.log('Unregister historyService: ' + id);
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
       * findBySourceInfo()
       *
       * Find the "next" record that has changed according to the
       * criteria in the srcInfo object passed, in the direction
       * specified, and pertaining to the detail id passed, if specified.
       *
       * Expects the srcInfo object to be from the
       * changeRoutingService.getSourceFieldInfo() method. This allows the
       * caller to request the next/previous/first/last change that only
       * pertains to a specific page because the srcInfo object specifies
       * the allowable table and field names that the matching change must
       * possess.
       *
       * dir can be 'f' for first, 'l' for last, 'p' for previous
       * or 'n' for next.
       *
       * Returns the record number of the change found, or
       * currRecNum if nothing was found, i.e. no record change.
       *
       * NOTE: depends upon the fieldStateMap internal to the
       * changeRoutingService to be correctly populated.
       *
       * param       srcInfo
       * param       dir - one of 'f', 'l', 'p', or 'n'
       * param       detId
       * return      recordNum
       * -------------------------------------------------------- */
      var findBySourceInfo = function(srcInfo, dir, detId) {
        var found = false;
        var newRecNum = currRecNum;
        var data = pregnancyCache.get(PREGNANCY_CACHE_KEY);
        var i;
        var test;
        var op;
        var tentativeRecNum;
        var currRec;    // The change record we are processing at a certain time.

        // Sanity checks.
        if (! srcInfo || ! dir) {
          log.error('findBySourceInfo() warning: srcInfo and/or dir is not defined.');
          return currRecNum;
        }
        if (! dir || ! _.contains(['f','l','p','n'], dir)) {
          log.error('findBySourceInfo() error: dir is inappropriately defined.');
          return currRecNum;
        }

        // --------------------------------------------------------
        // Setup test() and op() to test for the end of the loop and move
        // the record pointer in the proper direction, respectively.
        // --------------------------------------------------------
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

        // --------------------------------------------------------
        // Loop through change records.
        // --------------------------------------------------------
        for (i; test(i) && ! found; i=op(i)) {
          currRec = data[2][i];

          // --------------------------------------------------------
          // Loop through the tables and acceptable fields that we are
          // looking for as passed in srcInfo.
          // --------------------------------------------------------
          _.each(srcInfo, function(flds, tbl) {
            var dId;
            var detRec;

            // --------------------------------------------------------
            // Does this change contain this table?
            // --------------------------------------------------------
            if (_.has(currRec, tbl)) {
              if (! found) {
                // --------------------------------------------------------
                // If detId is specified, the record must be chosen with it.
                // --------------------------------------------------------
                if (detId) {
                  if (_.has(currRec[tbl], detId)) {
                    detRec = currRec[tbl][detId];
                  }
                } else {
                  // --------------------------------------------------------
                  // No detId, but the changes always have the id of the source
                  // as the key, so take the first one. Multiple keys would
                  // require a detId to access so we are only expecting one anyway.
                  // --------------------------------------------------------
                  dId = _.keys(currRec[tbl])[0];
                  if (! _.isUndefined(dId)) {
                    detRec = currRec[tbl][dId];
                  }
                }
                if (detRec && detRec.fields) {
                  // --------------------------------------------------------
                  // We have a change record so test to see if it has fields
                  // that match the required fields in srcInfo for this table.
                  // --------------------------------------------------------
                  _.each(detRec.fields, function(f) {
                    if (! found) {
                      if (_.contains(flds, f)) {
                        // --------------------------------------------------------
                        // Found a positive match.
                        // --------------------------------------------------------
                        newRecNum = i;
                        found = true;
                      } else {
                        if (_.contains(flds, 'DEFAULT')) {
                          // --------------------------------------------------------
                          // We can use a default field as a tentative answer to use
                          // if we don't come up with anything specific.
                          // --------------------------------------------------------
                          tentativeRecNum = i;
                        }
                      }
                    }     // ! found
                  });
                }
              }   // if (! found)
            }     // if (_.has(currRec, tbl))
          });     // each srcInfo loop.
          // --------------------------------------------------------
          // Still nothing definitive found? Use what we have, if anything.
          // --------------------------------------------------------
          if (! found && tentativeRecNum) {
            newRecNum = tentativeRecNum;
            found = true;
          }
        }         // Outer for loop.

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
      var next = function(srcInfo, detId) {
        var origRecNum = currRecNum;
        if (srcInfo) {
          currRecNum = findBySourceInfo(srcInfo, 'n', detId);
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
      var prev = function(srcInfo, detId) {
        var origRecNum = currRecNum;
        if (srcInfo) {
          currRecNum = findBySourceInfo(srcInfo, 'p', detId);
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
      var first = function(srcInfo, detId) {
        var origRecNum = currRecNum;
        if (srcInfo) {
          currRecNum = findBySourceInfo(srcInfo, 'f', detId);
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
      var last = function(srcInfo, detId) {
        var origRecNum = currRecNum;
        if (srcInfo) {
          currRecNum = findBySourceInfo(srcInfo, 'l', detId);
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

      /* --------------------------------------------------------
      * getChangedFields()
      *
      * Returns a map of fields that have changed for the changed
      * object passed and optionally, pertaining to the detail id
      * passed.
      *
      * The changed object expected is what was returned by
      * notifyCallbacks() in the changed element.
      *
      * The returned changed map is a simplier version that has an
      * element per field across all data sources. This allows the
      * caller, i.e. a view, to be able to quickly ascertain whether
      * a change occurred or not. There is a loss of table information,
      * but for the fields that matter, it does not make much difference.
      *
      * Changed fields are memoized by the current record number.
      *
      * param       changed
      * param       detId
      * return      changedFields
      * -------------------------------------------------------- */
      var getChangedFields = function(changed, detId) {
        var key = "" + currRecNum;
        var changedFields = changedFieldsCache.get(key);
        if (changedFields) return changedFields;
        changedFields = {};
        _.each(changed, function(obj, tbl) {
          var flds = [];
          if (_.size(obj) > 0) {
            if (detId) {
              flds = obj[detId].fields;
            } else {
              flds = obj[_.keys(obj)[0]].fields;
            }
            _.each(flds, function(f) {
              changedFields[f] = true;
            });
          }
        });
        changedFieldsCache.put(key, changedFields);
        return changedFields;
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
        registerPubSub: registerPubSub,
        unregister: unregister,
        next: next,
        prev: prev,
        first: first,
        last: last,
        curr: curr,
        info: info,
        lookup: lookup,
        getChangedByNum: getChangedByNum,
        getChangedFields: getChangedFields
      };

    }]);

})(angular, _);
