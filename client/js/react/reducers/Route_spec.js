import expect from 'expect'

import reducer, {DEFAULT_ROUTE_CHANGE} from './Route'
import {ROUTE_CHANGE} from '../constants/ActionTypes'

describe('reducers/Route', () => {

  it('should set a new route', () => {
    const route = 'thisIsARoute'
    const action = {
      type: ROUTE_CHANGE,
      payload: {
        route
      }
    }
    expect(reducer(DEFAULT_ROUTE_CHANGE, action)).toEqual(route)
  })

  it('should unset a route with empty route as payload', () => {
    const route = ''
    const action = {
      type: ROUTE_CHANGE,
      payload: {
        route
      }
    }
    expect(reducer('ThisIsAlreadySetRoute', action)).toEqual(route)
  })

  it('should unset a route with no payload', () => {
    const route = ''
    const action = {
      type: ROUTE_CHANGE,
    }
    expect(reducer('ThisIsAlreadySetRoute', action)).toEqual(route)
  })
})

