import {Schema, arrayOf, normalize} from 'normalizr'
import fetch from 'isomorphic-fetch'

const API_ROOT = '/api/data/'
const METHODS = ['DELETE', 'GET', 'POST', 'PUT']

export const CALL_API = Symbol('Call Api')

// Fetches an API response and normalizes the result JSON according to schema.
// This makes every API response have the same shape, regardless of how nested it was.
function callApi(serverPath, method, schema) {
  const fullUrl = (serverPath.indexOf(API_ROOT) === -1) ? API_ROOT + serverPath : serverPath
  const options = {
    credentials: 'include',
    method: method
  }

  console.log('callApi(): fullUrl: ', fullUrl, ', serverPath: ', serverPath)
  return fetch(fullUrl, options)
    .then(response =>
      response.json().then(json => ({ json, response }))
    )
    .then(({ json, response }) => {
      console.log(`Reponse from Server: ${response.status}`)
      if (!response.ok) {
        console.log('response.ok: ', response.ok)
        return Promise.reject(json)
      }

      const normalJson = normalize(json, schema)
      //console.log('normalJson: ', normalJson)
      return Object.assign({}, normalJson)
    })

    return Promise.resolve()
}

// --------------------------------------------------------
// Schemas.
// --------------------------------------------------------
const userSchema = new Schema('users', {
  idAttribute: 'id'
})

const roleSchema = new Schema('roles', {
  idAttribute: 'id'
})

userSchema.define({
  role: roleSchema
})

export const Schemas = {
  USER: userSchema,
  USER_ARRAY: arrayOf(userSchema),
  ROLE: roleSchema,
  ROLE_ARRAY: arrayOf(roleSchema)
}


export default store => next => action => {
  const callAPI = action[CALL_API]
  if (typeof callAPI === 'undefined') return next(action)

  let {serverPath} = callAPI
  const {schema, types, method='GET'} = callAPI

  if (typeof serverPath === 'function') {
    serverPath = serverPath(store.getState())
  }

  if (typeof serverPath !== 'string') {
    throw new Error('Specify a string for serverPath.')
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
  if (typeof method !== 'string') {
    throw new Error('Expected method to be a string.')
  }
  if (METHODS.indexOf(method) === -1) {
    throw new Error(`Unexpected method encounted: ${method}`)
  }

  function actionWith(data) {
    const finalAction = Object.assign({}, action, data)
    delete finalAction[CALL_API]
    return finalAction
  }

  const [ requestType, successType, failureType ] = types
  next(actionWith({ type: requestType }))

  return callApi(serverPath, method, schema).then(
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

