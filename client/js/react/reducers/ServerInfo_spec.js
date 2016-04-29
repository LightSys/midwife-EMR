import expect from 'expect'

import reducer, {DEFAULT_SERVER_INFO} from './ServerInfo'

import {
  SERVER_INFO
} from '../constants/ActionTypes'

import {setServerInfo} from '../actions/ServerInfo'


describe('reducers/ServerInfo', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_SERVER_INFO)
  })

  it('should set serverInfo', () => {
    const serverInfo = {
      thingA: true,
      thingB: {
        thingC: 123,
        thingD: 'yes'
      }
    }
    const action = {
      type: SERVER_INFO,
      payload: {
        serverInfo
      }
    }
    expect(reducer(undefined, action)).toEqual(action.payload.serverInfo)
  })
})

