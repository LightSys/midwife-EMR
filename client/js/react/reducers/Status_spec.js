import expect from 'expect'
import _ from 'underscore'

import reducer from './Status'
import {DEFAULT_STATUS} from './Status'

import {
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE,
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE,
  DATA_CHANGE
} from '../constants/ActionTypes'

import {
  NOT_LOADED,
  LOADING,
  LOADED,
  SAVING
} from '../constants/index'


describe('reducers/Status', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_STATUS)
  })

  describe('LOAD_ALL_USERS', () => {

    it('should set status to LOADING for LOAD_ALL_USERS_REQUEST', () => {
      const action = {type: LOAD_ALL_USERS_REQUEST}
      const newState = {user: {status: LOADING, dirty: [], pending: []}}
      expect(reducer(DEFAULT_STATUS, action))
        .toEqual(Object.assign({}, DEFAULT_STATUS, newState))
    })

    it('should set status to LOADED for LOAD_ALL_USERS_SUCCESS', () => {
      const action = {type: LOAD_ALL_USERS_SUCCESS}
      const newState = {user: {status: LOADED, dirty: [], pending: []}}
      expect(reducer(DEFAULT_STATUS, action))
        .toEqual(Object.assign({}, DEFAULT_STATUS, newState))
    })

    it('should set status to NOT_LOADED for LOAD_ALL_USERS_FAILURE', () => {
      const action = {type: LOAD_ALL_USERS_FAILURE}
      const newState = {user: {status: NOT_LOADED, dirty: [], pending: []}}
      expect(reducer(DEFAULT_STATUS, action))
        .toEqual(Object.assign({}, DEFAULT_STATUS, newState))
    })

  })  // end LOAD_ALL_USERS

  describe('SAVE_USER', () => {

    it('should set status to SAVING for SAVE_USER_REQUEST with id passed', () => {
      const action = {type: SAVE_USER_REQUEST, meta: {id: 1}}
      const newState = {user: {status: SAVING, dirty: [], pending: [1]}}
      expect(reducer(DEFAULT_STATUS, action))
        .toEqual(Object.assign({}, DEFAULT_STATUS, newState))
    })

    it('should set status to LOADED for SAVE_USER_SUCCESS with id passed', () => {
      const action = {type: SAVE_USER_SUCCESS, meta: {id: 1}}
      const newState = {user: {status: LOADED, dirty: [], pending: []}}
      expect(reducer(DEFAULT_STATUS, action))
        .toEqual(Object.assign({}, DEFAULT_STATUS, newState))
    })

    it('should set status to LOADED for SAVE_USER_FAILURE with id passed', () => {
      const action = {type: SAVE_USER_FAILURE, meta: {id: 1}}
      const newState = {user: {status: LOADED, dirty: [], pending: [1]}}
      expect(reducer(DEFAULT_STATUS, action))
        .toEqual(Object.assign({}, DEFAULT_STATUS, newState))
    })

  })  // end SAVE_USER

  describe('DATA_CHANGE', () => {
    it('should flag entity record as dirty for each table', () => {
      const tables = _.keys(DEFAULT_STATUS)
      _.each(tables, (table) => {
        const action = {type: DATA_CHANGE, table, id: 1}
        const newState = {[table]: {status: NOT_LOADED, pending: [], dirty: [1]}}
        expect(reducer(DEFAULT_STATUS, action))
          .toEqual(Object.assign({}, DEFAULT_STATUS, newState))
      })
    })

  })

})

