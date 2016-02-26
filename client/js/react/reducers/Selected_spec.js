import expect from 'expect'

import reducer from './Selected'
import {
  selectUser
} from '../actions/UsersRoles'

describe('reducers/Selected', () => {
  it('selectUser reducer should return initial state', () => {
    expect(reducer(undefined, {})).toEqual({
      patient: -1,
      pregnancy: -1,
      role: -1,
      user: -1
    })
  })
  it('selectUser reducer should set a user', () => {
    const userId = 342
    expect(reducer(0, selectUser(userId))).toEqual({user: userId})
  })
  it('selectUser reducer should unset a user', () => {
    expect(reducer(undefined, selectUser())).toEqual({
      patient: -1,
      pregnancy: -1,
      role: -1,
      user: -1
    })
  })
})


