import React from 'react'
import ReactDOM from 'react-dom'
import {createStore, applyMiddleware} from 'redux'
import {Provider} from 'react-redux'
import thunk from 'redux-thunk'
import createLogger from 'redux-logger'

import App from './components/app'
import reducers from './reducers'
import api from './middleware'
import Comm from './services/comm'
import {
  SITE_MESSAGE,
  SYSTEM_MESSAGE
} from './actions'

// --------------------------------------------------------
// Bring in our own Bootstrap theme and styles.
// --------------------------------------------------------
require('bootstrap3.3.6/flatly/bootstrap.css')
require('./style.css')

// --------------------------------------------------------
// Get configuration data passed in from the outside.
// --------------------------------------------------------
const root = document.getElementById('root')
const cfgData = JSON.parse(root.getAttribute('data-cfg'))

// --------------------------------------------------------
// Get logging setup for development, etc.
// --------------------------------------------------------
const logTheseTypes = [
  SYSTEM_MESSAGE
]
const loggerOpts = {
  predicate: (getState, action) => logTheseTypes.indexOf(action.type) !== -1
}
const logger = createLogger(loggerOpts)

// --------------------------------------------------------
// Get the Redux store setup.
// --------------------------------------------------------
const createMiddlewareStore = applyMiddleware(
  thunk,
  api,
  logger
)(createStore)
const store = createMiddlewareStore(reducers)

// --------------------------------------------------------
// Bring up the communications layer. We pass the store so
// that it can dispatch data.
// --------------------------------------------------------
Comm(store)

// --------------------------------------------------------
// Render the application.
// --------------------------------------------------------
ReactDOM.render(
  <Provider store={store}>
    <App cfg={cfgData.cfg} />
  </Provider>
  , root
)

