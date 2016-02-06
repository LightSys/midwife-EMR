import io from 'socket.io-client'

import {siteMessage, systemMessage} from '../actions'

const SITE_URL = `${window.location.origin}/site`
const SYSTEM_URL = `${window.location.origin}/system`

const Comm = (store) => {
  const ioSite = io.connect(SITE_URL)
  const ioSystem = io.connect(SYSTEM_URL)

  ioSite.on('site', (data) => {
    store.dispatch(siteMessage(data.data))
  })
  ioSystem.on('system', (data) => {
    store.dispatch(systemMessage(data.data))
  })

}

export default Comm

