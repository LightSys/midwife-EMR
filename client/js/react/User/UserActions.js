import {isEmpty} from 'underscore'

import {CALL_API, Schemas} from '../middleware'


// --------------------------------------------------------
// Action types.
// --------------------------------------------------------
export const SELECTED_USER = 'SELECTED_USER'

export const USER_LIST_REQUEST = 'USER_LIST_REQUEST'
export const USER_LIST_SUCCESS = 'USER_LIST_SUCCESS'
export const USER_LIST_FAILURE = 'USER_LIST_FAILURE'

export const USER_SAVE_REQUEST = 'USER_SAVE_REQUEST'
export const USER_SAVE_SUCCESS = 'USER_SAVE_SUCCESS'
export const USER_SAVE_FAILURE = 'USER_SAVE_FAILURE'


// --------------------------------------------------------
// Load all users into state from the server.
// --------------------------------------------------------
function fetchUsers() {
  console.log('fetchUsers()')
  return {
    [CALL_API]: {
      types: [USER_LIST_REQUEST, USER_LIST_SUCCESS, USER_LIST_FAILURE],
      serverPath: 'user',
      schema: Schemas.USER_ARRAY
    }
  }
}

// --------------------------------------------------------
// Load all users into state from the server. Do nothing if
// the users are already in state.
// --------------------------------------------------------
export function loadUsers() {
  console.log('loadUsers()')
  return (dispatch, getState) => {
    const users = getState().entities.users
    if (users && ! isEmpty(users)) return null
    return dispatch(fetchUsers())
  }
}

export const selectUser = (userId) => {
  return {
    type: SELECTED_USER,
    selectedUser: userId
  }
}

// --------------------------------------------------------
// Save a user to the server.
// --------------------------------------------------------
export const saveUser = (user) => {
  console.log('saveUser(): ', user)
  return {
    [CALL_API]: {
      types: [USER_SAVE_REQUEST, USER_SAVE_SUCCESS, USER_SAVE_FAILURE],
      serverPath: `user/${user.id}`,
      schema: Schemas.USER,
      method: 'PUT',
      user
    }
  }
}



