import io from 'socket.io-client'

import {
  siteMessage,
  systemMessage,
  authenticationUpdate,
  dataChange
} from '../actions'

import {
  DATA_CHANGE
} from '../constants/ActionTypes'

const SITE_URL = `${window.location.origin}/site`
const SYSTEM_URL = `${window.location.origin}/system`
const DATA_URL = `${window.location.origin}/data`

const Comm = (store) => {
  const ioSite = io.connect(SITE_URL)
  const ioSystem = io.connect(SYSTEM_URL)
  const ioData = io.connect(DATA_URL)

  ioSite.on('site', (data) => {
    store.dispatch(siteMessage(data.data))
  })

  ioSystem.on('system', (data) => {
    store.dispatch(systemMessage(data.data))
  })

  ioData.on('data', (data) => {
    // TODO: refactor to a switch for efficiency.
    //
    // NOTE: this is not a Redux type, of course, but we follow the same
    // pattern for the server to client communications and use the same
    // constant for the Redux action type.
    if (data.type && data.type === DATA_CHANGE) {
      // Notification from the server that data was
      // changed by a different client.
      store.dispatch(dataChange(data))
    } else if (data.authentication) {
      store.dispatch(authenticationUpdate(data.authentication))
    }
  })

}

export default Comm

