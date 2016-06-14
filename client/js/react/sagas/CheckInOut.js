import {call, put} from 'redux-saga/effects'
import {takeLatest} from 'redux-saga'
import fetch from 'isomorphic-fetch'

import {API_ROOT} from '../constants/index'
import {checkStatus} from '../utils/sagasHelper'
import {Schemas} from '../constants/index'

import {changeData} from '../services/comm'

import {
  CHECK_IN_OUT_REQUEST,
  CHECK_IN_OUT_SUCCESS,
  CHECK_IN_OUT_FAILURE,
  SELECT_PREGNANCY,
  ROUTE_CHANGE
} from '../constants/ActionTypes'

import {
  addSuccessNotification,
  addWarningNotification,
  addDangerNotification,
  removeNotification
} from '../actions/Notifications'

const successNotifyTimeout = 2000;
const warningNotifyTimeout = 3000;
const dangerNotifyTimeout = 5000;


export function* checkInOutSaga(action) {
  let retAction
  try {
    retAction = yield call(changeData, action)

    // Determine success or failure.
    if (retAction.payload.error) throw retAction.payload.error

    // --------------------------------------------------------
    // Success
    // --------------------------------------------------------

    // Update the state.
    yield put({type: CHECK_IN_OUT_SUCCESS, payload: Object.assign({}, retAction.payload)})

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
    yield put({type: CHECK_IN_OUT_FAILURE, payload: action.payload})

    // Notifiy user.
    let userMsg = 'Sorry, there was a problem checking in or out.'
    if (e && typeof e == 'string') userMsg = e
    const notifyAction = addDangerNotification(userMsg)
    const notifyTimeout = dangerNotifyTimeout
    yield put(notifyAction)
    yield put(removeNotification(notifyAction.payload.id, notifyTimeout))
  } finally {
    // Unselect the pregnancy.
    yield put({type: SELECT_PREGNANCY})
  }
}


export function* watchCheckInOut() {
  yield* takeLatest(CHECK_IN_OUT_REQUEST, checkInOutSaga)
}

