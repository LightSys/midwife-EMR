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
  SET_IS_AUTHENTICATED,
  SET_USER_ID,
  SET_ROLE_NAME
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

export const setUserId = (id) => {
  if (! id) id = -1
  return {
    type: SET_USER_ID,
    payload: {
      id
    }
  }
}

export const setRoleName = (roleName) => {
  return {
    type: SET_ROLE_NAME,
    payload: {
      roleName
    }
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

