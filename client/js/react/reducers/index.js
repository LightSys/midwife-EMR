/*
 * -------------------------------------------------------------------------------
 * reducers/index.js
 *
 * Reducers common to multiple domains or not specific to one domain. Rolls up all
 * reducers into one here.
 * -------------------------------------------------------------------------------
 */
import {combineReducers} from 'redux'
import {reducer as formReducer} from 'redux-form'

// --------------------------------------------------------
// Import Actions and Reducers from the various domains.
// --------------------------------------------------------
import {SELECTED_USER} from '../User/UserActions'
import {selectedUser} from '../User/UserReducers'

// --------------------------------------------------------
// Common Actions and Reducers across multiple domains.
// --------------------------------------------------------
import {
  SITE_MESSAGE,
  SYSTEM_MESSAGE,
  AUTHENTICATION_UPDATE,
  SET_COOKIES
} from '../actions/index'

const DEFAULT_ENTITY_STATE = {
  users: {},
  roles: {}
}

const entities = (state = DEFAULT_ENTITY_STATE, action) => {
  if (action.response && action.response.entities) {
    return Object.assign({}, state, action.response.entities)
  }
  return state
}


const siteMessage = (state = {}, action) => {
  if (action.type === SITE_MESSAGE) {
    return Object.assign({}, state, {message: action.message})
  }
  return state
}

const systemMessage = (state = {}, action) => {
  if (action.type === SYSTEM_MESSAGE) {
    return Object.assign({}, state, {message: action.message})
  }
  return state
}

const AUTHENTICATION_DEFAULT = {
  expiry: 0,
  isAuthenticated: false
}

const authentication = (state = AUTHENTICATION_DEFAULT, action) => {
  if (action.type === AUTHENTICATION_UPDATE) {
    return Object.assign({}, state, {expiry, isAuthenticated} = action)
  }
  return state;
}

const cookies = (state = {}, action) => {
  if (action.type === SET_COOKIES) {
    return Object.assign({}, state, action.cookies)
  }
  return state;
}

const RootReducer = combineReducers({
  form: formReducer,
  entities,
  siteMessage,
  systemMessage,
  authentication,
  cookies,
  selectedUser
})

export default RootReducer
