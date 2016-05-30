import {
  DATA_TABLE_REQUEST,
  DATA_TABLE_SUCCESS,
  DATA_TABLE_FAILURE
} from '../constants/ActionTypes'


export const getLookupTable = (table) => {
  return {
    type: DATA_TABLE_REQUEST,
    payload: {
      table
    }
  }
}

export const setLookupTable = (entities) => {
  return {
    type: DATA_TABLE_SUCCESS,
    payload: {
      entities
    }
  }
}

