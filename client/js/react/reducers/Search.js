import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE
} from '../constants/ActionTypes'


export const DEFAULT_SEARCH = {searchCriteria: {searchTerm: ''}, results: []}

const search = (state=DEFAULT_SEARCH, action) => {
  const newState = {}
  switch (action.type) {
    case SEARCH_PATIENT_REQUEST:
      // Save the search criteria, clear the prior results.
      return Object.assign({}, {searchCriteria: action.payload.searchCriteria, results: []})
    case SEARCH_PATIENT_SUCCESS:
      // Save the results, preserve existing search criteria.
      return Object.assign({}, state, {searchCriteria: state.searchCriteria, results: action.payload.results})

    default:
      return state
  }
}

export default search

