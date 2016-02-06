import {combineReducers} from 'redux'

import {SITE_MESSAGE, SYSTEM_MESSAGE} from '../actions/index'

const DEFAULT_ENTITY_STATE = {
  users: {}
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
const RootReducer = combineReducers({
  entities,
  siteMessage,
  systemMessage
})

export default RootReducer
