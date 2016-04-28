import expect from 'expect'

import {
  DATA_CHANGE,
  SET_COOKIES,
  SYSTEM_MESSAGE,
  SITE_MESSAGE,
  SET_IS_AUTHENTICATED,
  SET_USER_ID
} from '../constants/ActionTypes'

import {
  dataChange,
  setCookies,
  systemMessage,
  siteMessage,
  setIsAuthenticated,
  setUserId
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

  it('setIsAuthenticated true', () => {
    const isAuthenticated = true
    const expectedAction = {
      type: SET_IS_AUTHENTICATED,
      isAuthenticated
    }
    expect(setIsAuthenticated(isAuthenticated)).toEqual(expectedAction)
  })

  it('setIsAuthenticated false', () => {
    const isAuthenticated = false
    const expectedAction = {
      type: SET_IS_AUTHENTICATED,
      isAuthenticated
    }
    expect(setIsAuthenticated(isAuthenticated)).toEqual(expectedAction)
  })

  it('setUserId passing param sets', () => {
    const id = 123
    const expectedAction = {
      type: SET_USER_ID,
      payload: {
        id
      }
    }
    expect(setUserId(id)).toEqual(expectedAction)
  })

  it('setUserId passing no param unsets', () => {
    const id = -1
    const expectedAction = {
      type: SET_USER_ID,
      payload: {
        id
      }
    }
    expect(setUserId()).toEqual(expectedAction)
  })
})

