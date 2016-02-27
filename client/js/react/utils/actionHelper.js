import {API_ROOT} from '../constants/index'

// --------------------------------------------------------
// Default options used for all server calls.
// --------------------------------------------------------
let options = {
  credentials: 'same-origin',   // Applies _csrf and connection.sid cookies.
  method: 'GET'
}

/* --------------------------------------------------------
 * getTransactionId()
 *
 * Returns a transaction id for use with redux-optimist.
 * -------------------------------------------------------- */
let nextTransactionId = 1
const getTransactionId = () => {
  return nextTransactionId++
}

export const makeGetAction = (types, test, path, schema, opts) => {
  const callOpts = Object.assign({}, options, opts)
  return (dispatch, getState) => {
    return dispatch({
      payload: {
        types: types,
        test: test,
        call: () => fetch(`${API_ROOT}/${path}`, callOpts),
        schema: schema
      },
      meta: {
        dataMiddleware: true
      }
    })
  }
}

export const makePostAction = (types, test, path, schema, opts, data, meta) => {
  const callOpts = Object.assign({}, options, opts)
  return (dispatch, getState) => {
    const {_csrf} = getState().cookies
    callOpts.method = 'POST'
    callOpts.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
    callOpts.body = JSON.stringify(Object.assign({}, data, {_csrf}))
    const {id} = data
    let metaObj = Object.assign({}, meta, {dataMiddleware: true, optimistId: getTransactionId()})
    dispatch({
      payload: {
        types: types,
        call: () => fetch(`${API_ROOT}/${path}/${id}`, callOpts),
        schema: schema,
        data: data
      },
      meta: metaObj
    })
  }
}

