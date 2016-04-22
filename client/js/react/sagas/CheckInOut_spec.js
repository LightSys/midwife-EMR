import 'babel-polyfill'
import {call, put} from 'redux-saga/effects'
import expect from 'expect'

import {
  CHECK_IN_OUT_REQUEST,
  CHECK_IN_OUT_SUCCESS,
  CHECK_IN_OUT_FAILURE
} from '../constants/ActionTypes'

import {
  checkInOutSaga,
  doCheckInOut
} from './CheckInOut'

import {
  checkInOut
} from '../actions/Pregnancy'

const getState = () => {}

describe('redux-saga/CheckInOut', () => {
    it('should work with expected payload', () => {
      const pregId = 1100
      const barcode = 223344
      // Get an action type.
      const action = checkInOut(barcode, pregId)
      // Get a saga iterator.
      const iterator = checkInOutSaga(getState, action)
      expect(iterator.next().value).toEqual(call(doCheckInOut, getState, action.payload))
    })
})

