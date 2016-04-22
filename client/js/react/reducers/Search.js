import {map} from 'underscore'

import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE,
  CHECK_IN_OUT_SUCCESS
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

    case CHECK_IN_OUT_SUCCESS:
      // --------------------------------------------------------
      // Need to adjust priority number of pregnancy within search 
      // results if it is there so that displays accurately when 
      // user goes back to search results page.
      //
      // Note: the CHECK_IN_OUT_SUCCESS action is handled in the
      // entities and search reducers.
      // --------------------------------------------------------
      if (true) {
        const newState = Object.assign({}, state)
        if (action.payload) {
          const {operation, pregId, priority} = action.payload
          if (operation && pregId) {
            const results = map(newState.results, (rec) => {
              if (rec.id === pregId) {
                if (operation === 'checkout') {
                  rec.priority = 0
                } else if (operation === 'checkin') {
                  rec.priority = priority
                }
              }
              return rec
            })
            newState.results = results
          }
        }
        return newState
      }

    default:
      return state
  }
}

export default search

