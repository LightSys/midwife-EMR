import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE
} from '../constants/ActionTypes'


export const searchPatient = (searchCriteria) => {
  return {
    type: SEARCH_PATIENT_REQUEST,
    payload: {
      searchCriteria
    }
  }
}

