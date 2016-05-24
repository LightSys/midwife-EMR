import 'babel-polyfill'
import {call, put} from 'redux-saga/effects'
import expect from 'expect'

import {
  ADD_USER_REQUEST,
  ADD_USER_SUCCESS,
  ADD_USER_FAILURE,
} from '../constants/ActionTypes'

import {
  addUserSaga,
  doAddUser
} from './UsersRoles'

import {
  addUser
} from '../actions/UsersRoles'

const getState = () => {}

describe('redux-saga/addUser', () => {
    it('should work with expected payload', () => {
      const user = {
        firstname: 'Test',
        lastname: 'test',
        displayName: 'test',
        shortName: 'test'
      }
      // Get an action type.
      const action = addUser(user)
      // Get a saga iterator.
      const iterator = addUserSaga(getState, action)
      expect(iterator.next().value).toEqual(call(doAddUser, getState, action.payload.user))
    })
})

