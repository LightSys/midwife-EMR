import {
  LOGIN_REQUESTED,
  LOGIN_SUCCESS,
  LOGIN_FAILURE,
  AUTHENTICATION_INIT,
  SET_IS_AUTHENTICATED,
  SET_COOKIES
} from '../constants/ActionTypes'

// Exported for testing.
export const AUTHENTICATION_DEFAULT = {
  isAuthenticated: false,
  cookies: []
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

