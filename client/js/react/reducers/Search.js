import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE
} from '../constants/ActionTypes'


export const DEFAULT_SEARCH = {searchCriteria: '', results: []}

const search = (state=DEFAULT_SEARCH, action) => {
  switch (action.type) {
    case SEARCH_PATIENT_SUCCESS:
      return Object.assign({}, state,
          {searchCriteria: action.payload.searchCriteria, results: action.payload.results})
    default:
      return state
  }
}

export default search

