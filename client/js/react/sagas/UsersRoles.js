import {call, fork, put, select} from 'redux-saga/effects'
import {takeEvery} from 'redux-saga'
import fetch from 'isomorphic-fetch'

import {API_ROOT} from '../constants/index'
import {checkStatus} from '../utils/sagasHelper'
import {Schemas} from '../constants/index'
import {changeData} from '../services/comm'

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

function* addUserSaga(action) {
  const user = action.payload.user
  let success = false
  let retAction
  let newUser
  try {
    retAction = yield call(changeData, action)
    newUser = retAction.payload.user
    success = true

    // Success: load the new user data into state.
    yield put({type: ADD_USER_SUCCESS, payload: newUser})

    // Select the new user.
    yield put({type: SELECT_USER, userId: newUser.id})

    // Change the route to edit the user.
    yield put({type: ROUTE_CHANGE, payload: {route: `/user/${newUser.id}`}})
  } catch (e) {
    console.log('Error in addUserSaga', e)
    yield put({type: ADD_USER_FAILURE, payload: action.payload})
  } finally {
    // Notifiy user.
    let userMsg = 'User added successfully.'
    let notifyAction = addSuccessNotification(userMsg)
    let notifyTimeout = successNotifyTimeout
    if (! success) {
      userMsg = 'Sorry, there was a problem adding the user.'
      notifyAction = addDangerNotification(userMsg)
      notifyTimeout = dangerNotifyTimeout
    }
    yield put(notifyAction)
    yield put(removeNotification(notifyAction.payload.id, notifyTimeout))
  }
}

export function* watchAddUser() {
  yield takeEvery(ADD_USER_REQUEST, addUserSaga)
}

