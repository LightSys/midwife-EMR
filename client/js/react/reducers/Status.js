import {
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE,
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE
} from '../constants/ActionTypes'

import {
  NOT_LOADED,
  LOADING,
  LOADED,
  SAVING
} from '../constants/index'

const DEFAULT_STATUS = {
  users: {
    status: NOT_LOADED,
    dirty: []
  },
  roles: {
    status: NOT_LOADED,
    dirty: []
  },
  patients: {
    status: NOT_LOADED,
    dirty: []
  },
  pregnancies: {
    status: NOT_LOADED,
    dirty: []
  },
  riskCodes: {
    status: NOT_LOADED,
    dirty: []
  },
  risks: {
    status: NOT_LOADED,
    dirty: []
  },
  vaccinations: {
    status: NOT_LOADED,
    dirty: []
  },
  vaccinationTypes: {
    status: NOT_LOADED,
    dirty: []
  },
  healthTeachings: {
    status: NOT_LOADED,
    dirty: []
  },
  medications: {
    status: NOT_LOADED,
    dirty: []
  },
  medicationTypes: {
    status: NOT_LOADED,
    dirty: []
  },
  pregnancyHistories: {
    status: NOT_LOADED,
    dirty: []
  },
  eventTypes: {
    status: NOT_LOADED,
    dirty: []
  },
  events: {
    status: NOT_LOADED,
    dirty: []
  },
  prenatalExams: {
    status: NOT_LOADED,
    dirty: []
  },
  labSuites: {
    status: NOT_LOADED,
    dirty: []
  },
  labTests: {
    status: NOT_LOADED,
    dirty: []
  },
  labTestValues: {
    status: NOT_LOADED,
    dirty: []
  },
  labTestResults: {
    status: NOT_LOADED,
    dirty: []
  },
  referrals: {
    status: NOT_LOADED,
    dirty: []
  },
  schedules: {
    status: NOT_LOADED,
    dirty: []
  },
  pregnoteTypes: {
    status: NOT_LOADED,
    dirty: []
  },
  pregnotes: {
    status: NOT_LOADED,
    dirty: []
  }
}

// --------------------------------------------------------
// Set the status if an entity, leaving dirty field unchanged.
// --------------------------------------------------------
const setStatus = (entity, state, status) => {
  return Object.assign({}, state, {[entity]: {status: status, dirty: state[entity].dirty}})
}

// --------------------------------------------------------
// Add an id to the dirty field of an entity, leaving status
// field unchanged.
// --------------------------------------------------------
const addDirty = (entity, state, id) => {
  let dirties = new Set(state[entity].dirty)  // Insure unique.
  dirties.add(id)
  return Object.assign({}, state, {[entity]: {status: state[entity].status, dirty: [...dirties]}})
}

// --------------------------------------------------------
// Remove an id from the dirty field of an entity, leaving
// status field unchanged.
// --------------------------------------------------------
const removeDirty = (entity, state, id) => {
  let dirties = new Set(state[entity].dirty)  // Insure unique.
  dirties.delete(id)
  return Object.assign({}, state, {[entity]: {status: state[entity].status, dirty: [...dirties]}})
}

// --------------------------------------------------------
// Tracks data status of entities.
// status: NOT_LOADED | LOADING | LOADED | SAVING
// dirty: array of ids that are dirty for a table.
// --------------------------------------------------------
const status = (state = DEFAULT_STATUS, action) => {
  let newState
  switch (action.type) {
    case LOAD_ALL_USERS_REQUEST:
      return setStatus('users', state, LOADING)
    case LOAD_ALL_USERS_SUCCESS:
      return setStatus('users', state, LOADED)
    case LOAD_ALL_USERS_FAILURE:
      return setStatus('users', state, NOT_LOADED)

    case SAVE_USER_REQUEST:
      newState = setStatus('users', state, SAVING)
      if (action.meta && action.meta.hasOwnProperty('id')) {
        const id = action.meta.id
        newState = addDirty('users', newState, id)
      }
      return newState
    case SAVE_USER_SUCCESS:
      newState = setStatus('users', state, LOADED)
      if (action.meta && action.meta.hasOwnProperty('id')) {
        const id = action.meta.id
        newState = removeDirty('users', newState, id)
      }
      return newState
    case SAVE_USER_FAILURE:
      return setStatus('users', state, LOADED)

    default:
      return state
  }
}

export default status
