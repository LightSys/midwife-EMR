/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * This is the root saga which must be a generator. All sagas are exposed from here.
 * -------------------------------------------------------------------------------
 */

import {fork} from 'redux-saga/effects'

import {watchSearchPatient} from './Search'
import {watchGetPregnancy} from './Pregnancy'
import {watchCheckInOut} from './CheckInOut'
import {watchLoadUserProfile} from './Profile'
import {watchAddUser} from './UsersRoles'
import {watchGetLookupTable} from './LookupTables'

export default function* rootSaga() {
  yield [
    fork(watchSearchPatient),
    fork(watchGetPregnancy),
    fork(watchCheckInOut),
    fork(watchLoadUserProfile),
    fork(watchAddUser),
    fork(watchGetLookupTable)
  ]
}

