import expect from 'expect'
import {each} from 'underscore'

import reducer, {DEFAULT_ENTITIES} from './Entities'

import {
  LOAD_ALL_USERS_REQUEST,
  LOAD_ALL_USERS_SUCCESS,
  LOAD_ALL_USERS_FAILURE,
  SAVE_USER_REQUEST,
  SAVE_USER_SUCCESS,
  SAVE_USER_FAILURE,
  CHECK_IN_OUT_REQUEST,
  CHECK_IN_OUT_SUCCESS,
  CHECK_IN_OUT_FAILURE,
  LOAD_USER_PROFILE_SUCCESS,
  DATA_TABLE_SUCCESS
} from '../constants/ActionTypes'


// --------------------------------------------------------
// DEFAULT_ENTITIES is an object with depth of one, so make
// sure that there are not any references to the original.
// This can be used to pass to the reducers to help insure
// that the original is not modified.
// --------------------------------------------------------
const getDefault = () => {
  const copy = Object.assign({}, DEFAULT_ENTITIES)
  each(copy, (val, key) => {
    copy[key] = Object.assign({}, val)
  })
  return copy
}

describe('reducers/Entities', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_ENTITIES)
  })

  describe('Lookup Tables', () => {
    it('should load all records of an entity', () => {
      const entities = {role: {'0': {id: 0}, '1': {id: 1}}}
      const action = {
        type: DATA_TABLE_SUCCESS,
        payload: {
          entities
        }
      }
      const expectedResult = Object.assign({}, DEFAULT_ENTITIES, {role: entities.role})
      expect(reducer(getDefault(), action)).toEqual(expectedResult)
    })
  })

  describe('USER PROFILE', () => {
    it('should set a user record', () => {
      const id = 123
      const firstname = 'First name'
      const lastname = 'Last name'
      const shortName = 'FL'
      const action = {
        type: LOAD_USER_PROFILE_SUCCESS,
        payload: {
          id,
          firstname,
          lastname,
          shortName
        }
      }
      const expectedUser = {[id]: action.payload}
      const expectedResult = Object.assign({}, DEFAULT_ENTITIES, {user: expectedUser})
      expect(reducer(getDefault(), action)).toEqual(expectedResult)
    })
  })

  describe('USERS', () => {
    describe('LOAD_ALL_USERS', () => {
      it('should update user and role for LOAD_ALL_USERS_SUCCESS', () => {
        const action = {type: LOAD_ALL_USERS_SUCCESS, payload: {json: {entities: {}}}}
        const newUsers = {'1': {id: 1}, '2': {id: 2}}
        const newRoles = {'1': {id: 1}, '2': {id: 2}}
        action.payload.json.entities.user = newUsers
        action.payload.json.entities.role = newRoles
        expect(reducer(getDefault(), action))
          .toEqual(Object.assign({}, DEFAULT_ENTITIES, {user: newUsers, role: newRoles}))
      })
    })

    describe('SAVE_USER', () => {
      it('should update user on SAVE_USER_REQUEST', () => {
        const newUser = {
          id: 1,
          lastname: 'Testing'
        }
        const action = {
          type: SAVE_USER_REQUEST,
          optimist: true,
          payload: {
            data: newUser
          }
        }
        expect(reducer(getDefault(), action))
          .toEqual(Object.assign({}, DEFAULT_ENTITIES, {user: {'1': newUser}}))
      })
    })
  })

  describe('PREGNANCY', () => {
    describe('Checking IN and OUT', () => {
      it('upon check in, should set priority number upon success', () => {
        const initial = Object.assign({}, DEFAULT_ENTITIES, {pregnancy: {'1': {
          id: 1,
          prenatalCheckinPriority: 0
        }}})
        const expected = Object.assign({}, DEFAULT_ENTITIES, {pregnancy: {'1': {
          id: 1,
          prenatalCheckinPriority: 88
        }}})
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

      it('upon check out, should unset priority number upon success', () => {
        const initial = Object.assign({}, DEFAULT_ENTITIES, {pregnancy: {'1': {
          id: 1,
          prenatalCheckinPriority: 88
        }}})
        const expected = Object.assign({}, DEFAULT_ENTITIES, {pregnancy: {'1': {
          id: 1,
          prenatalCheckinPriority: 0
        }}})
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

  })

})

