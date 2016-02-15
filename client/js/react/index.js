import React from 'react'
import {render} from 'react-dom'
import {createStore, applyMiddleware, compose} from 'redux'
import {Provider} from 'react-redux'
import thunk from 'redux-thunk'
import createLogger from 'redux-logger'
import {Router, browserHistory} from 'react-router'

import reducers from './reducers'
import api from './middleware'
import Comm from './services/comm'
import {initializeAuth} from './services/authentication'
import routes from './routes'

import {
  USER_SAVE_REQUEST,
  USER_SAVE_SUCCESS,
  USER_SAVE_FAILURE
} from './User/UserActions'

// --------------------------------------------------------
// Bring in our own Bootstrap theme and styles.
// --------------------------------------------------------
require('bootstrap3.3.6/flatly/bootstrap.css')
require('./style.css')

// --------------------------------------------------------
// Get logging setup for development, etc.
// --------------------------------------------------------
const logTheseTypes = [
  USER_SAVE_REQUEST,
  USER_SAVE_SUCCESS,
  USER_SAVE_FAILURE
]
const loggerOpts = {
  predicate: (getState, action) => logTheseTypes.indexOf(action.type) !== -1
}
const logger = createLogger(loggerOpts)

// --------------------------------------------------------
// Get the Redux store setup.
//
// TODO: Revise to only load devTools only in development.
// --------------------------------------------------------
const createMiddlewareStore = compose(
  applyMiddleware(
    thunk,
    api,
    logger)
  , window.devToolsExtension ? window.devToolsExtension() : f => f
  )(createStore)
const store = createMiddlewareStore(reducers)

// --------------------------------------------------------
// Intialize the services with the store that need it.
// --------------------------------------------------------
Comm(store)
initializeAuth(store)

// --------------------------------------------------------
// Render the application.
// --------------------------------------------------------
render(
  <Provider store={store}>
    <Router
      history={browserHistory}
      routes={routes}
    />
  </Provider>
  , root
)

