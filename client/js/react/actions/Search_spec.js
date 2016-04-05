import expect from 'expect'

import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE
} from '../constants/ActionTypes'

import {
  searchPatient
} from './Search'

describe('actions/Search', () => {
  it('should create Search patient action', () => {
    const searchCriteria = {
      searchTerm: 'this is a search term'
    }
    const expectedAction = {
      type: SEARCH_PATIENT_REQUEST,
      payload: {
        searchCriteria
      }
    }
    expect(searchPatient(searchCriteria)).toEqual(expectedAction)
  })

  it('should create Search patient action with dob', () => {
    const searchCriteria = {
      dob: new Date(1986, 11, 21)
    }
    const expectedAction = {
      type: SEARCH_PATIENT_REQUEST,
      payload: {
        searchCriteria
      }
    }
    expect(searchPatient(searchCriteria)).toEqual(expectedAction)
  })


})

