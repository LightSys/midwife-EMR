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
    'ngResource',
    'angularMoment',
    'historyControlModule',
    'historyServiceModule',
    'patientWellModule'
  ]);

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

    .filter('getGAFromLMP', ['moment', function(moment) {
      return function(lmp, rDate) {
        return getGA(edd(lmp, moment), rDate, moment);
      };
    }]);

})(angular);
