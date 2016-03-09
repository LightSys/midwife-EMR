import {
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE,
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE,
  DATA_CHANGE
} from '../constants/ActionTypes'

import {
  NOT_LOADED,
  LOADING,
  LOADED,
  SAVING
} from '../constants/index'

// --------------------------------------------------------
// status: NOT_LOADED | LOADING | LOADED | SAVING
// pending: ids that are currently being saved to the server.
// dirty: ids that other clients have changed that we have not refreshed.
//
// Note: exported for the sake of testing.
// --------------------------------------------------------
export const DEFAULT_STATUS = {
  user: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  role: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  patient: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  pregnancy: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  riskCode: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  risk: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  vaccination: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  vaccinationType: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  healthTeaching: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  medication: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  medicationType: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  pregnancyHistory: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  eventType: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  event: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  prenatalExam: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  labSuite: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  labTest: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  labTestValue: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  labTestResult: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  referral: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  schedule: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  pregnoteType: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  },
  pregnote: {
    status: NOT_LOADED,
    pending: [],
    dirty: []
  }
}

// --------------------------------------------------------
// Set the status if an entity, leaving pending field unchanged.
// --------------------------------------------------------
const setStatus = (entity, state, status) => {
  let newStatus = Object.assign({}, state)
  Object.assign(newStatus,
    {[entity]: {status: status,
      pending: state[entity].pending,
      dirty: state[entity].dirty}})
  return newStatus;
}

// --------------------------------------------------------
// Add an id to the pending field of an entity, leaving other
// fields unchanged.
// --------------------------------------------------------
const addPending = (entity, state, id) => {
  let pendings = new Set(state[entity].pending)  // Insure unique.
  let dirty = state[entity].dirty
  pendings.add(id)
  return Object.assign({}, state,
    {[entity]: {status: state[entity].status, pending: [...pendings], dirty}})
}

// --------------------------------------------------------
// Add an id to the dirty field of an entity, leaving other
// fields unchanged.
// --------------------------------------------------------
const addDirty = (entity, state, id) => {
  let dirties = new Set(state[entity].dirty)  // Insure unique.
  let pending = state[entity].pending
  dirties.add(id)
  return Object.assign({}, state,
    {[entity]: {status: state[entity].status, dirty: [...dirties], pending}})
}

// --------------------------------------------------------
// Remove an id from the pending field of an entity, leaving
// other fields unchanged.
// --------------------------------------------------------
const removePending = (entity, state, id) => {
  let pendings = new Set(state[entity].pending)  // Insure unique.
  let dirty = state[entity].dirty
  pendings.delete(id)
  return Object.assign({}, state,
    {[entity]: {status: state[entity].status, pending: [...pendings], dirty}})
}

// --------------------------------------------------------
// Remove an id from the dirty field of an entity, leaving
// other fields unchanged.
// --------------------------------------------------------
const removeDirty = (entity, state, id) => {
  let dirties = new Set(state[entity].dirty)  // Insure unique.
  let pending = state[entity].pending
  dirties.delete(id)
  return Object.assign({}, state,
    {[entity]: {status: state[entity].status, dirty: [...dirties], pending}})
}

// --------------------------------------------------------
// Tracks data status of entities.
// status: NOT_LOADED | LOADING | LOADED | SAVING
// pending: array of ids that are pending a save confirmation
//          from the server for a table.
// dirty: array of ids that other clients have changed that
//        we have not refreshed from the server yet.
// --------------------------------------------------------
const status = (state = DEFAULT_STATUS, action) => {
  let newState
  switch (action.type) {
    case LOAD_ALL_USERS_REQUEST:
      return setStatus('user', state, LOADING)
    case LOAD_ALL_USERS_SUCCESS:
      return setStatus('user', state, LOADED)
    case LOAD_ALL_USERS_FAILURE:
      return setStatus('user', state, NOT_LOADED)

    case SAVE_USER_REQUEST:
      newState = setStatus('user', state, SAVING)
      if (action.meta && action.meta.hasOwnProperty('id')) {
        const id = action.meta.id
        newState = addPending('user', newState, id)
      }
      return newState
    case SAVE_USER_SUCCESS:
      newState = setStatus('user', state, LOADED)
      if (action.meta && action.meta.hasOwnProperty('id')) {
        const id = action.meta.id
        newState = removePending('user', newState, id)
      }
      return newState
    case SAVE_USER_FAILURE:
      // Should set status back to LOADED but make sure id is still in pending.
      newState = setStatus('user', state, LOADED)
      if (action.meta && action.meta.hasOwnProperty('id')) {
        const id = action.meta.id
        newState = addPending('user', newState, id)
      }
      return newState

    case DATA_CHANGE:
      return addDirty(action.table, state, action.id)

    default:
      return state
  }
}

export default status
