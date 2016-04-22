import {call, put} from 'redux-saga/effects'
import {takeLatest} from 'redux-saga'
import fetch from 'isomorphic-fetch'

import {API_ROOT} from '../constants/index'
import {checkStatus} from '../utils/sagasHelper'
import {Schemas} from '../constants/index'

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

const options = {
  credentials: 'same-origin',   // Applies _csrf and connection.sid cookies.
  method: 'GET'
}

// --------------------------------------------------------
// This is a POST.
// --------------------------------------------------------
export const doCheckInOut = (getState, {barcode, pregId}) => {
  const fetchOpts = Object.assign({}, options)
  const {_csrf} = getState().authentication.cookies
  fetchOpts.method = 'POST'
  fetchOpts.headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
  fetchOpts.body = JSON.stringify(Object.assign({}, {barcode, _csrf, pregId}))
  return fetch(`${API_ROOT}/checkinout`, fetchOpts)
    .then(checkStatus)
    .then((resp) => {
      return resp.json()
    })
    .catch((error) => {
      // checkStatus() threw an exception above.
      throw error
    })
}

export function* checkInOutSaga(getState, action) {
  let requestStatus

  try {
    ({requestStatus} = yield call(doCheckInOut, getState, action.payload))
  } catch (error) {
    yield put({type: CHECK_IN_OUT_FAILURE, error})
    let msg
    if (error.status == 401) {
      msg = 'Oops, looks like you need to LOGIN first.'
      // Change route to the login page.
      yield put({type: ROUTE_CHANGE, payload: {route: '/login'}})
    } else if (error.status == 403) {
      msg = 'Oops, looks like you are not authorized to do this.'
    } else {
      msg = 'Sorry about that, an error was encountered processing the check in/out. Try again?'
    }
    const warningNotifyAction = addWarningNotification(msg)
    yield put(warningNotifyAction)
    yield put(removeNotification(warningNotifyAction.payload.id, warningNotifyTimeout))
  } finally {
    const {path, success, msg, payload} = requestStatus

    if (! success) {
      yield put({type: CHECK_IN_OUT_FAILURE, payload: action.payload})

      // Notifiy user.
      const userMsg = 'The check in/out has failed. Please try again later.'
      const dangerNotifyAction = addDangerNotification(userMsg)
      yield put(dangerNotifyAction)
      yield put(removeNotification(dangerNotifyAction.payload.id, dangerNotifyTimeout))
    } else {
      // Success
      const reducerData = Object.assign({}, action.payload, payload)
      yield put({type: CHECK_IN_OUT_SUCCESS, payload: reducerData})

      // Unselect the pregnancy.
      yield put({type: SELECT_PREGNANCY})

      // Notifiy user.
      const userMsg = `${payload.operation} successful.`
      const successNotifyAction = addSuccessNotification(userMsg)
      yield put(successNotifyAction)
      yield put(removeNotification(successNotifyAction.payload.id, successNotifyTimeout))
    }
  }
}

export function* watchCheckInOut(getState) {
  yield* takeLatest(CHECK_IN_OUT_REQUEST, checkInOutSaga, getState)
}

