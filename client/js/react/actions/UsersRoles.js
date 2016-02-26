import {isEmpty, isNumber, noop} from 'underscore'

import {Schemas} from '../constants/index'
import {makeGetAction, makePostAction} from '../utils/index'
import {
  SELECT_USER,
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE,
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE
} from '../constants/ActionTypes'



// --------------------------------------------------------
// Exported action creators.
// --------------------------------------------------------

export const selectUser = (userId) => {
  if (! isNumber(userId)) userId = -1   // Default unselects the user.
  return {
    type: SELECT_USER,
    userId: userId
  }
}

export const loadAllUsersRoles = () => {
  return makeGetAction(
    [LOAD_ALL_USERS_REQUEST, LOAD_ALL_USERS_SUCCESS, LOAD_ALL_USERS_FAILURE],
    (state) => isEmpty(state.entities.users),
    'user',
    Schemas.USER_ARRAY
  )
}

export const saveUser = (user) => {
  return makePostAction(
    [SAVE_USER_REQUEST, SAVE_USER_SUCCESS, SAVE_USER_FAILURE],  // types
    noop,                                                       // test
    'user',                                                     // path
    Schemas.USER,                                               // schema
    {},                                                         // options
    user                                                        // data
  )
}


