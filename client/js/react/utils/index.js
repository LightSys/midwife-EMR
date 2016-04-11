import moment from 'moment'
import _ from 'underscore'


import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

// --------------------------------------------------------
// These are our breakpoints, but we never reference the
// numbers themselves except here.
// --------------------------------------------------------
const BREAKPOINT_SMALL = 480
const BREAKPOINT_MEDIUM = 600
const BREAKPOINT_LARGE = 992

// --------------------------------------------------------
// Passed a width, return the breakpoint. If no width is
// passed, gets it from getViewportSize().
// --------------------------------------------------------
export const getBreakpoint = (w) => {
  if (typeof w === 'undefined') w = getViewportSize().w
  if (w <= BREAKPOINT_SMALL) return BP_SMALL
  if (w <= BREAKPOINT_MEDIUM) return BP_MEDIUM
  if (w <= BREAKPOINT_LARGE) return BP_LARGE
  return BP_LARGE
}


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
export const getViewportSize = (w=window) => {
  // This works for all browsers except IE8 and before
  if (w.innerWidth !== null) return {w: w.innerWidth, h:w.innerHeight};

  // For IE (or any browser) in Standards mode
  const d = w.document;
  if (d.compatMode == "CSS1Compat") {
    return {w: d.documentElement.clientWidth, h: d.documentElement.clientHeight};
  }

  // For browsers in Quirks mode
  return {w: d.body.clientWidth, h: d.body.clientWidth};
}


/* --------------------------------------------------------
 * getUniqueId()
 *
 * Returns an unitque id for use with redux-optimist or
 * whatever else needs a non-repeating number.
 * -------------------------------------------------------- */
let nextUniqueId = 1
export const getUniqueId = () => {
  return nextUniqueId++
}

/* --------------------------------------------------------
 * removeClass()
 *
 * Remove the specified class from the specified element,
 * if it exists. Note that this modifies the element that
 * is passed.
 *
 * param       element
 * param       className
 * return      undefined
 * -------------------------------------------------------- */
export const removeClass = (element, className) => {
  element.className = element
    .className
    .split(' ')
    .filter((c) => {return c !== className})
    .join(' ')
}

/* --------------------------------------------------------
 * formatDate()
 *
 * Format the date passed to the 'MM-DD-YYYY' format.
 *
 * param       d  - Date object or can be turned into a Date
 * return      string
 * -------------------------------------------------------- */
export const formatDate = (d) => {
  if (! d) return ''
  const mDate = moment(d)
  if (! mDate.isValid()) return ''
  return mDate.format('MM-DD-YYYY')
}

/* --------------------------------------------------------
 * formatDohID()
 *
  * Return the specified dohID formatted per the usual spec,
 * which is xx-xx-xx.
 *
 * If useAltFormat is true, the alternate format for Phil
 * Health is used which is xx-xxxx.
 *
 * param      dohID
 * param      useAltFormat  - boolean
 * return     formatted string
 * -------------------------------------------------------- */
export const formatDohID = (dohID, useAltFormat) => {
  if (! useAltFormat) {
    return dohID? dohID.slice(0,2) + '-' + dohID.slice(2,4) + '-' + dohID.slice(4): '';
  } else {
    return dohID? dohID.slice(0,2) + '-' + dohID.slice(2): '';
  }
}

/* --------------------------------------------------------
 * age()
 *
 * Returns the age in years as a string given the date of
 * birth in ISO 8601 format as a string. Invalid formats
 * passed will result in an emtpy string being returned.
 *
 * param       dob
 * return      age
 * -------------------------------------------------------- */
export const age = (dob) => {
  if (! dob) return ''
  if (! moment(dob).isValid()) return ''
  return moment().diff(dob, 'years')
}

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
 * param      edd - estimated due date as JS Date or Moment obj
 * param      rDate - the reference date use for the calculation
 * return     GA - as a string in ww d/7 format
 * -------------------------------------------------------- */
export const getGA = (edd, rDate) => {
  if (! edd) throw new Error('getGA() must be called with an estimated due date.');
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
  return weeks + ' ' + days + '/7';
}

