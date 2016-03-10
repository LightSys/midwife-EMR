/*
 * -------------------------------------------------------------------------------
 * Entities.js
 *
 * Top-level reducer for all entities.
 * -------------------------------------------------------------------------------
 */
import {isNumber} from 'underscore'

import {
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE,
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE
} from '../constants/ActionTypes'

// --------------------------------------------------------
// Default values. Exported for the sake of testing.
// --------------------------------------------------------
export const DEFAULT_ENTITIES = {
  user: {},
  role: {},
  patient: {},
  pregnancy: {},
  riskCode: {},
  risk: {},
  vaccination: {},
  vaccinationType: {},
  healthTeaching: {},
  medication: {},
  medicationType: {},
  pregnancyHistory: {},
  eventType: {},
  event: {},
  prenatalExam: {},
  labSuite: {},
  labTest: {},
  labTestValue: {},
  labTestResult: {},
  referral: {},
  schedule: {},
  pregnoteType: {},
  pregnote: {}
}

const entities = (state = DEFAULT_ENTITIES, action) => {
  let newState
  switch (action.type) {
    case LOAD_ALL_USERS_SUCCESS:
      newState = Object.assign({}, state)
      newState.user = action.payload.json.entities.user
      newState.role = action.payload.json.entities.role
      return newState

    case SAVE_USER_REQUEST:
      // Assumes optimist update.
      let user = Object.assign({}, state.user)
      if (action.optimist && action.payload.data &&
          action.payload.data.hasOwnProperty('id')) {
        const id = action.payload.data.id
        user[id] = action.payload.data
      }
      return Object.assign({}, state, {user: user})

    default:
      return state
  }
}

export default entities
