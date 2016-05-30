import expect from 'expect'

import {
  DATA_TABLE_REQUEST,
  DATA_TABLE_SUCCESS,
  DATA_TABLE_FAILURE
} from '../constants/ActionTypes'

import {
  getLookupTable,
  setLookupTable
} from './LookupTables'

describe('action/LookupTable', () => {
  it('getLookupTable', () => {
    const table = 'role'
    const expectedAction = {
      type: DATA_TABLE_REQUEST,
      payload: {
        table
      }
    }
    expect(getLookupTable(table)).toEqual(expectedAction)
  })

  it('setLookupTable', () => {
    const entities = {entities: {role: {}}}
    const expectedAction = {
      type: DATA_TABLE_SUCCESS,
      payload: {
        entities
      }
    }
    expect(setLookupTable(entities)).toEqual(expectedAction)
  })



})

