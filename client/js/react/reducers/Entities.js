/*
 * -------------------------------------------------------------------------------
 * Entities.js
 *
 * Top-level reducer for all entities.
 * -------------------------------------------------------------------------------
 */
import {isNumber, each, keys} from 'underscore'

import {
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE,
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE,
  CLEAR_PREGNANCY_DATA,
  GET_PREGNANCY_REQUEST,
  GET_PREGNANCY_SUCCESS,
  GET_PREGNANCY_FAILURE,
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

const PREGNANCY_TABLES = [
  'patient',
  'pregnancy',
  'riskCode',
  'risk',
  'vaccination',
  'vaccinationType',
  'healthTeaching',
  'medication',
  'medicationType',
  'pregnancyHistory',
  'eventType',
  'event',
  'prenatalExam',
  'labSuite',
  'labTest',
  'labTestValue',
  'labTestResult',
  'referral',
  'schedule',
  'pregnoteType',
  'pregnote'
]

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

    case CLEAR_PREGNANCY_DATA:
      // Clear all pregnancy tables.
      if (true) {
        const newState = Object.assign({}, state)
        each(PREGNANCY_TABLES, (tbl) => {
          newState[tbl] = {}
        })
        return newState
      }

    case GET_PREGNANCY_SUCCESS:
      // Add the pregnancy record and related records to state.
      // TODO: ensure that this properly handles one to many relationships.
      if (true) {
        const newState = Object.assign({}, state)
        if (action.payload && action.payload.entities && action.payload.entities.pregnancy) {
          each(keys(action.payload.entities), (tbl) => {
            each(action.payload.entities[tbl], (rec, id) => {
              newState[tbl][id] = rec
            })
          })
          return newState
        }
        return state
      }

    default:
      return state
  }
}

export default entities
