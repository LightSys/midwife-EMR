import {
  LOGIN_REQUESTED,
  LOGIN_SUCCESS,
  LOGIN_FAILURE,
  AUTHENTICATION_INIT,
  SET_IS_AUTHENTICATED,
  SET_COOKIES,
  SET_USER_ID
} from '../constants/ActionTypes'

// Exported for testing.
export const AUTHENTICATION_DEFAULT = {
  isAuthenticated: false,
  cookies: [],
  userId: -1
}

const authentication = (state = AUTHENTICATION_DEFAULT, action) => {
  switch (action.type) {
    case AUTHENTICATION_INIT:
      // Sets both cookies and isAuthenticated.
      return Object.assign({}, state,
        {isAuthenticated: action.isAuthenticated, cookies: action.cookies})
      break

    case SET_IS_AUTHENTICATED:
      return Object.assign({}, state, {isAuthenticated: action.isAuthenticated})
      break

    case SET_COOKIES:
      return Object.assign({}, state, {cookies: action.cookies})
      break

    case SET_USER_ID:
      if (true) {
        const id = action.payload.id? action.payload.id: -1
        return Object.assign({}, state, {userId: id})
      }
      break

    case LOGIN_REQUESTED:
      return state
      break

    case LOGIN_SUCCESS:
      return state
      break

    case LOGIN_FAILURE:
      return state
      break

    default:
      return state
  }
}

export default authentication

