import {call, put} from 'redux-saga/effects'
import {takeLatest} from 'redux-saga'
import fetch from 'isomorphic-fetch'
import {normalize} from 'normalizr'

import {API_ROOT} from '../constants/index'
import {checkStatus} from '../utils/sagasHelper'
import {Schemas} from '../constants/index'
import {changeData} from '../services/comm'

import {
  CLEAR_PREGNANCY_DATA,
  SELECT_PREGNANCY,
  GET_PREGNANCY_REQUEST,
  GET_PREGNANCY_SUCCESS,
  GET_PREGNANCY_FAILURE,
  SAVE_PRENATAL_REQUEST,
  SAVE_PRENATAL_SUCCESS,
  SAVE_PRENATAL_FAILURE
} from '../constants/ActionTypes'

import {
  addSuccessNotification,
  addWarningNotification,
  addDangerNotification,
  removeNotification
} from '../actions/Notifications'

import {
  getPregnancy,
  selectPregnancy
} from '../actions/Pregnancy'

const successNotifyTimeout = 2000;
const warningNotifyTimeout = 3000;
const dangerNotifyTimeout = 5000;

const options = {
  credentials: 'same-origin',   // Applies _csrf and connection.sid cookies.
  method: 'GET'
}

// ========================================================
// ========================================================
// Get pregnancy
// ========================================================
// ========================================================

export const doGetPregnancy = (pregId) => {
  const fetchOpts = Object.assign({}, options)
  return fetch(`${API_ROOT}/pregnancy/${pregId}`, fetchOpts)
    .then(checkStatus)
    .then((resp) => {
      return resp.json()
    })
    .then((json) => {
      return {entities: normalize(json, Schemas.PREGNANCY).entities}
    })
    .catch((error) => {
      throw {error}
    })
}

export function* getPregnancySaga(action) {
  try {
    const {entities, error} = yield call(doGetPregnancy, action.payload.id)
    let payload = Object.assign({}, {entities, pregId: action.payload.id})

    // Only allow one pregnancy to be loaded at a time on the client.
    yield put({type: CLEAR_PREGNANCY_DATA})

    // Load the new pregnancy data and select the pregnancy.
    yield put({type: GET_PREGNANCY_SUCCESS, payload})
    yield put(selectPregnancy(action.payload.id))
  } catch (error) {
    console.log('Error caught in getPregnancySaga()', error)
    yield put({type: GET_PREGNANCY_FAILURE, error})
    const msg = 'Sorry about that, an error was encountered getting data. Try again?'
    const warningNotifyAction = addWarningNotification(msg)
    yield put(warningNotifyAction)
    yield put(removeNotification(warningNotifyAction.payload.id, warningNotifyTimeout))
  }
}

// ========================================================
// ========================================================
// Save prenatal
// ========================================================
// ========================================================

export function* savePrenatalSaga(action) {
  let retAction
  try {
    retAction = yield call(changeData, action)
    console.log('retAction', retAction)

    // Determine success or failure.
    if (retAction.payload.error) throw retAction.payload.error

    // --------------------------------------------------------
    // Success
    // --------------------------------------------------------

    // Update the state.
    yield put({type: SAVE_PRENATAL_SUCCESS, payload: Object.assign({}, retAction.payload)})

    // Notifiy user.
    let userMsg = 'Success'
    if (retAction.payload.operation) userMsg += ': ' + retAction.payload.operation
    const successNotifyAction = addSuccessNotification(userMsg)
    yield put(successNotifyAction)
    yield put(removeNotification(successNotifyAction.payload.id, successNotifyTimeout))
  } catch (e) {
    // --------------------------------------------------------
    // Failure
    // --------------------------------------------------------

    // Update the state.
    yield put({type: SAVE_PRENATAL_FAILURE, payload: action.payload})

    // Notifiy user.
    let userMsg = 'Sorry, there was a problem saving the record.'
    if (e && typeof e == 'string') userMsg = e
    const notifyAction = addDangerNotification(userMsg)
    const notifyTimeout = dangerNotifyTimeout
    yield put(notifyAction)
    yield put(removeNotification(notifyAction.payload.id, notifyTimeout))
  }
}

// ========================================================
// ========================================================
// Watchers
// ========================================================
// ========================================================

export function* watchGetPregnancy() {
  yield* takeLatest(GET_PREGNANCY_REQUEST, getPregnancySaga)
}

export function* watchSavePrenatal() {
  yield* takeLatest(SAVE_PRENATAL_REQUEST, savePrenatalSaga)
}

