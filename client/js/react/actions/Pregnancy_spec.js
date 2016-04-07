import expect from 'expect'

import {
  GET_PREGNANCY_REQUEST,
  GET_PREGNANCY_SUCCESS,
  GET_PREGNANCY_FAILURE,
  SELECT_PREGNANCY
} from '../constants/ActionTypes'

import {
  getPregnancy,
  selectPregnancy
} from './Pregnancy'


describe('actions/Pregnancy', () => {
  it('should create get pregnancy action', () => {
    const id = 1310
    const expectedAction = {
      type: GET_PREGNANCY_REQUEST,
      payload: {
        id
      }
    }
    expect(getPregnancy(id)).toEqual(expectedAction)
  })

  it('should create select pregnancy action', () => {
    const pregId = 1310
    const expectedAction = {
      type: SELECT_PREGNANCY,
      pregId
    }
    expect(selectPregnancy(pregId)).toEqual(expectedAction)
  })
})

