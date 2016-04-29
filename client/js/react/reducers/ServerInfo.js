import {
  SERVER_INFO
} from '../constants/ActionTypes'

export const DEFAULT_SERVER_INFO = {}

const serverInfo = (state=DEFAULT_SERVER_INFO, action) => {
  switch (action.type) {
    case SERVER_INFO:
      return Object.assign({}, state, action.payload.serverInfo)

    default:
      return state
  }
}

export default serverInfo
