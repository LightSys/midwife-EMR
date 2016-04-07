import {isNumber} from 'underscore'

import {
  SELECT_PREGNANCY,
  GET_PREGNANCY_REQUEST,
  GET_PREGNANCY_SUCCESS,
  GET_PREGNANCY_FAILURE
} from '../constants/ActionTypes'

export const getPregnancy = (id) => {
  return {
    type: GET_PREGNANCY_REQUEST,
    payload: {
      id
    }
  }
}

export const selectPregnancy = (pregId) => {
  if (! isNumber(pregId)) pregId = -1   // Default unselects the pregnancy.
  return {
    type: SELECT_PREGNANCY,
    pregId
  }
}

