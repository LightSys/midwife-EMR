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
  SET_COOKIES,
  SET_IS_AUTHENTICATED
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

export const setIsAuthenticated = (isAuthenticated) => {
  return {
    type: SET_IS_AUTHENTICATED,
    isAuthenticated
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

