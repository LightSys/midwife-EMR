;(function(angular) {

  'use strict';

  // --------------------------------------------------------
  // UI-Router
  // --------------------------------------------------------
  angular.module('midwifeEmr')
    .config(['$stateProvider', '$urlRouterProvider', '$locationProvider',
        function($stateProvider, $urlRouterProvider, $locationProvider) {

      // --------------------------------------------------------
      // historyService callbacks for cleanup when leaving states.
      // --------------------------------------------------------
      var hsPrenatalCB;
      var hsLabsCB;
      var hsQuestionnaireCB;
      var hsMidwifeCB;
      var hsGeneralCB;

      $urlRouterProvider.otherwise('/'); // TODO: this takes out of SPA, correct?

      $stateProvider
        // --------------------------------------------------------
        // Base state for all historical information on a pregnancy.
        // --------------------------------------------------------
        .state('pregnancy', {
          url: '/spa/history/pregnancy/:id',
          resolve: {
            pregId: ['$stateParams', function($stateParams) {
              return $stateParams.id;
            }]
          },
          views: {
            'tabs': {
              templateUrl: '/angular/views/pregnancy-tab.html'
            },
            'patientWell': {
              templateUrl: '/angular/views/history-header.html',
              controller: function($scope, $stateParams) {
                $scope.pregId = $stateParams.id;
              }
            },
            'content': {
              template: '<p>pregnancy state</p>'
            }
          }
        })
        // --------------------------------------------------------
        // Prenatal tab.
        // --------------------------------------------------------
        .state('pregnancy.prenatal', {
          url: '/prenatal',
          views: {
            'title@': {
              template: '<h1>{{title}}</h1>',
              controller: function($scope) {
                $scope.title = 'Prenatal';
              }
            },
            'content@': {
              templateUrl: '/angular/views/prenatal.html',
              controller: ['$scope', 'historyService', 'pregId', function($scope, historyService, pregId) {
                historyService.loadAsNeeded(pregId);
                hsPrenatalCB = historyService.register(function(data) {
                  $scope.ctrl = data;
                  $scope.func = {};
                  $scope.func.contains = _.contains;
                  console.dir($scope.ctrl);
                });
                historyService.curr();
                $scope.pregId = pregId;
              }],
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.prenatal, onExit');
            historyService.unregister(hsPrenatalCB);
          }]
        })
        // --------------------------------------------------------
        // Labs tab.
        // --------------------------------------------------------
        .state('pregnancy.labs', {
          url: '/labs',
          views: {
            'title@': {
              template: '<h1>{{title}}</h1>',
              controller: function($scope) {
                $scope.title = 'Labs';
              }
            },
            'content@': {
              template: '<p>This is the labs content for pregnancy id: {{pregId}}.</p>',
              controller: ['$scope', 'historyService', 'pregId', function($scope, historyService, pregId) {
                historyService.loadAsNeeded(pregId);
                hsLabsCB = historyService.register(function(data) {
                  $scope.ctrl = data;
                });
                historyService.curr();
                $scope.pregId = pregId;
              }]
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.labs, onExit');
            historyService.unregister(hsLabsCB);
          }]
        })
        // --------------------------------------------------------
        // Questionnaire tab.
        // --------------------------------------------------------
        .state('pregnancy.questionnaire', {
          url: '/quesEdit',
          views: {
            'title@': {
              template: '<h1>{{title}}</h1>',
              controller: function($scope) {
                $scope.title = 'Pregnancy Questionnaire';
              }
            },
            'content@': {
              template: '<p>This is the questionnaire content for pregnancy id: {{pregId}}.</p>',
              controller: ['$scope', 'historyService', 'pregId', function($scope, historyService, pregId) {
                historyService.loadAsNeeded(pregId);
                hsQuestionnaireCB = historyService.register(function(data) {
                  $scope.ctrl = data;
                });
                historyService.curr();
                $scope.pregId = pregId;
              }]
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.questionnaire, onExit');
            historyService.unregister(hsQuestionnaireCB);
          }]
        })
        // --------------------------------------------------------
        // Midwife tab.
        // --------------------------------------------------------
        .state('pregnancy.midwife', {
          url: '/midwifeinterview',
          views: {
            'title@': {
              template: '<h1>{{title}}</h1>',
              controller: function($scope) {
                $scope.title = 'Midwife Interview';
              }
            },
            'content@': {
              template: '<p>This is the midwife content for pregnancy id: {{pregId}}.</p>',
              controller: ['$scope', 'historyService', 'pregId', function($scope, historyService, pregId) {
                historyService.loadAsNeeded(pregId);
                hsMidwifeCB = historyService.register(function(data) {
                  $scope.ctrl = data;
                });
                historyService.curr();
                $scope.pregId = pregId;
              }]
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.midwife, onExit');
            historyService.unregister(hsMidwifeCB);
          }]
        })
        // --------------------------------------------------------
        // General tab.
        // --------------------------------------------------------
        .state('pregnancy.general', {
          url: '/edit',
          views: {
            'title@': {
              template: '<h1>{{title}}</h1>',
              controller: function($scope) {
                $scope.title = 'Edit Client';
              }
            },
            'content@': {
              template: '<p>This is the general content for pregnancy id: {{pregId}}.</p>',
              controller: ['$scope', 'historyService', 'pregId', function($scope, historyService, pregId) {
                historyService.loadAsNeeded(pregId);
                hsGeneralCB = historyService.register(function(data) {
                  $scope.ctrl = data;
                });
                historyService.curr();
                $scope.pregId = pregId;
              }]
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.general, onExit');
            historyService.unregister(hsGeneralCB);
          }]
        });

      $locationProvider.html5Mode(true);

    }]);

})(angular);
