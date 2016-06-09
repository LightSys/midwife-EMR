import {
  setCookies,
  setIsAuthenticated,
  setUserId,
  setRoleName
} from '../actions/index'

// Our singleton reference to the Redux store.
let theStore = null;

export const initializeAuth = (store) => {
  theStore = store
}

export const cookies = (cookies) => {
  theStore.dispatch(setCookies(cookies))
}

export const initAuthenticated = (isAuthenticated) => {
  theStore.dispatch(setIsAuthenticated(isAuthenticated))
}

export const initUserId = (id) => {
  theStore.dispatch(setUserId(id))
}

export const initRoleName = (roleName) => {
  theStore.dispatch(setRoleName(roleName))
}

export const isAuthenticated = () => {
  const {authentication: {isAuthenticated: isAuthen}} = theStore.getState()
  return isAuthen
}

