import {
  WINDOW_RESIZE
} from '../constants/ActionTypes'

import {BP_UNSET} from '../constants/index'

export const DEFAULT_WINDOW = {
  w: 0,
  h: 0,
  bp: BP_UNSET
}

const reducer = (state = DEFAULT_WINDOW, action) => {
  switch (action.type) {
    case WINDOW_RESIZE:
      return Object.assign({}, action.payload)
  }
  return state
}

export default reducer
