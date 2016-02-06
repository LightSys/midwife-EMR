import {Schema, arrayOf, normalize} from 'normalizr'

export const CALL_API = Symbol('Call Api')

// Fetches an API response and normalizes the result JSON according to schema.
// This makes every API response have the same shape, regardless of how nested it was.
function callApi(endpoint, schema) {
  // This is not needed.
  //const fullUrl = (endpoint.indexOf(API_ROOT) === -1) ? API_ROOT + endpoint : endpoint

  // TODO: do something other than fetch here ...
  //return fetch(fullUrl)
    //.then(response =>
      //response.json().then(json => ({ json, response }))
    //).then(({ json, response }) => {
      //if (!response.ok) {
        //return Promise.reject(json)
      //}

      //const camelizedJson = camelizeKeys(json)
      //const nextPageUrl = getNextPageUrl(response)

      //return Object.assign({},
        //normalize(camelizedJson, schema),
        //{ nextPageUrl }
      //)
    //})

    return Promise.resolve()
}

export default store => next => action => {
  const callAPI = action[CALL_API]
  if (typeof callAPI === 'undefined') return next(action)

  let { key } = callAPI
  const { schema, types } = callAPI

  if (typeof key === 'function') {
    key = key(store.getState())
  }

  if (typeof key !== 'string') {
    throw new Error('Specify a string for key.')
  }
  if (!schema) {
    throw new Error('Specify one of the exported Schemas.')
  }
  if (!Array.isArray(types) || types.length !== 3) {
    throw new Error('Expected an array of three action types.')
  }
  if (!types.every(type => typeof type === 'string')) {
    throw new Error('Expected action types to be strings.')
  }

  function actionWith(data) {
    const finalAction = Object.assign({}, action, data)
    delete finalAction[CALL_API]
    return finalAction
  }

  const [ requestType, successType, failureType ] = types
  next(actionWith({ type: requestType }))

  return callApi(key, schema).then(
    response => next(actionWith({
      response,
      type: successType
    })),
    error => next(actionWith({
      type: failureType,
      error: error.message || 'Something bad happened'
    }))
  )
}

