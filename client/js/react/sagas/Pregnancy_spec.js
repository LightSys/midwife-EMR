import 'babel-polyfill'
import {call, put} from 'redux-saga/effects'
import expect from 'expect'

import {
  doGetPregnancy,
  getPregnancySaga
} from './Pregnancy'

import {
  CLEAR_PREGNANCY_DATA,
  SELECT_PREGNANCY,
  GET_PREGNANCY_REQUEST,
  GET_PREGNANCY_SUCCESS,
  GET_PREGNANCY_FAILURE
} from '../constants/ActionTypes'

import {
  getPregnancy,
  selectPregnancy
} from '../actions/Pregnancy'


describe('redux-saga/Pregnancy', () => {

  describe('getPregnancy()', () => {
    it('should work with expected payload', () => {
      const pregId = 1100
      // Get an action type.
      const action = getPregnancy(pregId)
      // Get a saga iterator.
      const iterator = getPregnancySaga(action)
      expect(iterator.next().value).toEqual(call(doGetPregnancy, pregId))
    })

    it('should handle errors', () => {
      const error = {}
      const pregId = 1001
      // Get an action type.
      const action = getPregnancy(pregId)
      // Get a saga iterator.
      const iterator = getPregnancySaga(action)
      iterator.next()

      expect(iterator.throw(error).value).toEqual(put({type: GET_PREGNANCY_FAILURE, error}))
    })
  })

})

