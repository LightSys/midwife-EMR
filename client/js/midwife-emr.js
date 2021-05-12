/*
 * -------------------------------------------------------------------------------
 * midwife-emr.js
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

    // --------------------------------------------------------
    // Auto expanding text areas. Adapted from "Expanding Text
    // Areas Made Elegant", http://alistapart.com/article/expanding-text-areas-made-elegant.
    //
    // This is the JS component of the "textarea" Jade component
    // in the mixins folder. There is also CSS.
    // --------------------------------------------------------
    $('div.expandingArea').each(function() {
      var area = $('textarea', $(this));
      var span = $('span', $(this));
      area.bind('input', function() {
        span.text(area.val());
      });
      span.text(area.val());
      $(this).addClass('active');
    });

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
    // Warn user if tries to navigate away with unsaved changes.
    // Uses jQuery.areYouSure plugin. Only affects forms that
    // have class 'dirty-check' in them.
    // --------------------------------------------------------
    $('form.dirty-check').areYouSure();

    // --------------------------------------------------------
    // Provide a visual clue to the user when the form data has
    // changed so that the user knows there are pending changes.
    // --------------------------------------------------------
    $('form.dirty-check').on('dirty.areYouSure', function() {
      $('#dirty-notice').show();
      $('#dirty-notice-tablet').show();
    });
    $('form.dirty-check').on('clean.areYouSure', function() {
      $('#dirty-notice').hide();
      $('#dirty-notice-tablet').hide();
    });

    // --------------------------------------------------------
    // Handle clicks in tables by retrieving a child page.
    // --------------------------------------------------------
    // Search results.
    $('.searchResultsRow').click(onClickChangeLocation('/pregnancy/:id/prenatal'));
    $('.searchResultsRowGuard').click(onClickChangeLocation('/pregnancy/:id/checkinout'));

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

    // Progress Notes
    $('.pregnoteRow').click(onClickChangeLocation('/pregnancy/:pid/pregnote/:id'));

    // health teachings
    $('.teachingsRow').click(onClickChangeLocation('/pregnancy/:pid/teaching/:id'));

    // Vaccinations
    $('.vaccinationsRow').click(onClickChangeLocation('/pregnancy/:pid/vaccination/:id'));

    // Medications
    $('.medicationsRow').click(onClickChangeLocation('/pregnancy/:pid/medication/:id'));


    // --------------------------------------------------------
    // Add and configure datepickers for all inputs that are
    // for dates. We don't use HTML5 input with type of date
    // because it is extremely inconsistent across browsers.
    // We are using jQuery UI's Datepicker instead.
    //
    // Inputs that are targeted will have the class 'datepicker'.
    //
    // The database expects dates in YYYY-MM-DD format while the
    // client wants dates in MM/DD/YYYY format for display.
    // Therefore we use a hidden field for each date that is
    // populated by the Datepicker with the value that the user
    // has chosen in the format required by the backend. The
    // input that the user sees displays the same date in the
    // format that the user expects. This is a feature of the
    // jQuery Datepicker widget using the altField and altFormat
    // options of Datepicker.
    //
    // The input field and the hidden field are linked by a data
    // field within the input element named 'data-alt-field'. If
    // found, the alternate field option is used. The value of
    // data-alt-field should be the id of the hidden field in
    // the format expected by a jQuery selector, e.g. '#altField-dob'.
    // Both fields should have the value attribute set if the
    // value is coming from the database on page load.
    //
    // <input type='text' class='datepicker' data-alt-field='#altField-dob' name='displayField-dob'>
    // <input type='hidden' id='altField-dob' name='dob'>
    //
    // Note that Datepicker date format specs and the Moment
    // library format specs vary, i.e. 'mm/dd/yy' = 'MM/DD/YYYY'.
    //
    // Default date is specifed with the data-defaultDate data
    // field. Datepicker accepts JS Date objects, date strings,
    // or period representations from today such as '+1m'. See
    // datepicker docs for details.
    //
    // TODO: handle display format in the configuration file or
    // some other user setting along with locale, etc.
    // --------------------------------------------------------
    $('.datepicker').each(function() {
      var $fld = $(this)
        , altFld = $fld.attr('data-alt-field')
        , defaultDate = $fld.attr('data-defaultDate')
        , onClose = function onClose(dateStr, dp) {
            if (dateStr.length === 0) $(this).datepicker('setDate', null);
          }
        , initDpOpts = {dateFormat: 'yy-mm-dd', altFormat: 'yy-mm-dd', onClose: onClose}
        , val = $fld.val()
        ;
      $fld.datepicker(initDpOpts);  // For initial load of date from field.
      if (val && val !== 'Invalid date') {
        $fld.datepicker('option', 'defaultDate', moment(val, 'YYYY-MM-DD').toDate());
      } else {
        if (defaultDate) {
          $fld.datepicker('option', 'defaultDate', defaultDate);
        }
      }
      if (altFld) {
        $fld.datepicker('option', 'altField', altFld);
      }
      // After the pre-existing date is loaded, set format to client display format.
      $fld.datepicker('option', 'dateFormat', 'mm/dd/yy');
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

    // --------------------------------------------------------
    // Watch for form submission and sanity check field values
    // of the general page in regard to date of birth. We don't
    // prevent the user from entering dates outside the expected
    // range, nor even prevent the submission. We just alert the
    // user so that it can be corrected if necessary.
    // --------------------------------------------------------
    $('form[name="pregnancyForm"]').on('submit', function(evt) {
      var $dob = $('input[name="dob"]')
        , dobDate
        , age
        ;
      if ($dob) {
        if ($dob.val()) {
          dobDate = moment($dob.val(), 'YYYY-MM-DD');
          age = moment().diff(dobDate, 'years');
          if (dobDate && dobDate.isValid() && (age < 11 || age > 50)) {
            alert('Are you sure about the date of birth?');
          }
        } else {
          alert('Did you forget to enter the date of birth?');
        }
      }
    });

    // --------------------------------------------------------
    // Report opens in another tab but leaves the form unusable.
    // Delay gives time for the report process to start and
    // eventually provide a download prompt to the user. In the
    // meantime, page reload on the form resets the original
    // report form.
    // --------------------------------------------------------
    $('input[id="reportFormDownloadPdf"]').on('click', function(evt) {
      setTimeout(function() {
        window.location.reload();
      }, 1000);
    });

    // --------------------------------------------------------
    // Disable inputs with the disable-on-submit class to help
    // prevent users from double tapping buttons to submit, or
    // worse, pressing repeatedly for reasons unknown.
    // --------------------------------------------------------
    $('.disable-on-submit').on('submit', function(evt) {
      $('.disable-on-submit input[type="submit"], .disable-on-submit button[type="submit"]').prop('disabled', true);
    });

    // --------------------------------------------------------
    // Hande jump to inputs denoted by the jump-to-input class.
    // Read the value of the data-jump-to attribute to determine
    // the value to set on the element pointed to by the
    // data-jump-hidden attribute. Finally, submit the form which
    // will include the name/value pair with the name as specified
    // in the hidden field and the value as specified in the
    // data-jump-to attribute.
    // --------------------------------------------------------
    $('.jump-to-input').on('click', function(evt) {
      var btn = $(this)
        , jumpTo
        , hidden
        , form
        ;
      jumpTo = btn.attr('data-jump-to');
      hidden = btn.attr('data-jump-hidden');
      if (jumpTo && hidden) {
        $(hidden).val(jumpTo);
        form = btn.parents('form')[0];
        // Prevent the 'are you sure' message since we are doing a submit
        // and not just leaving the page with unsaved changes.
        $(form).trigger('reinitialize.areYouSure');
        form.submit();
      }
    });

  })(window, jQuery, _, moment);
});
