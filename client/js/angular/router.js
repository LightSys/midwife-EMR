;(function(angular) {

  'use strict';

  // --------------------------------------------------------
  // UI-Router
  // --------------------------------------------------------
  angular.module('midwifeEmr')
    .config(['$stateProvider', '$urlRouterProvider', '$locationProvider',
        function($stateProvider, $urlRouterProvider, $locationProvider) {

      // --------------------------------------------------------
      // Keys for historyService callbacks to facilitate cleanup
      // when leaving states. Used by commonController() and
      // addStateHandle().
      //
      // Note: there is no significance to the values being the
      // same as the UI-Router states, just convention.
      // --------------------------------------------------------
      var hsPrenatalCB          = 'pregnancy.prenatal';
      var hsPrenatalExamCB      = 'pregnancy.prenatalExam';
      var hsLabsCB              = 'pregnancy.labs';
      var hsQuestionnaireCB     = 'pregnancy.questionnaire';
      var hsMidwifeCB           = 'pregnancy.midwife';
      var hsGeneralCB           = 'pregnancy.general';

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
            'historyControl': {
              template: "<history-control id='historyControl' hc-follow='true'></history-control>"
            },
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
              controller: ['$scope', 'historyService', 'pregId',
                  commonController(hsPrenatalCB)],
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.prenatal, onExit');
            historyService.unregister(stateHandles[hsPrenatalCB]);
          }]
        })
        // --------------------------------------------------------
        // PrenatalExam.
        // --------------------------------------------------------
        .state('pregnancy.prenatalExam', {
          url: '/prenatalexam/:peid',
          resolve: {
            peId: ['$stateParams', function($stateParams) {
              return $stateParams.peid;
            }]
          },
          views: {
            'tabs@': {
              template: '<span></span>'    // We don't want tabs to show.
            },
            'title@': {
              template: '<h1>{{title}}</h1>',
              controller: function($scope) {
                $scope.title = 'Prenatal Exam';
              }
            },
            'content@': {
              templateUrl: '/angular/views/prenatalExam.html',
              controller: ['$scope', 'historyService', 'pregId', 'peId',
                  commonController(hsPrenatalExamCB)],
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.prenatalExam, onExit');
            historyService.unregister(stateHandles[hsPrenatalExamCB]);
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
              controller: ['$scope', 'historyService', 'pregId',
                  commonController(hsLabsCB)],
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.labs, onExit');
            historyService.unregister(stateHandles[hsLabsCB]);
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
                $scope.title = 'Questionnaire';
              }
            },
            'content@': {
              template: '<p>This is the questionnaire content for pregnancy id: {{pregId}}.</p>',
              controller: ['$scope', 'historyService', 'pregId',
                  commonController(hsQuestionnaireCB)]
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.questionnaire, onExit');
            historyService.unregister(stateHandles[hsQuestionnaireCB]);
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
              controller: ['$scope', 'historyService', 'pregId',
                  commonController(hsMidwifeCB)]
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.midwife, onExit');
            historyService.unregister(stateHandles[hsMidwifeCB]);
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
              controller: ['$scope', 'historyService', 'pregId',
                  commonController(hsGeneralCB)]
            }
          },
          onExit: ['historyService', function(historyService) {
            // --------------------------------------------------------
            // Clean up the callback for the history service.
            // --------------------------------------------------------
            console.log('State: pregnancy.general, onExit');
            historyService.unregister(stateHandles[hsGeneralCB]);
          }]
        });

      $locationProvider.html5Mode(true);

    }]);

  // --------------------------------------------------------
  // Define an object containing functions for use in the
  // views.
  // --------------------------------------------------------
  var commonFuncs = {
    contains: _.contains,
    log: function(msg) {console.log(msg);},
    gotoUrl: function(url) {
      // Testing
      console.log(url);
    },
    /* --------------------------------------------------------
     * hasChanged()
     *
     * Returns whether the field has changed on this change
     * record or not. Expects to be passed $scope.ctrl as the
     * first parameter, and well as table, pregId, and field.
     *
     * If ctrl.changed[table][pregId] does not exist, that is
     * not an error, it just means that it was not changed.
     *
     * param       ctrl
     * param       table
     * param       pregId
     * param       fld
     * return      boolean
     * -------------------------------------------------------- */
    hasChanged: function(ctrl, table, pregId, fld) {
      if (! ctrl || ! table || ! pregId || ! fld) return false;
      if (ctrl.changed && ctrl.changed[table] && ctrl.changed[table][pregId]) {
        return _.contains(ctrl.changed[table][pregId].fields, fld);
      }
      return false;
    }
  };

  /* --------------------------------------------------------
   * addStateHandle()
   *
   * Store a key/value in the stateHandles object. Meant as
   * a central place to store historyService registry ids so
   * that they are available for unregistry later in order to
   * prevent memory leaks.
   *
   * param       key
   * param       val
   * return      undefined
   * -------------------------------------------------------- */
  var addStateHandle = function(key, val) {
    stateHandles[key] = val;
  };
  var stateHandles = {};

  /* --------------------------------------------------------
    * commonController()
    *
    * Returns a controller that is most likly useful for most
    * states. Expects a String that will serve as a key to
    * store the historyService registry id so that it can be
    * retrieved later from the stateHandles object when it is
    * time to unregister.
    *
    * The detId parameter, if passed, is defined per the context
    * or state and might be prenatalExamId in one context or
    * medicationId in another.
    *
    * param       handle
    * param       detId
    * return      undefined
    * -------------------------------------------------------- */
  var commonController = function(handle) {
    return function($scope, historyService, pregId, detId) {
      var unregisterHdl;
      console.log(pregId + (detId? ' : ' + detId: ''));
      historyService.loadAsNeeded(pregId);
      unregisterHdl = historyService.register(function(data) {
        $scope.ctrl = data;
        $scope.func = commonFuncs;
        console.dir($scope.ctrl);
      });
      addStateHandle(handle, unregisterHdl);
      historyService.curr();
      $scope.pregId = pregId;
      if (detId) $scope.detId = detId;
    };
  };


})(angular);
