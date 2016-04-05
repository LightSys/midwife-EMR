import expect from 'expect'

import reducer, {DEFAULT_SEARCH} from './Search'

import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE
} from '../constants/ActionTypes'

import {searchPatient} from '../actions/Search'

describe('reducers/Search', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_SEARCH)
  })

  it('should do a success search', () => {
    const searchCriteria = {
      searchTerm: 'This is a test'
    }
    const results = ['one', 'two', 'three']
    const action = {
      type: SEARCH_PATIENT_SUCCESS,
      payload: {
        searchCriteria,
        results
      }
    }
    expect(reducer(undefined, action)).toEqual(action.payload)
  })

})

