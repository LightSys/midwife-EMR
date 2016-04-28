import expect from 'expect'

import {
  selectUser,
  loadUserProfile
} from './UsersRoles'

import {
  SELECT_USER,
  LOAD_USER_PROFILE_REQUEST
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

  describe('loadUserProfile', () => {
    it('produces expected action', () => {
      const expectedAction = {
        type: LOAD_USER_PROFILE_REQUEST
      }
      expect(loadUserProfile()).toEqual(expectedAction)
    })
  })
})


