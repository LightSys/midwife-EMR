/*
 * -------------------------------------------------------------------------------
 * midwife-emr-home.js
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
     * param      line - true to do a line instead of bar chart (false)
     * return     undefined 
     * -------------------------------------------------------- */
    var doChart = function doChart(el, line, legend) {
      var $prenatalThisWeek = $(el)
        , data = $prenatalThisWeek.attr('data-data')
        , options = $prenatalThisWeek.attr('data-options')
        , divWidth = parseInt($prenatalThisWeek.css('width'), 10)
        , doLine = line? true: false
        , doLegend = legend? true: false
        , ticks = null
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
      // If the number of data elements is too high it will make
      // the axis labels hard to read, so we substitute our own
      // ticks function in order to eliminate some labels for
      // readability.
      // --------------------------------------------------------
      if (data.data.length > 15) {
        ticks = function(axis) {
          var tickArr = []
            , interval = Math.round(data.data.length / 15)
            ;
          _.each(data.data, function(dat, idx) {
            if (idx % interval === 0) {
              tickArr.push([idx, dat[0]]);
            }
          });
          return tickArr;
        };
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
            show: !doLine,
            barWidth: 0.6,
            align: "center"
          },
          lines: {
            show: doLine,
          }
        },
        legend: {
          show: doLegend,
          margin: [0, -40]  // Move legend outside of canvas so doesn't interfere with graph.
        },
        xaxis: {
          mode: "categories",
         ticks: ticks
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
          , topOffset = -15
          ;
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
      doChart('#prenatalHistoryByWeek', true, true);
    }


  })(window, jQuery, _, moment);
});
