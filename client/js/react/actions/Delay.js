import {isObject, isNumber, has} from 'underscore'

import {DELAY} from '../constants/ActionTypes'

/* --------------------------------------------------------
 * scheduleDelay()
 *
 * Schedules the passed action to be run delay ms later.
 *
 * param        action
 * return       function - picked up by thunk
 * -------------------------------------------------------- */
export const scheduleDelay = (action) => {
  if (! isObject(action)) return
  console.log('scheduleDelay action', action)
  return (dispatch, getState) => {
    return dispatch(action)
  }

}


