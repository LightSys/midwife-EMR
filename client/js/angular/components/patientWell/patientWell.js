;(function(angular) {

  'use strict';

  angular.module('patientWellModule', [])
    .directive('patientWell', ['historyService', function(historyService) {
      return {
        restrict: 'A',
        replace: false,
        templateUrl: '/angular/components/patientWell/patientWell.tmpl',
        controllerAs: 'ctrl',
        scope: {},
        controller: function() {},
        link: function($scope, element, attrs, ctrl) {
          var hsCallback;

          // --------------------------------------------------------
          // Register the historyService callback.
          // --------------------------------------------------------
          hsCallback = historyService.register(function(data) {
            $scope.ctrl = data;
          });

          // --------------------------------------------------------
          // Clean up.
          // --------------------------------------------------------
          $scope.$on('$destroy', function() {
            // The History Service callback.
            if (historyService.unregister(hsCallback)) {
              console.log('Successfully unregistered history service callback.');
            } else {
              console.log('Did not successfully unregister history service callback.');
            }
          });

        }
      };
    }]);
})(angular);
