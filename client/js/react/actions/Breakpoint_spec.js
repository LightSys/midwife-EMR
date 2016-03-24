import expect from 'expect'

import {WINDOW_RESIZE} from '../constants/ActionTypes'
import {
  BP_UNSET,
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

import {windowResize} from './Breakpoint'
import {getBreakpoint} from '../utils/index'

describe('actions/window', () => {
  it('should create window resize action', () => {
    const w = 455
    const h = 712
    const bp = getBreakpoint(w)
    const expectedAction = {
      type: WINDOW_RESIZE,
      payload: {w, h, bp}
    }
    expect(windowResize(w, h)).toEqual(expectedAction)
  })
})

