import expect from 'expect'

import reducer, {DEFAULT_WINDOW} from './Breakpoint'
import {WINDOW_RESIZE} from '../constants/ActionTypes'
import {
  BP_UNSET,
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

describe('reducers/window', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_WINDOW)
  })

  it('should set other values', () => {
    const newValues = {
      w: 517,
      h: 810,
      bp: BP_MEDIUM
    }
    const action = {
      type: WINDOW_RESIZE,
      payload: newValues
    }
    expect(reducer(undefined, action)).toEqual(newValues)
  })

})

