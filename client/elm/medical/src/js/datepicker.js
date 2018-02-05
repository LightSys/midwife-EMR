var app;                    // Set by setApp().

function handleSelection(id, selectedDateStr, dpInstance) {
  jQuery("#" + id).datepicker("hide");
  app.ports.selectedDate.send({dateField: id, date: selectedDateStr});
}

/* --------------------------------------------------------
 * openDatePicker()
 *
 * We open the datepicker but before we do we set defaults
 * because the element that the datepicker was attached to
 * probably was not on the page then the SPA started, so we
 * do it at the last possible moment.
 *
 * DatePicker Widget options (partial list):
 * changeMonth:     allows user to change month shown.
 * changeYear:      allows user to change year shown.
 * yearRange:       insures that a reasonable range of years
 *                  are shown to the user, e.g. "-60:+5" means
 *                  60 years before the current year and 5
 *                  years after.
 * showButtonPanel: show buttons at the bottom of the date
 *                  picker dialog with close and go to current
 *                  date buttons.
 * currentText:     The text on the go to current date button.
 * onSelect:        The function that handles user selection
 *                  of a date.
 * dateFormat:      The format of the date that is expected.
 *
 * param       id   an id as a string
 * -------------------------------------------------------- */
function openDatePicker(id) {
  var dp = jQuery("#" + id);
  dp.datepicker({
    changeMonth: true,
    changeYear: true,
    yearRange: "-60:+5",
    showButtonPanel: true,
    currentText: "Go to today",
    onSelect: function(value, instance) { handleSelection(id, value, instance); },
    dateFormat: "yy-mm-dd"
  });
  dp.datepicker().datepicker("show");
}

/* --------------------------------------------------------
 * setApp()
 *
 * Save the reference to the Elm client then subscribe to
 * messages coming from the Elm client and send them to
 * the server.
 * -------------------------------------------------------- */
var setApp = function(theApp) {
  app = theApp;

  app.ports.openDatePicker.subscribe(function(id) {
    openDatePicker(id);
  });
};

module.exports = {
  setApp: setApp
};
