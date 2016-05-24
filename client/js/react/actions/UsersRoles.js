import {isEmpty, isNumber} from 'underscore'

import {Schemas} from '../constants/index'
import {
  makeGetAction,
  makePostAction,
  makeSimplePostAction
} from '../utils/actionHelper'
import {
  SELECT_USER,
  LOAD_ALL_USERS_SET,
  SAVE_USER_SET,
  ADD_USER_REQUEST,
  USER_PASSWORD_RESET_SET,
  LOAD_USER_PROFILE_REQUEST
} from '../constants/ActionTypes'



// --------------------------------------------------------
// Sync action creators.
// --------------------------------------------------------

export const selectUser = (userId) => {
  if (! isNumber(userId)) userId = -1   // Default unselects the user.
  return {
    type: SELECT_USER,
    userId: userId
  }
}

// --------------------------------------------------------
// Async action creators.
// --------------------------------------------------------

// This is handled by the Profile saga.
export const loadUserProfile = () => {
  return {
    type: LOAD_USER_PROFILE_REQUEST
  }
}

export const loadAllUsersRoles = () => {
  return makeGetAction(
    LOAD_ALL_USERS_SET,                       // types
    (state) => true,                          // test
    'user',                                   // path
    Schemas.USER_ARRAY                        // schema
  )
}

export const saveUser = (user) => {
  return makePostAction(
    SAVE_USER_SET,                            // types
    (state) => true,                          // test
    'user',                                   // path
    Schemas.USER,                             // schema
    {},                                       // options
    user,                                     // data
    {id: user.id}                             // meta object additions
  )
}

export const addUser = (user) => {
  return {
    type: ADD_USER_REQUEST,
    payload: {
      user
    }
  }
}

export const resetUserPassword = (id, password) => {
  return makeSimplePostAction(
    USER_PASSWORD_RESET_SET,                  // types
    `user/${id}/passwordreset`,               // path
    {id, password},                           // data
    true                                      // notify
  )
}

export const resetProfilePassword = (id, password) => {
  return makeSimplePostAction(
    USER_PASSWORD_RESET_SET,                  // types
    `profile/passwordreset`,                  // path
    {id, password},                           // data
    true                                      // notify
  )
}

export const saveProfile = (profile) => {
  return makePostAction(
    SAVE_USER_SET,                            // types
    (state) => true,                          // test
    'profile',                                // path
    Schemas.USER,                             // schema
    {},                                       // options
    profile,                                  // data
    {id: profile.id, noIdInUrl: true}         // meta object additions
  )
}

