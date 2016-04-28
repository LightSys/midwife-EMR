import {API_ROOT} from '../constants/index'
import {getUniqueId} from '../utils/index'

// --------------------------------------------------------
// Default options used for all server calls.
// --------------------------------------------------------
let options = {
  credentials: 'same-origin',   // Applies _csrf and connection.sid cookies.
  method: 'GET'
}

export const makeGetAction = (types, test, path, schema, opts) => {
  const callOpts = Object.assign({}, options, opts)
  return (dispatch, getState) => {
    return dispatch({
      payload: {
        types: types,
        test: test,
        call: () => fetch(`${API_ROOT}/${path}`, callOpts),
        schema: schema,
        notifyUser: false
      },
      meta: {
        dataMiddleware: true
      }
    })
  }
}

/* --------------------------------------------------------
 * makePostAction()
 *
 * Makes a POST action.
 *
 * If meta.noIdInUrl is true, then the id is not specified
 * in the url.
 * -------------------------------------------------------- */
export const makePostAction = (types, test, path, schema, opts, data, meta) => {
  const callOpts = Object.assign({}, options, opts)
  return (dispatch, getState) => {
    const {_csrf} = getState().authentication.cookies
    callOpts.method = 'POST'
    callOpts.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
    callOpts.body = JSON.stringify(Object.assign({}, data, {_csrf}))

    // Don't specify id in url if explicitly told not to.
    let url
    const {id} = data
    if (meta && meta.noIdInUrl) {
      url = `${API_ROOT}/${path}`
    } else {
      url = `${API_ROOT}/${path}/${id}`
    }

    let metaObj = Object.assign({}, meta, {dataMiddleware: true, optimistId: getUniqueId()})
    dispatch({
      payload: {
        types: types,
        call: () => fetch(url, callOpts),
        schema: schema,
        notifyUser: true,
        data: data
      },
      meta: metaObj
    })
  }
}

// --------------------------------------------------------
// Fewer options passed, no schema, no optimist, full path
// expected with id and any other path segments.
// --------------------------------------------------------
export const makeSimplePostAction = (types, path, data, notify) => {
  const callOpts = Object.assign({}, options)
  return (dispatch, getState) => {
    const {_csrf} = getState().authentication.cookies
    callOpts.method = 'POST'
    callOpts.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
    callOpts.body = JSON.stringify(Object.assign({}, data, {_csrf}))
    let metaObj = Object.assign({}, {dataMiddleware: true})
    dispatch({
      payload: {
        types: types,
        call: () => fetch(`${API_ROOT}/${path}`, callOpts),
        notifyUser: notify,
        data: data
      },
      meta: metaObj
    })

  }
}

