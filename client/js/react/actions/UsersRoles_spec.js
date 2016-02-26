import expect from 'expect'

import {
  selectUser
} from './UsersRoles'

import {
  SELECT_USER
} from '../constants/ActionTypes'

describe('actions/UsersRoles', () => {
  describe('selectUser', () => {
    it('selectUser action', () => {
      const userId = 123
      const expectedAction = {
        type: SELECT_USER,
        userId: userId
      }
      expect(selectUser(userId)).toEqual(expectedAction)
    })
    it('selectUser action no args', () => {
      const expectedAction = {
        type: SELECT_USER,
        userId: -1
      }
      expect(selectUser()).toEqual(expectedAction)
    })
  })
})


