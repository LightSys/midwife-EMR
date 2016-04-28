import 'babel-polyfill'
import {call, put} from 'redux-saga/effects'
import expect from 'expect'

import {
  loadUserProfileSaga,
  doLoadUserProfile
} from './Profile'

import {
  LOAD_USER_PROFILE_REQUEST,
  LOAD_USER_PROFILE_SUCCESS,
  LOAD_USER_PROFILE_FAILURE
} from '../constants/ActionTypes'

import {
  loadUserProfile
} from '../actions/UsersRoles'


describe('redux-saga/Profile', () => {

  describe('loadUserProfile', () => {
    it('should call loadUserProfileSaga', () => {
      const action = loadUserProfile()
      const iterator = loadUserProfileSaga(action)
      expect(iterator.next().value).toEqual(call(doLoadUserProfile))
    })

    it('should handle error', () => {
      const error = {}
      const action = loadUserProfile()
      const iterator = loadUserProfileSaga(action)
      iterator.next()
      expect(iterator.throw(error).value)
        .toEqual(put({type: LOAD_USER_PROFILE_FAILURE, error}))
    })
  })
})

