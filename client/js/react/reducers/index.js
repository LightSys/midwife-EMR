/*
 * -------------------------------------------------------------------------------
 * reducers/index.js
 *
 * Reducers common to multiple domains or not specific to one domain. Rolls up all
 * reducers into one here.
 * -------------------------------------------------------------------------------
 */
import {combineReducers} from 'redux'
import optimist from 'redux-optimist'

// --------------------------------------------------------
// Import Actions and Reducers from the various domains.
// --------------------------------------------------------
import selected from './Selected'
import entities from './Entities'
import status from './Status'
import notifications from './Notifications'
import authentication from './Authentication'
import breakpoint from './Breakpoint'
import search from './Search'
import route from './Route'
import serverInfo from './ServerInfo'

// --------------------------------------------------------
// Common Actions and Reducers across multiple domains.
// --------------------------------------------------------
import {
  SITE_MESSAGE,
  SYSTEM_MESSAGE,
  AUTHENTICATION_UPDATE,
  SET_COOKIES
} from '../constants/ActionTypes'


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

// --------------------------------------------------------
// TODO: resolve issue with node_modules/redux-optimist/.babelrc
// which was causing compile failures to due using a Babel 5.x
// option named "optional" which caused my Babel 6.x configuration
// to fail. As a hack, I renamed .babelrc to RENAMED_bablerc.
// --------------------------------------------------------
const RootReducer = optimist(combineReducers({
  authentication,
  breakpoint,
  entities,
  notifications,
  route,
  search,
  selected,
  serverInfo,
  siteMessage,
  status,
  systemMessage
}))

export default RootReducer
