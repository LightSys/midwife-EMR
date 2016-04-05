import 'babel-polyfill'
import {call, put} from 'redux-saga/effects'
import expect from 'expect'

import {
  searchPatient,
  doSearchPatient
} from './Search'

import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE
} from '../constants/ActionTypes'

import {searchPatient as searchPatientActionCreator} from '../actions/Search'

describe('redux-saga/Search', () => {

  it('should work with expected payload', () => {
    const criteria = {
      searchTerm: 'testing'
    }
    // Get an action type.
    const action = searchPatientActionCreator(criteria)
    // Get a saga iterator.
    const iterator = searchPatient(action)
    expect(iterator.next().value).toEqual(call(doSearchPatient, criteria))
  })

  it('should handle errors', () => {
    const error = {}
    const criteria = {
      searchTerm: 'testing again'
    }
    // Get an action type.
    const action = searchPatientActionCreator(criteria)
    // Get a saga iterator.
    const iterator = searchPatient(action)
    iterator.next()

    expect(iterator.throw(error).value).toEqual(put({type: SEARCH_PATIENT_FAILURE, error}))
  })
})

