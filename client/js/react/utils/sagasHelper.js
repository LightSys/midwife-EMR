
/* --------------------------------------------------------
 * checkStatus()
 *
 * Check the status of fetch operations.
 *
 * Adapted from: https://github.com/github/fetch
 * -------------------------------------------------------- */
export const checkStatus = (response)  => {
  if (response.status >= 200 && response.status < 300) {
    return response
  } else {
    const error = new Error(response.statusText)
    error.response = response
    error.status = response.status
    return response
      .json()
      .catch(e => {
        // Server did not send anything.
        throw error
      })
      .then(json => {
        error.json = json
        throw error
      })
  }
}

