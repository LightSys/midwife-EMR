;(function(angular) {

  'use strict';

  /* --------------------------------------------------------
   * edd()
   *
   * Returns the estimated due date as a Date object based
   * upon the last mentral period date passed.
   *
   * param       lmp
   * param       moment
   * return      edd
   * -------------------------------------------------------- */
  var edd = function(lmp, moment) {
    if (! lmp) return '';
    return moment(lmp).add(280, 'days').toDate();
  };


/* --------------------------------------------------------
 * getGA()
 *
 * Returns the gestational age as a string in the format
 * 'ww d/7' where ww is the week and d is the day of the
 * current week, e.g. 38 2/7 or 32 5/7.
 *
 * Uses a reference date, which is either passed or if
 * not passed it is assumed to be today. The reference
 * date is the date that the gestational age should be
 * computed for. In other words, given the estimated
 * due date and the reference date, what is the
 * gestational age from the perspective of the reference
 * date.
 *
 * Calculation assumes a 40 week pregnancy and subtracts
 * the refDate from the estimated due date, which is
 * also passed as a parameter. Params edd and rDate can be
 * Moment objects, JS Date objects, or strings in YYYY-MM-DD
 * format.
 *
 * Note: if parameters are not 'date-like' per above specifications,
 * will return an empty string.
 *
 * Note: if weeks calculation is over 46, assumes erroneous
 * input and returns 'Error'.
 *
 * param      edd - estimated due date as JS Date or Moment obj
 * param      rDate - the reference date use for the calculation
 * param      moment
 * return     GA - as a string in ww d/7 format
 * -------------------------------------------------------- */
  var getGA = function(edd, rDate, moment) {
    if (! edd) {
      return;
    }
    var estDue
      , refDate
      , tmpDate
      ;
    // Sanity check for edd.
    if (typeof edd === 'string' && /....-..-../.test(edd)) {
      estDue = moment(edd, 'YYYY-MM-DD');
    }
    if (moment.isMoment(edd)) estDue = edd.clone();
    if (_.isDate(edd)) estDue = moment(edd);
    if (! estDue) return '';

    // Sanity check for rDate.
    if (rDate) {
      if (typeof rDate === 'string' && /....-..-../.test(rDate)) {
        refDate = moment(rDate, 'YYYY-MM-DD');
      }
      if (moment.isMoment(rDate)) refDate = rDate.clone();
      if (_.isDate(rDate)) refDate = moment(rDate);
      if (! refDate) return '';
    } else {
      refDate = moment();
    }

    // --------------------------------------------------------
    // Sanity check for reference date before pregnancy started.
    // --------------------------------------------------------
    tmpDate = estDue.clone();
    if (refDate.isBefore(tmpDate.subtract(280, 'days'))) {
      return '0 0/7';
    }

    var weeks = Math.abs(40 - estDue.diff(refDate, 'weeks') - 1)
      , days = Math.abs(estDue.diff(refDate.add(40 - weeks, 'weeks'), 'days'))
      ;
    if (_.isNaN(weeks) || ! _.isNumber(weeks)) return '';
    if (_.isNaN(days) || ! _.isNumber(days)) return '';
    if (days >= 7) {
      weeks++;
      days = days - 7;
    }
    if (weeks > 46) return "Error";
    return weeks + ' ' + days + '/7';
  };

  angular.module('midwifeEmr', [
    'angularMoment',
    'ui.router',
    'historyControlModule',
    'historyServiceModule',
    'changeRoutingServiceModule',
    'patientWellModule'
  ]);


  // --------------------------------------------------------
  // Debugging for UI Router.
  // --------------------------------------------------------
  angular.module('midwifeEmr')
    .run(function($rootScope) {
      $rootScope.$on("$stateChangeError", console.log.bind(console));

      $rootScope.$on('$stateChangeStart',
        function(event, toState, toParams, fromState, fromParams){
          //console.dir(event);
          //console.dir(toState);
          //console.dir(toParams);
          //console.dir(fromState);
          //console.dir(fromParams);
          //event.preventDefault();
      });
    });

  // --------------------------------------------------------
  // Various filters.
  // --------------------------------------------------------
  angular.module('midwifeEmr')
    // --------------------------------------------------------
    // abs filter
    // https://stackoverflow.com/a/27358041
    // --------------------------------------------------------
    .filter('abs', function() {
      return function(val) {
        return Math.abs(val);
      };
    })

    .filter('dohFormatted', function() {
      return function(val) {
        return val? val.slice(0,2) + '-' + val.slice(2,4) + '-' + val.slice(4): '';
      };
    })

    .filter('edd', ['moment', function(moment) {
      return function(lmp) {
        return edd(lmp, moment);
      };
    }])

    .filter('onlyValidDate', ['moment', function(moment) {
      return function(theDate) {
        var m = moment(theDate);
        if (m.isValid()) return theDate;
        return '';
      };
    }])

    /* --------------------------------------------------------
     * secondaryHistorical()
     *
     * Return the historical records at the state that they
     * were in at the replacedAt timestamp.
     *
     * Note: assumes that input records are already sorted
     * by replacedAt field.
     * -------------------------------------------------------- */
    .filter('secondaryHistorical', ['moment', function(moment) {
      return function(data, replacedAt, sortFld) {
        var recs = [];
        var tmp = {};
        var maxDate = moment(replacedAt);

        angular.forEach(data, function(rec) {
          if (! moment(rec.replacedAt).isAfter(maxDate)) {
            if (tmp[rec.id]) {
              if (rec.op === 'D') {
                delete tmp[rec.id];
              } else {
                // Replacement of record.
                tmp[rec.id] = rec;
              }
            } else {
              // First encounter of this record id.
              tmp[rec.id] = rec;
            }
          }
        });

        // --------------------------------------------------------
        // Convert to an array and sort by sortFld.
        // --------------------------------------------------------
        angular.forEach(Object.keys(tmp), function(key) {
          recs.push(tmp[key]);
        });
        recs.sort(function(a, b) {
          if (a[sortFld] < b[sortFld]) return -1;
          if (a[sortFld] > b[sortFld]) return 1;
          return 0;
        });
        return recs;
      };
    }])

    /* --------------------------------------------------------
     * riskTypeHistorical()
     *
     * Returns historical risks that match the type passed,
     * were recorded before the date/time passed, and are unique
     * per id. The most recent id is used.
     *
     * NOTE: assumes that input risks are sorted by replacedAt.
     * -------------------------------------------------------- */
    .filter('riskTypeHistorical', ['moment', function(moment) {
      return function(risks, type, replacedAt) {
        var recs = [];
        var tmp = {};
        if (! risks || risks.length && risks.length === 0) return [];

        // --------------------------------------------------------
        // Eliminate risks by type, replacedAt date/time, and retain
        // the most recent id.
        // --------------------------------------------------------
        var maxDate = moment(replacedAt);
        angular.forEach(risks, function(risk) {
          if (! moment(risk.replacedAt).isAfter(maxDate)) {
            // Only accept our type.
            if (risk.riskType === type) {
              if (tmp[risk.id]) {
                if (risk.op === 'D') {
                  // Risk was deleted in history so remove it.
                  delete tmp[risk.id];
                } else {
                  // Risk was updated so replace it.
                  tmp[risk.id] = risk;
                }
              } else {
                // Risk was inserted.
                tmp[risk.id] = risk;
              }
            }
          }
        });
        // --------------------------------------------------------
        // Convert to an array and sort by name.
        // --------------------------------------------------------
        angular.forEach(Object.keys(tmp), function(key) {
          recs.push(tmp[key]);
        });
        recs.sort(function(a, b) {
          if (a.name < b.name) return -1;
          if (a.name > b.name) return 1;
          return 0;
        });
        return recs;
      };
    }])

    .filter('getGAFromLMP', ['moment', function(moment) {
      return function(lmp, rDate) {
        var edDate = edd(lmp, moment);
        if (! edDate) return '';
        return getGA(edDate, rDate, moment);
      };
    }]);

})(angular);
