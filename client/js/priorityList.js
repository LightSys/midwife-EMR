/*
 * -------------------------------------------------------------------------------
 * priorityList.js
 *
 * Client-side JS for AJAX calls to server to refresh data and send user changes.
 * -------------------------------------------------------------------------------
 */


// --------------------------------------------------------
// Load the module when the document is ready.
// --------------------------------------------------------
$(function() {
  (function(window, $, _, moment) {
    "use strict";

    // --------------------------------------------------------
    // The url that this module is concerned with. If the
    // current location matches this url, the module is activated.
    // --------------------------------------------------------
    var priorityListUrl = '/priorityList';

    // --------------------------------------------------------
    // The urls to retrieve the data and save data changes for
    // a particular client. Note that the save url has a
    // placeholder in it for the id.
    // --------------------------------------------------------
    var priorityListDataUrl = '/priorityList';
    var priorityListSaveUrl = '/priorityList/:id/save';

    // --------------------------------------------------------
    // The amount of time in milliseconds between attempts to
    // refresh the data from the server.
    // --------------------------------------------------------
    var refreshPeriod = 30 * 1000;    // 30 seconds

    var ajaxData = {}             // Sent with every AJAX call.
      , updateInProgress = false  // Do not allow refreshes while saves are active.
      ;

    /* --------------------------------------------------------
     * getData()
     *
     * Gets the data from the server.
     *
     * param      cb - the callback to pass the data to.
     * return     undefined
     * -------------------------------------------------------- */
    var getData = function getData(cb) {
      if (! updateInProgress) {
        $.ajax({
          url: priorityListDataUrl
          , type: 'POST'
          , data: ajaxData
          , dataType: 'json'
          , success: function(data, textStatus, jqXHR) {
              cb(data);
            }
        });
      }
    };

    /* --------------------------------------------------------
     * saveData()
     *
     * Saves the user's choice regarding whether the chart is
     * pulled or not. Choice is sent to the server via AJAX.
     *
     * param      pregId    - pregnancy id
     * param      isChecked - whether the chart is pulled or not
     * param      cb        - the callback
     * return     undefined 
     * -------------------------------------------------------- */
    var saveData = function saveData(pregId, isChecked, cb) {
      var myData = _.clone(ajaxData)
        , saveUrl = priorityListSaveUrl.replace(':id', pregId)
        ;
      myData.pregnancy_id = pregId;
      myData.isChecked = isChecked;
      $.ajax({
        url: saveUrl
        , type: 'POST'
        , data: myData
        , dataType: 'json'
        , success: function(data, textStatus, jqXHR) {
            cb(null, data);
          }
        , error: function(jqXHR, textStatus, error) {
            cb(error);
          }
      });
    };

    /* --------------------------------------------------------
     * makeId()
     *
     * Makes an HTML id based upon the id passed.
     *
     * param       id - in our case the client id
     * return      string with the id in it
     * -------------------------------------------------------- */
    var makeId = function makeId(id) {
      return 'recordId-' + id;
    };

    /* --------------------------------------------------------
     * getId()
     *
     * Returns the pregnancy id portion of the id passed. Assumes
     * that the parameter id was created with makeId() and is
     * in the format "record-nnn" where nnn is the pregnancy id.
     *
     * param       id
     * return      pregnancy id
     * -------------------------------------------------------- */
    var getId = function getId(id) {
      return id.split('-')[1];
    };

    /* --------------------------------------------------------
     * makeCell()
     *
     * Make a table cell (column) using the text as the content
     * and optionally creating an id for the cell.
     *
     * param      text - data within the cell
     * param      id - id to set on the element
     * return     html as a string
     * -------------------------------------------------------- */
    var makeCell = function makeCell(text, id) {
      var col = '<td';
      if (id) {
        col += ' id="' + id + '"';
      }
      col += '>' + text + '</td>';
      return col;
    };

    /* --------------------------------------------------------
     * refreshData()
     *
     * Refresh the data in the display with the data received
     * from the server.
     *
     * param      data - array of JSON objects representing clients
     * return     undefined
     * -------------------------------------------------------- */
    var refreshData = function refreshData(data) {
      var $tbody = $('#priorityListTable tbody')
        , numRows = $tbody.find('tr').length
        , rowEnd = '</tr>'
        , newRows = []
        , checked = '<i class="fa fa-check"></i>'
        , unchecked = ''
        , chartPulledUnchecked = '<input type="checkbox" name="chartPulled" value="1">'
        , chartPulledChecked = '<input type="checkbox" name="chartPulled" value="1" checked>'
        ;

      _.each(data, function(rec) {
        var id = makeId(rec.id)
          , rowStart = '<tr class="dataRows" id="' + id + '">'
          , colPri =  makeCell(rec.priority)
          , colName = makeCell(rec.lastname + ', ' + rec.firstname)
          , colMmc = makeCell(rec.dohID)
          , colIn = makeCell(rec.checkIn)
          , colChart = rec.chartPulled? makeCell(chartPulledChecked): makeCell(chartPulledUnchecked)
          , colWgt = rec.wgt? makeCell(checked): makeCell(unchecked)
          , colBP = rec.systolic? makeCell(checked): makeCell(unchecked)
          , colExam = rec.prenatalExam? makeCell(checked): makeCell(unchecked)
          , colOut = makeCell(rec.checkOut)
          , row = rowStart + colPri + colName + colMmc + colIn + colChart + colWgt +
                  colBP + colExam + colOut + rowEnd
          , currRec
          ;
        currRec = $tbody.find('#' + id);
        if (currRec.length === 0) {
          // --------------------------------------------------------
          // A row with this id does not yet exist, create it.
          // --------------------------------------------------------
          newRows.push(row);
        } else {
          // --------------------------------------------------------
          // A row with this id already exists, update it.
          // TODO: only replace cells that have changed.
          // --------------------------------------------------------
          $('#' + id).replaceWith(row);
        }
      });
      $tbody.append(newRows);
    };

    // --------------------------------------------------------
    // We only activate on one page, everything else is ignored.
    // --------------------------------------------------------
    if (window.location.pathname === priorityListUrl) {
      // --------------------------------------------------------
      // We need the CSRF token in order to use AJAX with the server.
      // --------------------------------------------------------
      ajaxData._csrf = $('#csrfToken').val();

      // --------------------------------------------------------
      // At load start things off by getting the data right away.
      // --------------------------------------------------------
      getData(refreshData);

      // --------------------------------------------------------
      // Do not allow the form to be submitted since it will be
      // handled with AJAX.
      // --------------------------------------------------------
      $('form#priorityListForm').submit(function(evt) {
        evt.preventDefault();
      });

      // --------------------------------------------------------
      // Watch for user to "check" when charts have been pulled
      // and update server accordingly.
      // --------------------------------------------------------
      $('form#priorityListForm table tbody')
        .on('click', 'tr input:checkbox[name="chartPulled"]', function(evt) {
          var $this = $(this)
            , isChecked = !! $this.is(':checked')
            , pregId = getId($this.parents('tr.dataRows').attr('id'))
            ;
          updateInProgress = true;
          saveData(pregId, isChecked, function(err, data) {
            if (err) console.error(err);
            updateInProgress = false;
          });
      });

      // --------------------------------------------------------
      // Thereafter periodically refresh the data from the server.
      // --------------------------------------------------------
      setInterval(function() {
        getData(refreshData);
      }, refreshPeriod);
    }

  })(window, jQuery, _, moment);
});


