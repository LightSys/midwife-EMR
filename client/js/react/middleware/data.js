import fetch from 'isomorphic-fetch'
import {omit, isEmpty} from 'underscore'
import {normalize} from 'normalizr'
import {BEGIN, COMMIT, REVERT} from 'redux-optimist'

// --------------------------------------------------------
// Handle any action with a meta object that has a
// dataMiddleware element set to true. Assumes that the
// action has a payload element.
//
// Action
//    meta
//      dataMiddleware  - required
//      optimistId      - optional, if present is the id for redux-optimist
//    payload
//      types           - required, array of 3 actions
//      call            - required, async function
//      test            - optional, function returns true to run
//      schema          - optional, if present uses normalize
//      data            - optional, if present passes to requestType for optimist
// --------------------------------------------------------
export default ({dispatch, getState}) => next => action => {
  // Determine if we are meant to be activated.
  if (! action.meta || ! action.meta.dataMiddleware) {
    return next(action)
  }
  if (! action.payload) return next(action)

  const {
    types,
    call,
    test,
    schema,
    data
  } = action.payload

  // --------------------------------------------------------
  // Sanity checks.
  // --------------------------------------------------------
  if (! types || ! Array.isArray(types) || types.length !== 3) {
    throw new Error('Expected an array of three in the types element.')
  }
  if (typeof call !== 'function') {
    throw new Error('Expected call element to be a function.')
  }
  if (test && typeof test === 'function') {
    // A function named test is optional, but if exists, use it to
    // determine if we should do any work.
    if (! test(getState())) return
  }

  // --------------------------------------------------------
  // Determine if this call should use redux-optimist.
  // --------------------------------------------------------
  let isOptimist = false
  let optimistId
  if (action.meta && action.meta.hasOwnProperty('optimistId')) {
    isOptimist = true
    optimistId = action.meta.optimistId
  }

  // --------------------------------------------------------
  // Create the next action without the elements particular
  // to a dataMiddleware call.
  // --------------------------------------------------------
  const makeNextAction = (type, payload, meta, optimist) => {
    let newAction = {
      type: type,
      payload: Object.assign({}, omit(payload, ['types', 'test'])),
      meta: Object.assign({}, omit(meta, 'dataMiddleware'))
    }
    if (optimist) newAction.optimist = Object.assign({}, optimist)
    return newAction
  }

  // --------------------------------------------------------
  // Extract the three actions and dispatch the first one.
  // --------------------------------------------------------
  const [requestType, successType, failureType] = action.payload.types
  if (isOptimist) {
    next(makeNextAction(requestType, action.payload, action.meta, {type: BEGIN, id: optimistId}))
  } else {
    next(makeNextAction(requestType, action.payload, action.meta))
  }

  // --------------------------------------------------------
  // Execute the call function passed in the action.
  // --------------------------------------------------------
  let error = false
  let jsonError = false
  return call()
    .then(response => {
      if (! response.ok) {
        // --------------------------------------------------------
        // Flag as an unrecoverable error and throw to the catch below.
        // --------------------------------------------------------
        error = true
        throw response.statusText
      }
      // Extract JSON from the response, if available.
      return response
        .json()
        // Flag as JSON not being available, which might be an error or not.
        .catch(e => jsonError = true)
        .then(json => {
          return { json, response }
        })
    })
    .catch((err) => {
      // --------------------------------------------------------
      // Handle unrecoverable server error.
      // --------------------------------------------------------
      console.log(`Server error during call for ${requestType}`, err)
      let nextAction
      if (isOptimist) {
        nextAction = makeNextAction(failureType, action.payload, action.meta, {type: REVERT, id: optimistId})
      } else {
        nextAction = makeNextAction(failureType, action.payload, action.meta)
      }
      dispatch(nextAction)
      // Set empty objects so that destructurings below do not die.
      return {json: {}, response: {}}
    })
    .then(({json, response}) => {
      if (error) return {json, response}  // Unrecoverable error.

      // --------------------------------------------------------
      // Normalize json if it needs it, otherwise return something
      // that passes the destructuring below.
      // --------------------------------------------------------
      if (jsonError || isEmpty(json) || ! schema) return {json, response}
      return {json: normalize(json, schema), response}
    })
    .then(({json, response}) => {
      if (error) return                 // Unrecoverable error.

      // --------------------------------------------------------
      // Dispatch final successful action type with results.
      // --------------------------------------------------------
      let nextAction
      if (isOptimist) {
        nextAction = makeNextAction(successType, {json}, action.meta, {type: COMMIT, id: optimistId})
      } else {
        nextAction = makeNextAction(successType, {json}, action.meta)
      }
      dispatch(nextAction)
    })
}


