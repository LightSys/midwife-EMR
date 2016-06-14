/* 
 * -------------------------------------------------------------------------------
 * Selected.js
 *
 * Top-level reducer for flagging anything that is selected.
 * ------------------------------------------------------------------------------- 
 */
import {
  SELECT_USER,
  SELECT_PREGNANCY
} from '../constants/ActionTypes'


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
        return Object.assign({}, state, {user: DEFAULT_SELECTED.user})
      }
    case SELECT_PREGNANCY:
      if (action && action.hasOwnProperty('pregId')) {
        return Object.assign({}, state, {pregnancy: action.pregId})
      } else {
        return Object.assign({}, state, {pregnancy: DEFAULT_SELECTED.pregnancy})
      }
    default:
      return state
  }
}

export default selected
