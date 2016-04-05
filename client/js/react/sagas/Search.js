import {call, put} from 'redux-saga/effects'
import {takeLatest} from 'redux-saga'
import fetch from 'isomorphic-fetch'

import {API_ROOT} from '../constants/index'

import {
  SEARCH_PATIENT_REQUEST,
  SEARCH_PATIENT_SUCCESS,
  SEARCH_PATIENT_FAILURE
} from '../constants/ActionTypes'

const options = {
  credentials: 'same-origin',   // Applies _csrf and connection.sid cookies.
  method: 'GET'
}


/* --------------------------------------------------------
 * checkStatus()
 *
 * Adapted from: https://github.com/github/fetch
 * -------------------------------------------------------- */
function checkStatus(response) {
  if (response.status >= 200 && response.status < 300) {
    return response
  } else {
    var error = new Error(response.statusText)
    error.response = response
    throw error
  }
}

// Exported for testing.
export const doSearchPatient = function (searchCriteria) {
  const fetchOpts = Object.assign({}, options)
  return fetch(`${API_ROOT}/search?searchPhrase=${searchCriteria.searchPhrase}`, fetchOpts)
    .then(checkStatus)
    .then((resp) => {
      return resp.json()
    })
    .then((json) => {
      return {results: json}  // Put it in the form the reducer expects.
    })
    .catch((error) => {
      throw {error}
    })
}

// Exported for testing.
export function* searchPatient(action) {
  try {
    const {results, error} = yield call(doSearchPatient, action.payload.searchCriteria)
    let payload = Object.assign({}, {results, searchCriteria: action.payload.searchCriteria})
    yield put({type: SEARCH_PATIENT_SUCCESS, payload})
  } catch (error) {
    yield put({type: SEARCH_PATIENT_FAILURE, error})
  }
}

export function* watchSearchPatient() {
  yield* takeLatest(SEARCH_PATIENT_REQUEST, searchPatient)
}


