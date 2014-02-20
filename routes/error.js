/* 
 * -------------------------------------------------------------------------------
 * error.js
 *
 * Application wide error handling.
 * ------------------------------------------------------------------------------- 
 */


/* --------------------------------------------------------
 * logError()
 *
 * Log the error to stderr.
 * -------------------------------------------------------- */
var logError = function(err, req, res, next) {
  console.error(err.stack);
  next(err);
};

/* --------------------------------------------------------
 * exitError()
 *
 * Exit the process.
 * -------------------------------------------------------- */
var exitError = function(err, req, res, next) {
  console.error('Exiting application due to error.');
  process.exit(1);
};


module.exports = {
  logError: logError
  , exitError: exitError
};


