import {has} from 'underscore'

import {
  ROUTE_CHANGE
} from '../constants/ActionTypes'


// --------------------------------------------------------
// Default route change. Exported for testing.
// --------------------------------------------------------
export const DEFAULT_ROUTE_CHANGE = ''


const routeChange = (state = DEFAULT_ROUTE_CHANGE, action) => {
  switch (action.type) {
    case ROUTE_CHANGE:
      // Set the route if in payload, otherwise unset it.
      if (action.payload && has(action.payload, 'route')) {
        return action.payload.route? action.payload.route: ''
      } else {
        return ''
      }
      break

    default:
      return state
  }
}

export default routeChange
