import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

export {
  makeGetAction,
  makePostAction
} from './actionHelper'

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

