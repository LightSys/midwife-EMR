import io from 'socket.io-client'

import {
  siteMessage,
  systemMessage,
  authenticationUpdate
} from '../actions'

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
    if (data.authentication) {
      store.dispatch(authenticationUpdate(data.authentication))
    }
  })

}

export default Comm

