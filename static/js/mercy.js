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
    // Midwife Interview: allow clicking on a row in the
    // pregnancy history table to go to that record.
    // --------------------------------------------------------
    $('.pregHistoryRow').click(function(evt) {
      evt.preventDefault();
      var histId = evt.currentTarget.id.split('-')[1]
        , pregId = evt.currentTarget.parentElement.id.split('-')[1]
        , path = '/pregnancy/' + pregId + '/preghistoryedit/' + histId
        ;
      window.location = path;
      return false;
    });

    // --------------------------------------------------------
    // Search Results: allow clicking on a row in the search
    // results screen to go to that record.
    // --------------------------------------------------------
    $('.searchResultsRow').click(function(evt) {
      evt.preventDefault();
      var recId = evt.currentTarget.id.split('-')[1]
        , path = '/pregnancy/' + recId + '/prenatal'
        ;
      window.location = path;
      return false;
    });

    // --------------------------------------------------------
    // User List: allow clicking on a row in the user list
    // screen to go to that record.
    // --------------------------------------------------------
    $('.userListRow').click(function(evt) {
      evt.preventDefault();
      var userId = evt.currentTarget.id.split('-')[1]
        , path = '/user/' + userId + '/edit'
        ;
      window.location = path;
      return false;
    });

    // --------------------------------------------------------
    // Role List: allow clicking on a row in the role list
    // screen to go to that record.
    // --------------------------------------------------------
    $('.roleListRow').click(function(evt) {
      evt.preventDefault();
      var roleId = evt.currentTarget.id.split('-')[1]
        , path = '/role/' + roleId + '/edit'
        ;
      window.location = path;
      return false;
    });

  })(window, jQuery, _);
});
