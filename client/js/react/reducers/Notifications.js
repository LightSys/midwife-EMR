import {
  ADD_NOTIFICATION,
  REMOVE_NOTIFICATION
} from '../constants/ActionTypes'

// --------------------------------------------------------
// Default notification. Exported for testing.
// --------------------------------------------------------
export const DEFAULT_NOTIFICATION = []


const notification = (state = DEFAULT_NOTIFICATION, action) => {
  switch (action.type) {
    case ADD_NOTIFICATION:
      const notification = action.payload
      const newState = [...state, notification]
      return newState
      break

    case REMOVE_NOTIFICATION:
      return state.filter((n) => n.id !== action.payload.id)
      break

    default:
      return state
  }
}

export default notification
