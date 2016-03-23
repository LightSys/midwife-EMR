import {
  setCookies,
  setIsAuthenticated
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

export const isAuthenticated = () => {
  const {authentication: {isAuthenticated: isAuthen}} = theStore.getState()
  return isAuthen
}

