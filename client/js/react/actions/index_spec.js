import expect from 'expect'

import {
  DATA_CHANGE,
  SET_COOKIES,
  SYSTEM_MESSAGE,
  SITE_MESSAGE,
  AUTHENTICATION_UPDATE
} from '../constants/ActionTypes'

import {
  dataChange,
  setCookies,
  systemMessage,
  siteMessage,
  authenticationUpdate
} from './index'

describe('actions/index', () => {
  it('dataChange', () => {
    const data = {
      table: 'user',
      id: 12
    }
    const expectedAction = {
      type: DATA_CHANGE,
      id: data.id,
      table: data.table
    }
    expect(dataChange(data)).toEqual(expectedAction)
  })

  it('setCookies', () => {
    const cookies = {
      one: 'this is the first cookie',
      two: 'this is the second cookie'
    }
    const expectedAction = {
      type: SET_COOKIES,
      cookies: cookies
    }
    expect(setCookies(cookies)).toEqual(expectedAction)
  })

  it('systemMessage', () => {
    const msg = {
      one: 1,
      two: 'two'
    }
    const expectedAction = {
      type: SYSTEM_MESSAGE,
      message: msg
    }
    expect(systemMessage(msg)).toEqual(expectedAction)
  })

  it('siteMessage', () => {
    const msg = {
      one: 1,
      two: 'two'
    }
    const expectedAction = {
      type: SITE_MESSAGE,
      message: msg
    }
    expect(siteMessage(msg)).toEqual(expectedAction)
  })

  it('authenticationUpdate', () => {
    const update = {
      expiry: 123456,
      isAuthenticated: true
    }
    const expectedAction = {
      type: AUTHENTICATION_UPDATE,
      expiry: update.authExpiry,
      isAuthenticated: update.isAuthenticated
    }
    expect(authenticationUpdate(update)).toEqual(expectedAction)
  })
})

