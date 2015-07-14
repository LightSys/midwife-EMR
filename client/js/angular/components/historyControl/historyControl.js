;(function(angular) {

  'use strict';

  angular.module('historyControlModule', [])
    .directive('historyControl', [
        '$state',
        'historyService',
        'changeRoutingService',
        function($state, historyService, changeRoutingService) {

      /* --------------------------------------------------------
       * navigate()
       *
       * Handles the change of record when the user selects one
       * of the navigation controls. If the changed fields are
       * not shown on the current state (as determined by the
       * changeRoutingService), and if the follow changes flag
       * is set, then change state to potentially show the
       * change without changing records. This allows the user
       * to navigate once to change to the right screen and again
       * to actually see the change.
       *
       * Also, when a record is change, calls updateMeta() to keep
       * the meta data about the current record in tact.
       *
       * param       $scope
       * param       recNum - 1 based
       * param       navFunc - the historyService navigation function.
       * return      
       * -------------------------------------------------------- */
      var navigate = function($scope, recNum, navFunc) {
        var changed;
        var newState;
        var source;

        // Sanity check.
        if (recNum < 1 || recNum > $scope.ctrl.numberRecords) {
          console.log('Invalid record number: ' + recNum + '. Aborting navigation.');
          return;
        }

        if ($scope.ctrl.follow) {
          changed = historyService.getChangedByNum(recNum);
          newState = changeRoutingService.getState(changed);

          console.log(newState);

          if (newState !== $state.$current.name) {
            $state.go(newState);
          } else {
            updateMeta($scope, navFunc());
          }
        } else {
          source = changeRoutingService.getSource('pregnancy.prenatalExam');
          console.dir(source);
          updateMeta($scope, navFunc());
        }
      };

      /* --------------------------------------------------------
        * updateMeta()
        *
        * Update the meta information about the current record such
        * as the record number and number of records, etc.
        *
        * param       $scope
        * param       info - object returned from some historyService calls
        * return      
        * -------------------------------------------------------- */
      var updateMeta = function($scope, info) {
        $scope.ctrl.currentRecord = info.currentRecord;
        $scope.ctrl.numberRecords = info.numberRecords;
        $scope.ctrl.pregnancyId = info.pregnancyId;
      };

      /* --------------------------------------------------------
        * resetMeta()
        *
        * Reset the meta information such as when loading completely
        * new data, etc.
        *
        * param     $scope
        * -------------------------------------------------------- */
      var resetMeta = function($scope) {
        $scope.ctrl.currentRecord = 0;
        $scope.ctrl.numberRecords = 0;
        $scope.ctrl.pregnancyId = 0;
      };

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
          $scope.ctrl.follow = attrs.hcFollow && attrs.hcFollow === 'true'? true: false;

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
            if ($scope.ctrl.currentRecord === 0) updateMeta($scope, historyService.info());

            // --------------------------------------------------------
            // Force the digest cycle when we know that it is needed.
            // --------------------------------------------------------
            $scope.ctrl.replacedAt = data.replacedAt;
            $scope.$applyAsync('ctrl.replacedAt');

            // --------------------------------------------------------
            // Display who changed the record for this change.
            // --------------------------------------------------------
            $scope.ctrl.updatedBy = void 0;
            $scope.ctrl.supervisor = void 0;
            if (data.changedBy.updatedBy) {
              $scope.ctrl.updatedBy = historyService.lookup('user', 'id', data.changedBy.updatedBy).username;
            }
            if (data.changedBy.supervisor) {
              $scope.ctrl.supervisor = historyService.lookup('user', 'id', data.changedBy.supervisor).username;
            }
          });

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
            navigate($scope, 1, historyService.first);
          });
          var prevHandle = prevLink.on('click', function(evt) {
            if ($scope.ctrl.currentRecord !== 1) {
              navigate($scope, $scope.ctrl.currentRecord - 1, historyService.prev);
            }
          });
          var nextHandle = nextLink.on('click', function(evt) {
            if ($scope.ctrl.currentRecord !== $scope.ctrl.numberRecords) {
              navigate($scope, $scope.ctrl.currentRecord + 1, historyService.next);
            }
          });
          var lastHandle = lastLink.on('click', function(evt) {
            navigate($scope, $scope.ctrl.numberRecords, historyService.last);
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
              resetMeta($scope);
              historyService.load(pregId);
            }
          }

        }
      };
    }]);

})(angular);
