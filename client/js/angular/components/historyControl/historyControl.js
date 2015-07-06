;(function(angular) {

  'use strict';

  angular.module('historyControlModule', [])
    .directive('historyControl', ['historyService', function(historyService) {
      return {
        restrict: 'E',
        replace: true,
        templateUrl: '/angular/components/historyControl/historyControl.tmpl',
        controllerAs: 'ctrl',
        scope: {
          hcPregId: '@',
          hcFollow: '@'
        },
        controller: function() {},
        link: function($scope, element, attrs, ctrl) {
          var hsCallback;
          var pregId;

          // --------------------------------------------------------
          // Top-level scope initialization.
          // --------------------------------------------------------
          $scope.ctrl.currentRecord = 0;
          $scope.ctrl.numberRecords = 0;
          $scope.ctrl.pregnancyId = 0;
          $scope.ctrl.updatedBy = '';
          $scope.ctrl.follow = !! attrs.hcFollow;

          // --------------------------------------------------------
          // Handle the checkbox to follow changes or not.
          // --------------------------------------------------------
          $scope.followChange = function() {
            // Is this necessary?
          };

          // --------------------------------------------------------
          // Register the historyService callback.
          // --------------------------------------------------------
          hsCallback = historyService.register(function(data) {
            var updatedBy;
            var changedTbl;
            var supervisor;

            // --------------------------------------------------------
            // Make sure updateMeta() is called the first time. Thereafter
            // the navigation controls call it.
            // --------------------------------------------------------
            if ($scope.ctrl.currentRecord === 0) updateMeta(historyService.info());

            // --------------------------------------------------------
            // Force the digest cycle when we know that it is needed.
            // --------------------------------------------------------
            $scope.ctrl.replacedAt = data.replacedAt;
            $scope.$applyAsync('ctrl.replacedAt');

            // --------------------------------------------------------
            // Display who changed the record. We take the first changed
            // table assuming that at any point in time the database
            // save was by the same user even if multiple tables
            // were involved.
            // --------------------------------------------------------
            changedTbl = _.keys(data.changed)[0];
            $scope.ctrl.updatedBy = historyService.lookup('user', 'id', data[changedTbl].updatedBy).username;
            if (data[changedTbl].supervisor) {
              supervisor = historyService.lookup('user', 'id', data[changedTbl].supervisor);
              $scope.ctrl.supervisor = supervisor.username;
            } else {
              $scope.ctrl.supervisor = '';
            }

            // --------------------------------------------------------
            // Force a UI-Router state change as needed so that the
            // changes can be seen on the proper page.
            // --------------------------------------------------------




          });

          /* --------------------------------------------------------
           * resetMeta()
           *
           * Reset the meta information such as when loading completely
           * new data, etc.
           * -------------------------------------------------------- */
          var resetMeta = function() {
            $scope.ctrl.currentRecord = 0;
            $scope.ctrl.numberRecords = 0;
            $scope.ctrl.pregnancyId = 0;
          };

          /* --------------------------------------------------------
           * updateMeta()
           *
           * Update the meta information about the current record such
           * as the record number and number of records, etc.
           *
           * param       info - object returned from some historyService calls
           * return      
           * -------------------------------------------------------- */
          var updateMeta = function(info) {
            $scope.ctrl.currentRecord = info.currentRecord;
            $scope.ctrl.numberRecords = info.numberRecords;
            $scope.ctrl.pregnancyId = info.pregnancyId;
          };

          // --------------------------------------------------------
          // Handle record navigation. There are four navagation types
          // with corresponding directive elements and historyService
          // functions for each of them. Each of the historyService
          // calls return the current record information which we use
          // to update the current meta information.
          // --------------------------------------------------------
          var firstLink = element.find('#historyControl-first');
          var prevLink = element.find('#historyControl-prev');
          var nextLink = element.find('#historyControl-next');
          var lastLink = element.find('#historyControl-last');
          var firstHandle = firstLink.on('click', function(evt) {
            updateMeta(historyService.first());
          });
          var prevHandle = prevLink.on('click', function(evt) {
            updateMeta(historyService.prev());
          });
          var nextHandle = nextLink.on('click', function(evt) {
            updateMeta(historyService.next());
          });
          var lastHandle = lastLink.on('click', function(evt) {
            updateMeta(historyService.last());
          });

          // --------------------------------------------------------
          // Clean up.
          // --------------------------------------------------------
          $scope.$on('$destroy', function() {
            var handles = [getHistoryHandle, prevHandle, nextHandle];
            handles.forEach(function(h) {
              angular.element(window).off('click', h);
            });

            // The History Service callback.
            if (historyService.unregister(hsCallback)) {
              console.log('Successfully unregistered history service callback.');
            } else {
              console.log('Did not successfully unregister history service callback.');
            }
          });

          // --------------------------------------------------------
          // Load the pregnancy automatically if the pregnancy id is
          // passed into the template. If the pregnancy id is not
          // passed in, the control will still work as expected
          // assuming that another entity has run historyService.load().
          // --------------------------------------------------------
          if ($scope.hcPregId) {
            pregId = parseInt($scope.hcPregId, 10);
            if (_.isNumber(pregId)) {
              resetMeta();
              historyService.load(pregId);
            }
          }

        }
      };
    }]);

})(angular);
