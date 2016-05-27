import 'babel-polyfill'
import React from 'react'
import {render} from 'react-dom'
import {createStore, applyMiddleware, compose} from 'redux'
import {Provider} from 'react-redux'
import thunk from 'redux-thunk'
import createLogger from 'redux-logger'
import {Router, browserHistory} from 'react-router'
import ES6Promise from 'es6-promise'
ES6Promise.polyfill()
import createSagaMiddleware from 'redux-saga'


import reducers from './reducers'
import dataMiddleware from './middleware/data'
import delayMiddleware from './middleware/delay'
import Comm from './services/comm'
import {initializeAuth} from './services/authentication'
import routes from './routes'
import breakpoint from './services/breakpoint'

import rootSaga from './sagas'

// --------------------------------------------------------
// Bring in our own Bootstrap theme and styles.
// --------------------------------------------------------
require('bootstrap3.3.6/flatly/bootstrap.css')
require('css/font-awesome.css')
require('./style.css')

// --------------------------------------------------------
// Get logging setup for development, etc.
// --------------------------------------------------------
//const logTheseTypes = [ ]
const loggerOpts = {
  //predicate: (getState, action) => logTheseTypes.indexOf(action.type) !== -1
  predicate: (getState, action) => action.meta && action.meta.dataMiddleware
}
const logger = createLogger(loggerOpts)

// --------------------------------------------------------
// Get the Redux store setup.
//
// TODO: Revise to only load devTools only in development.
// --------------------------------------------------------
const sagaMiddleware = createSagaMiddleware()
const createMiddlewareStore = compose(
  applyMiddleware(
    sagaMiddleware,
    thunk,
    dataMiddleware,
    delayMiddleware,
    logger)
  , window.devToolsExtension ? window.devToolsExtension() : f => f
  )(createStore)
const store = createMiddlewareStore(reducers)
sagaMiddleware.run(rootSaga)

// --------------------------------------------------------
// Intialize the services with the store that need it.
// --------------------------------------------------------
Comm(store)
initializeAuth(store)
breakpoint(store)

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

