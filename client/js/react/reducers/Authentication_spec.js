import expect from 'expect'
import {omit} from 'underscore'

import {
  LOGIN_REQUESTED,
  LOGIN_SUCCESS,
  LOGIN_FAILURE,
  AUTHENTICATION_INIT,
  SET_IS_AUTHENTICATED,
  SET_COOKIES
} from '../constants/ActionTypes'

import reducer, {AUTHENTICATION_DEFAULT} from './Authentication'

describe('reducers/Authentication', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(AUTHENTICATION_DEFAULT)
  })

  it('AUTHENTICATION_INIT', () => {
    const action = {
      type: AUTHENTICATION_INIT,
      cookies: ['This is one cookie', 'this is another'],
      isAuthenticated: true
    }
    const newState = omit(action, 'type')
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })

  it('SET_IS_AUTHENTICATED', () => {
    const action = {
      type: SET_IS_AUTHENTICATED,
      isAuthenticated: true
    }
    const newState = omit(action, 'type')
    newState.cookies = AUTHENTICATION_DEFAULT.cookies
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })

  it('SET_COOKIES', () => {
    const action = {
      type: SET_COOKIES,
      cookies: ['one cookie', 'two cookies']
    }
    const newState = omit(action, 'type')
    newState.isAuthenticated = AUTHENTICATION_DEFAULT.isAuthenticated
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })

})

