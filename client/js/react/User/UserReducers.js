import {
  SELECTED_USER,
  USER_LIST_REQUEST,
  USER_LIST_SUCCESS,
  USER_LIST_FAILURE
} from './UserActions'

const DEFAULT_SELECTED_USER = 0

export const selectedUser = (state = DEFAULT_SELECTED_USER, action) => {
  if (action.type === SELECTED_USER) {
    return action.selectedUser
  }
  return state
}




