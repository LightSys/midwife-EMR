// --------------------------------------------------------
// Users and Roles.
// --------------------------------------------------------
export const SELECT_USER = 'SELECT_USER'

export const LOAD_ALL_USERS_REQUEST = 'LOAD_ALL_USERS_REQUEST'
export const LOAD_ALL_USERS_SUCCESS = 'LOAD_ALL_USERS_SUCCESS'
export const LOAD_ALL_USERS_FAILURE = 'LOAD_ALL_USERS_FAILURE'

export const SAVE_USER_REQUEST = 'SAVE_USER_REQUEST'
export const SAVE_USER_SUCCESS = 'SAVE_USER_SUCCESS'
export const SAVE_USER_FAILURE = 'SAVE_USER_FAILURE'

// Convenience constants for actions, etc.
export const LOAD_ALL_USERS_SET = [LOAD_ALL_USERS_REQUEST, LOAD_ALL_USERS_SUCCESS, LOAD_ALL_USERS_FAILURE]
export const SAVE_USER_SET = [SAVE_USER_REQUEST, SAVE_USER_SUCCESS, SAVE_USER_FAILURE]

// We are informed by the server that another client has changed some data.
export const DATA_CHANGE = 'DATA_CHANGE'


// --------------------------------------------------------
// Miscellaneous.
// --------------------------------------------------------
export const SITE_MESSAGE = 'SITE_MESSAGE'
export const SYSTEM_MESSAGE = 'SYSTEM_MESSAGE'
export const AUTHENTICATION_UPDATE = 'AUTHENTICATION_UPDATE'
export const SET_COOKIES = 'SET_COOKIES'
