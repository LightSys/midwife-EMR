/* 
 * -------------------------------------------------------------------------------
 * tests.js
 *
 * Various browser tests we may want to run to ascertain our environment.
 * ------------------------------------------------------------------------------- 
 */

/* --------------------------------------------------------
 * isDateInput()
 *
 * Test whether the browser supports inputs with a type of
 * 'date'. Returns true if the browser supports an input
 * of type date.
 * -------------------------------------------------------- */
function supportsDateInput() {
  var test = document.createElement('input');
  test.type = 'date';
  return test.type === 'date';
}


module.exports = {
  supportsDateInput
}
