import {isNumber, contains} from 'underscore'

import {
  ADD_NOTIFICATION,
  REMOVE_NOTIFICATION
} from '../constants/ActionTypes'
import {scheduleDelay} from './Delay'
import {getUniqueId} from '../utils/index'

// --------------------------------------------------------
// Types of notification messages (they match Bootstrap).
// Exported for testing.
// --------------------------------------------------------
export const SUCCESS = 'success'
export const WARNING = 'warning'
export const INFO = 'info'
export const DANGER = 'danger'

const addNotification = (msg, msgType, closeable=false) => {
  if (contains([SUCCESS, WARNING, INFO, DANGER], msgType)) {
    // Assign an id so that it can be removed later.
    const id = getUniqueId()
    return {
      type: ADD_NOTIFICATION,
      payload: {
        id,
        msg,
        msgType,
        closeable
      }
    }
  }
  return void 0
}

/* --------------------------------------------------------
 * removeNotification()
 *
 * Remove the specified notification after delay ms. Usually
 * used in conjunction with one of the add notification functions.
 * The id passed to removeNotification is in action.payload.id of 
 * the add notification.
 *
 * param       id
 * param       delay
 * return      action object
 * -------------------------------------------------------- */
export const removeNotification = (id, delay) => {
  return {
    type: REMOVE_NOTIFICATION,
    payload: {
      id
    },
    meta: {
      delay
    }
  }
}

export const addSuccessNotification = (msg, closeable) => {
  return addNotification(msg, SUCCESS, closeable)
}

export const addWarningNotification = (msg, closeable) => {
  return addNotification(msg, WARNING, closeable)
}

export const addInfoNotification = (msg, closeable) => {
  return addNotification(msg, INFO, closeable)
}

export const addDangerNotification = (msg, closeable) => {
  return addNotification(msg, DANGER, closeable)
}

