/*
 * -------------------------------------------------------------------------------
 * actions/index.js
 *
 * Actions common to multiple domains or not specific to one domain.
 * -------------------------------------------------------------------------------
 */

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

export const setCookies = (cookies) => {
  return {
    type: SET_COOKIES,
    cookies: cookies
  }
}


