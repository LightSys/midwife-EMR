/*
 * -------------------------------------------------------------------------------
 * actions/index.js
 *
 * Actions common to multiple domains or not specific to one domain.
 * -------------------------------------------------------------------------------
 */

import {CALL_API, Schemas} from '../middleware'


// --------------------------------------------------------
// Action types.
// --------------------------------------------------------

export const CURRENT_USER_REQUEST = 'CURRENT_USER_REQUEST'
export const CURRENT_USER_SUCCESS = 'CURRENT_USER_SUCCESS'
export const CURRENT_USER_FAILURE = 'CURRENT_USER_FAILURE'


export const SITE_MESSAGE = 'SITE_MESSAGE'
export const SYSTEM_MESSAGE = 'SYSTEM_MESSAGE'

export const AUTHENTICATION_UPDATE = 'AUTHENTICATION_UPDATE'

export const SET_COOKIES = 'SET_COOKIES'

// --------------------------------------------------------
// Actions.
// --------------------------------------------------------

// Fetches a single user from the server.
// Relies on the custom API middleware defined in ../middleware/index.js.
function fetchUser(login) {
  return {
    [CALL_API]: {
      types: [ CURRENT_USER_REQUEST, CURRENT_USER_SUCCESS, CURRENT_USER_FAILURE ],
      serverPath: login,
      schema: Schemas.USER
    }
  }
}

// Fetches a single user from the server unless it is cached.
// Relies on Redux Thunk middleware.
export function loadUser(login, requiredFields = []) {
  return (dispatch, getState) => {
    const user = getState().entities.users[login]
    if (user && requiredFields.every(key => user.hasOwnProperty(key))) {
      return null
    }

    return dispatch(fetchUser(login))
  }
}

export const siteMessage = (msg) => {
  return {
    type: SITE_MESSAGE,
    message: msg
  }
}

export const systemMessage = (msg) => {
  return {
    type: SYSTEM_MESSAGE,
    message: msg
  }
}

export const authenticationUpdate = ({authExpiry, isAuthenticated}) => {
  return {
    type: AUTHENTICATION_UPDATE,
    expiry: authExpiry,
    isAuthenticated: isAuthenticated
  }
}

// NOTE: this might not be necessary with the credentials option in the middleware.
export const setCookies = (cookies) => {
  return {
    type: SET_COOKIES,
    cookies: cookies
  }
}


