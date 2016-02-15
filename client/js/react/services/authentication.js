import {setCookies} from '../actions/index'

let theStore = null;

export const initializeAuth = (store) => {
  theStore = store
}

export const cookies = (cookies) => {
  theStore.dispatch(setCookies(cookies))
}

export const isAuthenticated = () => {
  const {authentication: {expiry, isAuthenticated: isAuthen}} = theStore.getState()
  return isAuthen && expiry > Date.now()
}

