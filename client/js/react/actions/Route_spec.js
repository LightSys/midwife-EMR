import expect from 'expect'

import {
  ROUTE_CHANGE
} from '../constants/ActionTypes'

import {routeChange} from './Route'

describe('actions/Route', () => {

  it('should create route change action', () => {
    const route = 'ThisIsANewRoute'
    const expectedAction = {
      type: ROUTE_CHANGE,
      payload: {
        route
      }
    }
    expect(routeChange(route)).toEqual(expectedAction)
  })

  it('should create route change action with cleared route', () => {
    const route = ''
    const expectedAction = {
      type: ROUTE_CHANGE,
      payload: {
        route
      }
    }
    expect(routeChange(route)).toEqual(expectedAction)
  })

  it('should create route change action with undefined route', () => {
    const route = void 0
    const expectedAction = {
      type: ROUTE_CHANGE,
      payload: {
        route
      }
    }
    expect(routeChange(route)).toEqual(expectedAction)
  })
})

