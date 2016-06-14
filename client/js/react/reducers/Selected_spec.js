import expect from 'expect'

import reducer from './Selected'
import {selectUser} from '../actions/UsersRoles'
import {selectPregnancy} from '../actions/Pregnancy'
import {
  SELECT_USER,
  SELECT_PREGNANCY
} from '../constants/ActionTypes'

describe('reducers/Selected', () => {
  // --------------------------------------------------------
  // User
  // --------------------------------------------------------
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
    const userId = 343
    const state1 = reducer(undefined, selectUser(userId))
    expect(reducer(state1, selectUser())).toEqual({
      patient: -1,
      pregnancy: -1,
      role: -1,
      user: -1
    })
  })
  it('unselecting user without passing userId field should leave other selections untouched', () => {
    const userId = 333
    const pregId = 444
    const state1 = reducer(undefined, selectPregnancy(pregId))
    const state2 = reducer(state1, selectUser(userId))
    expect(reducer(state2, {type: SELECT_USER})).toEqual({
      patient: -1,
      pregnancy: pregId,
      role: -1,
      user: -1
    })
  })

  // --------------------------------------------------------
  // Pregnancy
  // --------------------------------------------------------
  it('selectPregnancy reducer should return initial state', () => {
    expect(reducer(undefined, {})).toEqual({
      patient: -1,
      pregnancy: -1,
      role: -1,
      user: -1
    })
  })
  it('selectPregnancy reducer should set a pregnancy', () => {
    const pregId = 342
    expect(reducer(0, selectPregnancy(pregId))).toEqual({pregnancy: pregId})
  })
  it('selectPregnancy reducer should unset a pregnancy', () => {
    const pregId = 222
    const state1 = reducer(undefined, selectPregnancy(pregId))
    expect(reducer(state1, selectPregnancy())).toEqual({
      patient: -1,
      pregnancy: -1,
      role: -1,
      user: -1
    })
  })
  it('unselecting pregnancy without passing pregId field should leave other selections untouched', () => {
    const pregId = 444
    const userId = 333
    const state1 = reducer(undefined, selectUser(userId))
    const state2 = reducer(state1, selectPregnancy(pregId))
    expect(reducer(state2, {type: SELECT_PREGNANCY})).toEqual({
      patient: -1,
      pregnancy: -1,
      role: -1,
      user: userId
    })
  })
})


