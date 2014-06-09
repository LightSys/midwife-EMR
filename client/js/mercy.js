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
  (function(window, $, _, moment) {
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
    * calcEdd()
    *
    * Calculate the estimated due date based upon the date of
    * the last mentral period passed. The returned date is a
    * String in YYYY-MM-DD format.
    *
    * NOTE: this function is also included in util.js on the
    * server side. Changes made here should also be made there.
    *
    * param       lmp - date of the last mentral period
    * return      edd - due date as a String
    * -------------------------------------------------------- */
    var calcEdd = function(lmp) {
      if (! lmp) throw new Error('calcEdd() must be called with the lmp date.');
      var edd
        ;
      if (! (moment(lmp)).isValid()) {
        throw new Error('calcEdd() must be called with a valid date.');
      }
      edd = moment(lmp).add('days', 280);
      return edd.format('YYYY-MM-DD');
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
     * onClickChangeLocation()
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
    var onClickChangeLocation = function(path) {
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
    $('.searchResultsRow').click(onClickChangeLocation('/pregnancy/:id/prenatal'));

    // Midwife Interview screen, pregnancy history.
    $('.pregHistoryRow').click(onClickChangeLocation('/pregnancy/:pid/preghistory/:id'));

    // Prenatal screen, prenatal exams.
    $('.prenatalExamRow').click(onClickChangeLocation('/pregnancy/:pid/prenatalexam/:id'));

    // List of users.
    $('.userListRow').click(onClickChangeLocation('/user/:id/edit'));

    // List of roles.
    $('.roleListRow').click(onClickChangeLocation('/role/:id/edit'));

    // Lab tests
    $('.labTestResultsRow').click(onClickChangeLocation('/pregnancy/:pid/labtest/:id'));

    // Referrals
    $('.referralsRow').click(onClickChangeLocation('/pregnancy/:pid/referral/:id'));

    // Vaccinations
    $('.vaccinationsRow').click(onClickChangeLocation('/pregnancy/:pid/vaccination/:id'));

    // Medications
    $('.medicationsRow').click(onClickChangeLocation('/pregnancy/:pid/medication/:id'));


    // --------------------------------------------------------
    // Prenatal screen: automatically pre-fill the estimated
    // due date based upon the lmp date if the edd is not
    // already filled in.
    // --------------------------------------------------------
    $('#prenatal-lmp').on('blur', function(evt) {
      var lmp = moment(evt.target.value)
        , eddFld = $('#prenatal-edd')
        ;
      if (eddFld.val().length == 0) {
        try {
          eddFld.val(calcEdd(lmp));
        } catch (e) {
          // Must not have contained a valid date.
          console.log(e);
        }
      }
    });

    // --------------------------------------------------------
    // POST changes to the required tetanus field (radio buttons)
    // to the server using AJAX.
    // --------------------------------------------------------
    $('input[name="numberRequiredTetanus"]').on('click', function(evt) {
      var val = evt.currentTarget.value
        , myself = $(this)
        , recId = myself.attr('data-recId')
        , token = myself.attr('data-token')
        , url = '/pregnancy/' + recId + '/requiredtetanus'
        , data = {}
        ;
      data._csrf = token; data.numberRequiredTetanus = val;
      $.post(url, data, function() {
        //console.log('Success');
      })
      .fail(function() {
        alert('Sorry, unable to save the number of required tetanus.');
        // Since the radio button has already been changed by the user now
        // the database is out of sync. Reload the page to show the user
        // the same thing as what is in the database or force the user
        // to login again if that is the issue.
        window.location.reload();
      });
      // Allow the radio button to select the value.
      return true;
    });


  })(window, jQuery, _, moment);
});
