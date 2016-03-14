import expect from 'expect'

import {
  addSuccessNotification,
  addWarningNotification,
  addInfoNotification,
  addDangerNotification,
  removeNotification,
  SUCCESS,
  WARNING,
  INFO,
  DANGER
} from './Notifications'

import {
  ADD_NOTIFICATION,
  REMOVE_NOTIFICATION
} from '../constants/ActionTypes'

describe('NOTIFICATIONS', () => {
  describe('Adding', () => {
    it('Success type', () => {
      const msg = 'This is a test message'
      const msgType = SUCCESS
      const timeout = 2000
      const closeable = false
      const id = 1
      const expectedAction = {
        type: ADD_NOTIFICATION,
        payload: {
          id,
          msg,
          msgType,
          timeout,
          closeable
        }
      }
      const result = addSuccessNotification(msg, timeout, closeable)
      expect(result.payload.id).toBeA('number')
      expect(result.msg).toEqual(expectedAction.msg)
      expect(result.msgType).toEqual(expectedAction.msgType)
      expect(result.timeout).toEqual(expectedAction.timeout)
      expect(result.closeable).toEqual(expectedAction.closeable)
    })
    it('Warning type', () => {
      const msg = 'This is a test message'
      const msgType = WARNING
      const timeout = 2000
      const closeable = false
      const id = 1
      const expectedAction = {
        type: ADD_NOTIFICATION,
        payload: {
          id,
          msg,
          msgType,
          timeout,
          closeable
        }
      }
      const result = addWarningNotification(msg, timeout, closeable)
      expect(result.payload.id).toBeA('number')
      expect(result.msg).toEqual(expectedAction.msg)
      expect(result.msgType).toEqual(expectedAction.msgType)
      expect(result.timeout).toEqual(expectedAction.timeout)
      expect(result.closeable).toEqual(expectedAction.closeable)
    })
    it('Info type', () => {
      const msg = 'This is a test message'
      const msgType = INFO
      const timeout = 2000
      const closeable = false
      const id = 1
      const expectedAction = {
        type: ADD_NOTIFICATION,
        payload: {
          id,
          msg,
          msgType,
          timeout,
          closeable
        }
      }
      const result = addInfoNotification(msg, timeout, closeable)
      expect(result.payload.id).toBeA('number')
      expect(result.msg).toEqual(expectedAction.msg)
      expect(result.msgType).toEqual(expectedAction.msgType)
      expect(result.timeout).toEqual(expectedAction.timeout)
      expect(result.closeable).toEqual(expectedAction.closeable)
    })
    it('Danger type', () => {
      const msg = 'This is a test message'
      const msgType = DANGER
      const timeout = 2000
      const closeable = false
      const id = 1
      const expectedAction = {
        type: ADD_NOTIFICATION,
        payload: {
          id,
          msg,
          msgType,
          timeout,
          closeable
        }
      }
      const result = addDangerNotification(msg, timeout, closeable)
      expect(result.payload.id).toBeA('number')
      expect(result.msg).toEqual(expectedAction.msg)
      expect(result.msgType).toEqual(expectedAction.msgType)
      expect(result.timeout).toEqual(expectedAction.timeout)
      expect(result.closeable).toEqual(expectedAction.closeable)
    })
  })

  describe('Removing', () => {
    it('should create removing action', () => {
      const id = 12
      const action = removeNotification(id)
      expect(action.type).toEqual(REMOVE_NOTIFICATION)
      expect(action.payload.id).toEqual(id)
    })
  })
})

