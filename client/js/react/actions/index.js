/*
 * -------------------------------------------------------------------------------
 * actions/index.js
 *
 * Actions common to multiple domains or not specific to one domain.
 * -------------------------------------------------------------------------------
 */

import {
  DATA_CHANGE,
  SITE_MESSAGE,
  SYSTEM_MESSAGE,
  AUTHENTICATION_UPDATE,
  SET_COOKIES
} from '../constants/ActionTypes'

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

export const dataChange = (data) => {
  return {
    type: DATA_CHANGE,
    table: data.table,
    id: data.id
  }
}

