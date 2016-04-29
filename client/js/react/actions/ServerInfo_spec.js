import expect from 'expect'

import {
  SERVER_INFO
} from '../constants/ActionTypes'

import {
  setServerInfo
} from './ServerInfo'


describe('actions/ServerInfo', () => {
  it('should include whatever the server sends', () => {
    const serverInfo = {
      thingA: true,
      thingB: 123,
      thingC: {
        thingD: 'this is really important'
      }
    }
    const expectedAction = {
      type: SERVER_INFO,
      payload: {
        serverInfo
      }
    }
    expect(setServerInfo(serverInfo)).toEqual(expectedAction)
  })
})

