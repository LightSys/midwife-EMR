import expect from 'expect'

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
  CHECK_IN_OUT_FAILURE
} from '../constants/ActionTypes'


describe('reducers/Entities', () => {
  it('should return initial state', () => {
    expect(reducer(undefined, {})).toEqual(DEFAULT_ENTITIES)
  })

  describe('USERS', () => {
    describe('LOAD_ALL_USERS', () => {
      it('should update user and role for LOAD_ALL_USERS_SUCCESS', () => {
        const action = {type: LOAD_ALL_USERS_SUCCESS, payload: {json: {entities: {}}}}
        const newUsers = {'1': {id: 1}, '2': {id: 2}}
        const newRoles = {'1': {id: 1}, '2': {id: 2}}
        action.payload.json.entities.user = newUsers
        action.payload.json.entities.role = newRoles
        expect(reducer(DEFAULT_ENTITIES, action))
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
        expect(reducer(DEFAULT_ENTITIES, action))
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

