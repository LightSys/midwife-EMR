import expect from 'expect'
import {omit} from 'underscore'

import {
  LOGIN_REQUESTED,
  LOGIN_SUCCESS,
  LOGIN_FAILURE,
  AUTHENTICATION_INIT,
  SET_IS_AUTHENTICATED,
  SET_COOKIES,
  SET_USER_ID
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
    const newState = Object.assign({}, AUTHENTICATION_DEFAULT,
      {isAuthenticated: action.isAuthenticated, cookies: action.cookies})
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })

  it('SET_IS_AUTHENTICATED', () => {
    const action = {
      type: SET_IS_AUTHENTICATED,
      isAuthenticated: true
    }
    const newState = Object.assign({}, AUTHENTICATION_DEFAULT, {isAuthenticated: action.isAuthenticated})
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })

  it('SET_COOKIES', () => {
    const action = {
      type: SET_COOKIES,
      cookies: ['one cookie', 'two cookies']
    }
    const newState = Object.assign({}, AUTHENTICATION_DEFAULT, {cookies: action.cookies})
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })

  it('SET_USER_ID with param', () => {
    const id = 123
    const action = {
      type: SET_USER_ID,
      payload: {
        id
      }
    }
    const newState = Object.assign({}, AUTHENTICATION_DEFAULT, {userId: id})
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })

  it('SET_USER_ID without param', () => {
    const id = void 0
    const action = {
      type: SET_USER_ID,
      payload: {
        id
      }
    }
    const newState = Object.assign({}, AUTHENTICATION_DEFAULT, {userId: -1})
    expect(reducer(AUTHENTICATION_DEFAULT, action)).toEqual(newState)
  })


})

