import io from 'socket.io-client'
import {normalize} from 'normalizr'

import {
  siteMessage,
  systemMessage,
  authenticationUpdate,
  dataChange
} from '../actions'

import {
  DATA_CHANGE,
  DATA_TABLE_REQUEST,
  DATA_TABLE_SUCCESS,
  DATA_TABLE_FAILURE
} from '../constants/ActionTypes'

import Schemas from '../constants/Schemas'
import {setLookupTable} from '../actions/LookupTables'

const SITE_URL = `${window.location.origin}/site`
const SYSTEM_URL = `${window.location.origin}/system`
const DATA_URL = `${window.location.origin}/data`

let ioData

const sendMsg = (msg, payload) => {
  ioData.emit(DATA_TABLE_REQUEST, JSON.stringify(payload))
}

const handleFailure = (err) => {
  // TODO: handle this properly.
  console.log(err)
}

/* --------------------------------------------------------
 * getLookupTable()
 *
 * Request that the server respond with the contents of a
 * lookup table. The server will only respond to white
 * listed tables.
 *
 * The response will arrive on the data channel.
 *
 * param       table
 * return      undefined
 * -------------------------------------------------------- */
export const getLookupTable = (table ) => {
  // --------------------------------------------------------
  // Patterned after Redux, though of course, this is not.
  // --------------------------------------------------------
  const action = {
    type: DATA_TABLE_REQUEST,
    payload: {
      table
    }
  }
  // --------------------------------------------------------
  // TODO: incorporate caching in order to reduce network calls.
  // --------------------------------------------------------
  sendMsg(DATA_TABLE_REQUEST, action)
}

const Comm = (store) => {
  const ioSite = io.connect(SITE_URL)
  const ioSystem = io.connect(SYSTEM_URL)
  ioData = io.connect(DATA_URL)

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

  ioData.on(DATA_TABLE_SUCCESS, (data) => {
    const dataObj = JSON.parse(data)
    const table = dataObj && dataObj.payload && dataObj.payload.data? dataObj.payload.data: void 0
    if (table) {
      const normalized = normalize(table, Schemas.ROLE_ARRAY)
      if (normalized) {
        store.dispatch(setLookupTable(normalized.entities))
      }
    }
  })

  ioData.on(DATA_TABLE_FAILURE, handleFailure)

}

export default Comm

