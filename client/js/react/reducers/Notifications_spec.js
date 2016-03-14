import expect from 'expect'

import reducer, {DEFAULT_NOTIFICATION} from './Notifications'

import {
  addSuccessNotification,
  addWarningNotification,
  addInfoNotification,
  addDangerNotification,
  removeNotification
} from '../actions/Notifications'


describe('reducers/Notifications', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_NOTIFICATION)
  })

  it('should do success notification', () => {
    const msg = 'This is a test'
    const closeable = false
    const timeout = 2000
    const action = addSuccessNotification(msg, closeable)
    const result = [{id: action.payload.id,
                     msg: action.payload.msg,
                     msgType: action.payload.msgType,
                     closeable: action.payload.closeable}]
    expect(reducer(DEFAULT_NOTIFICATION, action)).toEqual(result)
  })

  it('should do warning notification', () => {
    const msg = 'This is a test'
    const closeable = false
    const timeout = 2000
    const action = addWarningNotification(msg, closeable)
    const result = [{id: action.payload.id,
                     msg: action.payload.msg,
                     msgType: action.payload.msgType,
                     closeable: action.payload.closeable}]
    expect(reducer(DEFAULT_NOTIFICATION, action)).toEqual(result)
  })

  it('should do info notification', () => {
    const msg = 'This is a test'
    const closeable = false
    const timeout = 2000
    const action = addInfoNotification(msg, closeable)
    const result = [{id: action.payload.id,
                     msg: action.payload.msg,
                     msgType: action.payload.msgType,
                     closeable: action.payload.closeable}]
    expect(reducer(DEFAULT_NOTIFICATION, action)).toEqual(result)
  })

  it('should do danger notification', () => {
    const msg = 'This is a test'
    const closeable = false
    const timeout = 2000
    const action = addDangerNotification(msg, closeable)
    const result = [{id: action.payload.id,
                     msg: action.payload.msg,
                     msgType: action.payload.msgType,
                     closeable: action.payload.closeable}]
    expect(reducer(DEFAULT_NOTIFICATION, action)).toEqual(result)
  })

  it('should remove a notification', () => {
    const addAction = addSuccessNotification('testing', false)
    const addState = reducer(DEFAULT_NOTIFICATION, addAction)
    const removeAction = removeNotification(addAction.payload.id, 0)
    expect(reducer(addState, removeAction)).toEqual(DEFAULT_NOTIFICATION)
  })


})

