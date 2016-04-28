import {call, put} from 'redux-saga/effects'
import {takeLatest} from 'redux-saga'

import {API_ROOT} from '../constants/index'
import {checkStatus} from '../utils/sagasHelper'

import {
  LOAD_USER_PROFILE_REQUEST,
  LOAD_USER_PROFILE_SUCCESS,
  LOAD_USER_PROFILE_FAILURE
} from '../constants/ActionTypes'

import {
  addSuccessNotification,
  addWarningNotification,
  addDangerNotification,
  removeNotification
} from '../actions/Notifications'

const options = {
  credentials: 'same-origin',   // Applies _csrf and connection.sid cookies.
  method: 'GET'
}

const infoNotifyTimeout = 2000;
const warningNotifyTimeout = 3000;
const dangerNotifyTimeout = 5000;


// Exported for testing.
export const doLoadUserProfile = function () {
  const fetchOpts = Object.assign({}, options)
  return fetch(`${API_ROOT}/profile`, fetchOpts)
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
export function* loadUserProfileSaga(action) {
  try {
    const {results, error} = yield call(doLoadUserProfile)
    let payload = Object.assign({}, results)
    yield put({type: LOAD_USER_PROFILE_SUCCESS, payload})
  } catch (error) {
    yield put({type: LOAD_USER_PROFILE_FAILURE, error})
    const msg = 'Sorry about that, an error was encountered loading the profile. Try again?'
    const warningNotifyAction = addWarningNotification(msg)
    yield put(warningNotifyAction)
    yield put(removeNotification(warningNotifyAction.payload.id, warningNotifyTimeout))
  }
}


export function* watchLoadUserProfile() {
  yield* takeLatest(LOAD_USER_PROFILE_REQUEST, loadUserProfileSaga)
}

