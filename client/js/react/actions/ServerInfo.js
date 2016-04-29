import {
  SERVER_INFO
} from '../constants/ActionTypes'


export const setServerInfo = (serverInfo) => {
  return {
    type: SERVER_INFO,
    payload: {
      serverInfo
    }
  }
}


