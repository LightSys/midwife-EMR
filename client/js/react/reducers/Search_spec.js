import expect from 'expect'

import reducer, {DEFAULT_SEARCH} from './Search'

import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE,
  CHECK_IN_OUT_SUCCESS
} from '../constants/ActionTypes'

import {searchPatient} from '../actions/Search'

describe('reducers/Search', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_SEARCH)
  })

  it('should record criteria during request', () => {
    const searchCriteria = {
      searchTerm: 'This is a test'
    }
    const results = []
    const action = {
      type: SEARCH_PATIENT_REQUEST,
      payload: {
        searchCriteria,
        results
      }
    }
    expect(reducer(undefined, action)).toEqual(action.payload)

  })

  it('should wipe out prior results during request', () => {
    const searchCriteria = {
      searchTerm: 'This is a test'
    }
    const priorState = DEFAULT_SEARCH
    priorState.results = ['one', 'two', 'three']
    const action = {
      type: SEARCH_PATIENT_REQUEST,
      payload: {
        searchCriteria
      }
    }
    const expectedState = {
      searchCriteria,
      results: []
    }
    expect(reducer(priorState, action)).toEqual(expectedState)

  })

  it('should record results upon success', () => {
    const searchCriteria = {
      searchTerm: ''
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

  it('should preserve search criteria upon success', () => {
    const searchCriteria = {
      searchTerm: 'This is a test'
    }
    const priorState = DEFAULT_SEARCH
    priorState.searchCriteria = searchCriteria
    const results = ['one', 'two', 'three']
    const action = {
      type: SEARCH_PATIENT_SUCCESS,
      payload: {
        results
      }
    }
    const expectedState = {
      searchCriteria,
      results
    }
    expect(reducer(priorState, action)).toEqual(expectedState)
  })

  it('should assign priority number upon check in', () => {
    const initial = Object.assign({}, DEFAULT_SEARCH, {results: [{
      id: 1,
      priority: 0
    }]})
    const expected = Object.assign({}, DEFAULT_SEARCH, {results: [{
      id: 1,
      priority: 88
    }]})
    const action = {
      type: CHECK_IN_OUT_SUCCESS,
      payload: {
        barcode: '123456',
        pregId: 1,
        priority: 88,
        operation: 'checkin'
      }
    }
    expect(reducer(initial, action)).toEqual(expected)
  })

  it('should clear priority number upon check out', () => {
    const initial = Object.assign({}, DEFAULT_SEARCH, {results: [{
      id: 1,
      priority: 88
    }]})
    const expected = Object.assign({}, DEFAULT_SEARCH, {results: [{
      id: 1,
      priority: 0
    }]})
    const action = {
      type: CHECK_IN_OUT_SUCCESS,
      payload: {
        barcode: '123456',
        pregId: 1,
        priority: 88,
        operation: 'checkout'
      }
    }
    expect(reducer(initial, action)).toEqual(expected)
  })
})

