import {WINDOW_RESIZE} from '../constants/ActionTypes'

import {
  BP_UNSET,
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

import {getBreakpoint} from '../utils/index'

export const windowResize = (w, h) => {
  const bp = getBreakpoint(w)

  return {
    type: WINDOW_RESIZE,
    payload: {w, h, bp}
  }
}

