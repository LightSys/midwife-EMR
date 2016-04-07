
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
    var error = new Error(response.statusText)
    error.response = response
    throw error
  }
}

