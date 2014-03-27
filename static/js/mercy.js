/*
 * -------------------------------------------------------------------------------
 * mercy.js
 *
 * Custom JS for the application.
 * -------------------------------------------------------------------------------
 */

// --------------------------------------------------------
// Load the module when the document is ready.
// --------------------------------------------------------
$(function() {
  (function(window, $, _) {
    "use strict";

    // --------------------------------------------------------
    // Some versions of IE do not have a console so do nothing.
    // --------------------------------------------------------
    if (! window.console) window.console = {
      log: function() {}
      , error: function() {}
      , warn: function() {}
    };

    /* --------------------------------------------------------
    * disableOnChange()
    * enableOnChange()
    * visibleOnChange()
    *
    * Toggle the corresponding CSS class pertaining to the function
    * names below. Each function expects a String as a parameter
    * that specifies the jQuery selector to use. The target element
    * to toggle is expected to be a child of this selector AND have
    * the class named 'disable-on-change' or 'enable-on-change' or
    * 'visible-on-change', respective to the function called. Usually
    * the selector is a form id and the element is within the form.
    *
    * disableOnChange(): adds the 'disabled' class to the element.
    * enableOnChange(): removes the 'disabled' class from the element.
    * visibleOnChange(): removes the 'invisible' class from the element.
    *
    * param       formSpec - form selection per jQuery
    * return      undefined
    * -------------------------------------------------------- */
    var disableOnChange = function(formSpec) {
      $(formSpec).change(function() {
        $(formSpec).find('.disable-on-change').addClass('disabled');
      });
    };
    var enableOnChange = function(formSpec) {
      $(formSpec).change(function() {
        $(formSpec).find('.enable-on-change').removeClass('disabled');
      });
    };
    var visibleOnChange = function(formSpec) {
      $(formSpec).change(function() {
        $(formSpec).find('.visible-on-change').removeClass('invisible');
      });
    };

    /* --------------------------------------------------------
     * handleRowClick()
     *
     * Curry function that handles a click event on a row in a
     * table. Expects the id attribute in the row to be in the
     * format of something-ID where ID is a number. Expects the
     * path passed to be in the format 'prefix/:id/postfix'.
     * It will replace :id in the path with the id derived from
     * the id of the row when the click event occurs.
     *
     * Will handle the id of the parent element in the same format
     * and place the id in the ':pid' placeholder if found. E.g.
     * '/somepath/:id/morepath/:pid' evaluates to 
     * '/somepath/23/morepath/1'.
     *
     * param       path - 'something/:id/somethingElse'
     * return      function - handles the click event
     * -------------------------------------------------------- */
    var handleRowClick = function(path) {
      return function(evt) {
        var id = evt.currentTarget.id.split('-')[1]
          , pid = evt.currentTarget.parentElement.id.split('-')[1]
          , url = path.replace(':id', id)
          ;
        if (pid && path.indexOf(':pid') !== -1) {
          url = url.replace(':pid', pid);
        }
        evt.preventDefault();
        window.location = url;
        return false;
      };
    };

    // --------------------------------------------------------
    // Respond to changes in these forms.
    // --------------------------------------------------------
    disableOnChange('#addPregForm');  // Midwife Interview Add Pregnancy Back button
    disableOnChange('#editPregForm');  // Midwife Interview Edit Pregnancy Back button
    disableOnChange('#midwifeForm');  // Midwife Interview Add Pregnancies button
    visibleOnChange('#midwifeForm');  // Midwife Interview explanation text
    disableOnChange('#prenatalForm');  // Prenatal Add prenatal exam button
    visibleOnChange('#prenatalForm');  // Prenatal Add explanation text


    // --------------------------------------------------------
    // Handle clicks in tables by retrieving a child page.
    // --------------------------------------------------------
    // Search results.
    $('.searchResultsRow').click(handleRowClick('/pregnancy/:id/prenatal'));

    // Midwife Interview screen, pregnancy history.
    $('.pregHistoryRow').click(handleRowClick('/pregnancy/:pid/preghistoryedit/:id'));

    // Prenatal screen, prenatal exams.
    $('.prenatalExamRow').click(handleRowClick('/pregnancy/:pid/prenatalexamedit/:id'));

    // List of users.
    $('.userListRow').click(handleRowClick('/user/:id/edit'));

    // List of roles.
    $('.roleListRow').click(handleRowClick('/role/:id/edit'));


  })(window, jQuery, _);
});
