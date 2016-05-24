import {call, put} from 'redux-saga/effects'
import {takeLatest} from 'redux-saga'
import fetch from 'isomorphic-fetch'

import {API_ROOT} from '../constants/index'
import {checkStatus} from '../utils/sagasHelper'
import {Schemas} from '../constants/index'

import {
  ADD_USER_REQUEST,
  ADD_USER_SUCCESS,
  ADD_USER_FAILURE,
  SELECT_USER,
  ROUTE_CHANGE
} from '../constants/ActionTypes'

import {
  addSuccessNotification,
  addWarningNotification,
  addDangerNotification,
  removeNotification
} from '../actions/Notifications'

const successNotifyTimeout = 2000;
const warningNotifyTimeout = 5000;
const dangerNotifyTimeout = 7000;

const options = {
  credentials: 'same-origin',   // Applies _csrf and connection.sid cookies.
  method: 'GET'
}

// --------------------------------------------------------
// This is a POST.
// --------------------------------------------------------
export const doAddUser = (getState, user) => {
  const fetchOpts = Object.assign({}, options)
  const {_csrf} = getState().authentication.cookies
  fetchOpts.method = 'POST'
  fetchOpts.headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
  fetchOpts.body = JSON.stringify(Object.assign({}, {_csrf}, user))
  return fetch(`${API_ROOT}/user`, fetchOpts)
    .then(checkStatus)
    .then((resp) => {
      return resp.json()
    })
    .catch((error) => {
      // checkStatus() threw an exception above but the
      // server may have sent back a JSON response anyway
      // with a requestStatus field.
      throw error
    })
}

export function* addUserSaga(getState, action) {
  let requestStatus
  let err

  try {
    ({requestStatus} = yield call(doAddUser, getState, action.payload.user))
  } catch (error) {
    err = error
    requestStatus = error && error.json && error.json.requestStatus? error.json.requestStatus: void 0
  } finally {
    let path, success, msg, payload
    if (requestStatus) {
      ({path, success, msg, payload} = requestStatus)
    }

    if (! success) {
      // Get the message as right as we can for the user.
      if (err && err.status && err.status == 401) {
        msg = 'Oops, looks like you need to LOGIN first.'
        // Change route to the login page.
        yield put({type: ROUTE_CHANGE, payload: {route: '/login'}})
      } else if (! msg && err && err.status && err.status == 403) {
        msg = 'Oops, looks like you are not authorized to do this.'
      } else if (! msg) {
        msg = 'Sorry about that, an error was encountered adding that user. Try again?'
      }

      yield put({type: ADD_USER_FAILURE, payload: action.payload})

      // Notifiy user.
      const warningNotifyAction = addDangerNotification(msg)
      yield put(warningNotifyAction)
      yield put(removeNotification(warningNotifyAction.payload.id, warningNotifyTimeout))
    } else {
      // Success: load the new user data into state.
      const newUser = Object.assign({}, requestStatus.payload)
      yield put({type: ADD_USER_SUCCESS, payload: newUser})

      // Select the new user.
      yield put({type: SELECT_USER, userId: newUser.id})

      // Change the route to edit the user.
      yield put({type: ROUTE_CHANGE, payload: {route: `/user/${newUser.id}`}})

      // Notifiy user.
      const userMsg = `User added successfully.`
      const successNotifyAction = addSuccessNotification(userMsg)
      yield put(successNotifyAction)
      yield put(removeNotification(successNotifyAction.payload.id, successNotifyTimeout))
    }
  }
}

export function* watchAddUser(getState) {
  yield* takeLatest(ADD_USER_REQUEST, addUserSaga, getState)
}

