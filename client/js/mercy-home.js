/*
 * -------------------------------------------------------------------------------
 * mercy-home.js
 *
 * Custom JS for the application for the home page.
 * -------------------------------------------------------------------------------
 */

// --------------------------------------------------------
// Load the module when the document is ready.
// --------------------------------------------------------
$(function() {
  (function(window, $, _, moment) {
    var data
      ;
    "use strict";

    // --------------------------------------------------------
    // Some versions of IE do not have a console so do nothing.
    // --------------------------------------------------------
    if (! window.console) window.console = {
      log: function() {}
      , error: function() {}
      , warn: function() {}
    };

    var writeDataValue = function writeDataValue($el, po, leftOffset, topOffset, val) {
      var left = po.left + leftOffset
        , top = po.top + topOffset
        , strArray = []
        ;
      strArray.push("<div style='position:absolute;left:");
      strArray.push(left);
      strArray.push("px;top:");
      strArray.push(top);
      strArray.push("px;color:#666;font-size:smaller'>");
      strArray.push(val);
      strArray.push("</div>");
      $el.append(strArray.join(''));
    };

    /* --------------------------------------------------------
     * doChart()
     *
     * Produce the barchart in the specified div. The div itself
     * is expected to have the data and options in the 'data-data'
     * and 'data-options' attributes respectively.
     *
     * param      el   - the jQuery selection criteria
     * return     undefined 
     * -------------------------------------------------------- */
    var doChart = function doChart(el) {
      var $prenatalThisWeek = $(el)
        , data = $prenatalThisWeek.attr('data-data')
        , options = $prenatalThisWeek.attr('data-options')
        , divWidth = parseInt($prenatalThisWeek.css('width'), 10)
        , plot
        ;

      // --------------------------------------------------------
      // Parse the data for the chart.
      // --------------------------------------------------------
      try {
        data = JSON.parse(data);
      } catch (e) {
        data = {};
      }

      // --------------------------------------------------------
      // Specify the options for the chart. Additional options or
      // options to override these can be specified in the
      // data-options attribute of the element specified.
      // --------------------------------------------------------
      options = _.extend({
        series: {
          //points: {show: true, fill: false},
          bars: {
            show: true,
            barWidth: 0.6,
            align: "center"
          }
        },
        xaxis: {
          mode: "categories",
          tickLength: 0,
        }
      }, options || {});

      // --------------------------------------------------------
      // Generate the barchart.
      // --------------------------------------------------------
      plot = $.plot(el, [ data ], options);

      // --------------------------------------------------------
      // Put the human-readable data value near the top of each bar.
      // --------------------------------------------------------
      _.each(data.data, function(bar, idx) {
        var value = bar[1]
          , o = plot.pointOffset({x: idx, y: value})
          , leftOffset = -6
          , topOffset = 4
          ;
        if (value < 4) topOffset -= 20;
        writeDataValue($prenatalThisWeek, o, leftOffset, topOffset, value);
      });
    };

    // --------------------------------------------------------
    // Activate on the home page only.
    // --------------------------------------------------------
    if (window.location.pathname === '/') {
      // --------------------------------------------------------
      // Instantiate the prenatal exams this week chart.
      // --------------------------------------------------------
      doChart('#prenatalThisWeek');
      doChart('#prenatalHistory');
    }


  })(window, jQuery, _, moment);
});
