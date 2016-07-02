import {isNumber} from 'underscore'

import {
  SELECT_PREGNANCY,
  GET_PREGNANCY_REQUEST,
  GET_PREGNANCY_SUCCESS,
  GET_PREGNANCY_FAILURE,
  SAVE_PRENATAL_REQUEST,
  SAVE_PRENATAL_SUCCESS,
  SAVE_PRENATAL_FAILURE,
  CHECK_IN_OUT_REQUEST
} from '../constants/ActionTypes'

export const getPregnancy = (id) => {
  return {
    type: GET_PREGNANCY_REQUEST,
    payload: {
      id
    }
  }
}

export const savePrenatal = (preg) => {
  return {
    type: SAVE_PRENATAL_REQUEST,
    payload: {
      preg
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

export const checkInOut = (barcode, pregId) => {
  return {
    type: CHECK_IN_OUT_REQUEST,
    payload: {
      barcode,
      pregId
    }
  }
}

