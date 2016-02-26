/* 
 * -------------------------------------------------------------------------------
 * Selected.js
 *
 * Top-level reducer for flagging anything that is selected.
 * ------------------------------------------------------------------------------- 
 */
import {SELECT_USER} from '../constants/ActionTypes'


// --------------------------------------------------------
// Default values.
// --------------------------------------------------------
const DEFAULT_SELECTED = {
  patient: -1,
  pregnancy: -1,
  role: -1,
  user: -1
}

// --------------------------------------------------------
// Reducers.
// --------------------------------------------------------

const selected = (state = DEFAULT_SELECTED, action) => {
  switch (action.type) {
    case SELECT_USER:
      if (action && action.hasOwnProperty('userId')) {
        return Object.assign({}, state, {user: action.userId})
      } else {
        return DEFAULT_SELECTED.user
      }
    default:
      return state
  }
}

export default selected
