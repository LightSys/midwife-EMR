import {isEmpty, isNumber, noop} from 'underscore'

import {Schemas} from '../constants/index'
import {makeGetAction, makePostAction} from '../utils/index'
import {
  SELECT_USER,
  LOAD_ALL_USERS_SET,
  SAVE_USER_SET,
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

export const loadAllUsersRoles = () => {
  return makeGetAction(
    LOAD_ALL_USERS_SET,                       // types
    (state) => isEmpty(state.entities.user),  // test
    'user',                                   // path
    Schemas.USER_ARRAY                        // schema
  )
}

export const saveUser = (user) => {
  return makePostAction(
    SAVE_USER_SET,                            // types
    noop,                                     // test
    'user',                                   // path
    Schemas.USER,                             // schema
    {},                                       // options
    user,                                     // data
    {id: user.id}                             // meta object additions
  )
}


