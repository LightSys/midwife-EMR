;(function(angular) {

  'use strict';

  angular.module('patientWellModule', [])
    .directive('patientWell', ['$compile', 'historyService', 'templateService',
        function($compile, historyService, templateService) {
      return {
        restrict: 'A',
        replace: false,
        controllerAs: 'ctrl',
        scope: {},
        controller: function() {},
        link: function($scope, element, attrs, ctrl) {
          var currViewport = templateService.getViewportSize();
          var hsCallback;

          /* --------------------------------------------------------
           * loadTemplate()
           *
           * Compile and install the template dynamically.
           *
           * param       templateName
           * return      undefined
           * -------------------------------------------------------- */
          var loadTemplate = function(templateName) {
            templateService.getTemplate(templateName)
              .then(function(tmpl) {
                console.log('patientWell: loading template.');
                element.html(tmpl).show();
                $compile(element.contents())($scope);
              });
          };

          // --------------------------------------------------------
          // Dynamically load the template according the size of the
          // viewport.
          //
          // Adapted from: http://onehungrymind.com/angularjs-dynamic-templates/
          // --------------------------------------------------------
          var templateName = '/angular/components/patientWell/patientWell.RES.tmpl';
          loadTemplate(templateName);

          // --------------------------------------------------------
          // Respond to resize events by loading the proper template
          // as necessary when viewport breakpoints are crossed.
          // --------------------------------------------------------
          templateService.register('patientWell', function(viewPort) {
            if (templateService.needTemplateChange(currViewport)) {
              currViewport = templateService.getViewportSize();
              loadTemplate(templateName);
            }
          });

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
