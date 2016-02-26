import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

export {
  renderText,
  renderCB,
  renderHidden
} from './formHelper'

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

export const getBreakpoint = () => {
  const size = getViewportSize()
  if (size.w <= BREAKPOINT_SMALL) return BP_SMALL
  if (size.w <= BREAKPOINT_MEDIUM) return BP_MEDIUM
  if (size.w <= BREAKPOINT_LARGE) return BP_LARGE
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

