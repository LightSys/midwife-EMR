import {takeEvery} from 'redux-saga'

import {getLookupTable} from '../services/comm'

import {
  DATA_TABLE_REQUEST
} from '../constants/ActionTypes'

export function* getLookupTableSaga(action) {
  const table = action.payload.table
  getLookupTable(table)
}

export function* watchGetLookupTable() {
  yield* takeEvery(DATA_TABLE_REQUEST, getLookupTableSaga)
}

