
import {
  ROUTE_CHANGE
} from '../constants/ActionTypes'



export const routeChange = (route) => {
  return {
    type: ROUTE_CHANGE,
    payload: {
      route
    }
  }
}

