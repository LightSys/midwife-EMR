// --------------------------------------------------------
// Users and Roles.
// --------------------------------------------------------
export const SELECT_USER = 'SELECT_USER'
export const SELECT_PREGNANCY = 'SELECT_PREGNANCY'

export const LOAD_ALL_USERS_REQUEST = 'LOAD_ALL_USERS_REQUEST'
export const LOAD_ALL_USERS_SUCCESS = 'LOAD_ALL_USERS_SUCCESS'
export const LOAD_ALL_USERS_FAILURE = 'LOAD_ALL_USERS_FAILURE'

export const SAVE_USER_REQUEST = 'SAVE_USER_REQUEST'
export const SAVE_USER_SUCCESS = 'SAVE_USER_SUCCESS'
export const SAVE_USER_FAILURE = 'SAVE_USER_FAILURE'

export const USER_PASSWORD_RESET_REQUEST = 'USER_PASSWORD_RESET_REQUEST'
export const USER_PASSWORD_RESET_SUCCESS = 'USER_PASSWORD_RESET_SUCCESS'
export const USER_PASSWORD_RESET_FAILURE = 'USER_PASSWORD_RESET_FAILURE'

// Convenience constants for actions, etc.
export const LOAD_ALL_USERS_SET = [
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE
]
export const SAVE_USER_SET = [
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE
]
export const USER_PASSWORD_RESET_SET = [
  USER_PASSWORD_RESET_REQUEST,
  USER_PASSWORD_RESET_SUCCESS,
  USER_PASSWORD_RESET_FAILURE
]

// We are informed by the server that another client has changed some data.
export const DATA_CHANGE = 'DATA_CHANGE'

// --------------------------------------------------------
// Notifications.
// --------------------------------------------------------
export const ADD_NOTIFICATION = 'ADD_NOTIFICATION'
export const REMOVE_NOTIFICATION = 'REMOVE_NOTIFICATION'

// --------------------------------------------------------
// Delayed actions.
// --------------------------------------------------------
export const DELAY = 'DELAY'

// --------------------------------------------------------
// Route changes via Redux state.
// --------------------------------------------------------
export const ROUTE_CHANGE = 'ROUTE_CHANGE'

// --------------------------------------------------------
// Patient Search.
// --------------------------------------------------------
export const SEARCH_PATIENT_REQUEST = 'SEARCH_PATIENT_REQUEST'
export const SEARCH_PATIENT_SUCCESS = 'SEARCH_PATIENT_SUCCESS'
export const SEARCH_PATIENT_FAILURE = 'SEARCH_PATIENT_FAILURE'

// --------------------------------------------------------
// Pregnancy.
// --------------------------------------------------------
export const GET_PREGNANCY_REQUEST = 'GET_PREGNANCY_REQUEST'
export const GET_PREGNANCY_SUCCESS = 'GET_PREGNANCY_SUCCESS'
export const GET_PREGNANCY_FAILURE = 'GET_PREGNANCY_FAILURE'
export const CLEAR_PREGNANCY_DATA = 'CLEAR_PREGNANCY_DATA'
export const CHECK_IN_OUT_REQUEST = 'CHECK_IN_OUT_REQUEST'
export const CHECK_IN_OUT_SUCCESS = 'CHECK_IN_OUT_SUCCESS'
export const CHECK_IN_OUT_FAILURE = 'CHECK_IN_OUT_FAILURE'


// --------------------------------------------------------
// Authentication related.
// --------------------------------------------------------
export const LOGIN_REQUESTED = 'LOGIN_REQUESTED'
export const LOGIN_SUCCESS = 'LOGIN_SUCCESS'
export const LOGIN_FAILURE = 'LOGIN_FAILURE'
export const AUTHENTICATION_INIT = 'AUTHENTICATION_INIT'
export const SET_COOKIES = 'SET_COOKIES'
export const SET_IS_AUTHENTICATED = 'SET_IS_AUTHENTICATED'

// Note: will deprecate AUTHENTICATION_UPDATE
//export const AUTHENTICATION_UPDATE = 'AUTHENTICATION_UPDATE'

// --------------------------------------------------------
// Window resize related.
// --------------------------------------------------------
export const WINDOW_RESIZE = 'WINDOW_RESIZE'

// --------------------------------------------------------
// Miscellaneous.
// --------------------------------------------------------
export const SITE_MESSAGE = 'SITE_MESSAGE'
export const SYSTEM_MESSAGE = 'SYSTEM_MESSAGE'
