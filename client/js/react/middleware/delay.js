/*
 * -------------------------------------------------------------------------------
 * delay.js
 *
 * A middleware thunk handler for processing a series of delayed dispatches.
 *
 * Adapted from: http://redux.js.org/docs/advanced/Middleware.html
 * -------------------------------------------------------------------------------
 */

import {has, isNumber} from 'underscore'

/**
 * Schedules actions with { meta: { delay: N } } to be delayed by N milliseconds.
 * Makes `dispatch` return a function to cancel the timeout in this case. Does
 * allow 0 millisecond delays.
 */
const delay = store => next => action => {
  if (! action.meta ||
      ! has(action.meta, 'delay') ||
      ! isNumber(action.meta.delay)) {
    return next(action)
  }
  if (action.meta.delay < 0) action.meta.delay = 0

  let timeoutId = setTimeout(
    () => next(action),
    action.meta.delay
  )

  return function cancel() {
    clearTimeout(timeoutId)
  }
}

export default delay

