;(function(angular) {

  'use strict';

  // --------------------------------------------------------
  // UI-Router
  // --------------------------------------------------------
  angular.module('midwifeEmr')
    .config([
        '$urlRouterProvider',
        '$locationProvider',
        '$futureStateProvider',
        function($urlRouterProvider, $locationProvider, $futureStateProvider) {

      // --------------------------------------------------------
      // Serves to convey the current UI-Router state to commonController().
      // Used for registering/unregistering with various services.
      // --------------------------------------------------------
      var prenatalState          = 'pregnancy.prenatal';
      var prenatalState          = 'pregnancy.prenatal';
      var prenatalExamState      = 'pregnancy.prenatalExam';
      var labsState              = 'pregnancy.labs';
      var questionnaireState     = 'pregnancy.questionnaire';
      var midwifeState           = 'pregnancy.midwife';
      var generalState           = 'pregnancy.general';

      $urlRouterProvider.otherwise('/');

      // ========================================================
      // ========================================================
      // State definition for UI Router Future States which allows
      // the final state definition to be deferred until runtime
      // when the templateService is available.
      // ========================================================
      // ========================================================
      var fsPregnancy = {
        type: 'templateService',
        stateName: 'pregnancy',
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
      };

      var fsPregnancyPrenatal = {
        type: 'templateService',
        stateName: 'pregnancy.prenatal',
        parent: 'pregnancy',
        url: '/prenatal',
        views: {
          'title@': {
            template: '<h1>{{title}}</h1>',
            controller: function($scope) {
              $scope.title = 'Prenatal';
            }
          },
          'content@': {
            templateUrl: '/angular/views/prenatal.RES.html',
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(prenatalState)],
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(prenatalState));
          pubSub.publish(getExitState(prenatalState));
        }]
      };

      var fsPregnancyPrenatalExam = {
        type: 'templateService',
        stateName: 'pregnancy.prenatalExam',
        parent: 'pregnancy',
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
            templateUrl: '/angular/views/prenatalExam.RES.html',
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId', 'peId',
                commonController(prenatalExamState)],
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(prenatalExamState));
          pubSub.publish(getExitState(prenatalExamState));
        }]
      };

      var fsPregnancyLabs = {
        type: 'templateService',
        stateName: 'pregnancy.labs',
        parent: 'pregnancy',
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
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(labsState)],
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(labsState));
          pubSub.publish(getExitState(labsState));
        }]
      };

      var fsPregnancyQuestionnaire = {
        type: 'templateService',
        stateName: 'pregnancy.questionnaire',
        parent: 'pregnancy',
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
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(questionnaireState)]
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(questionnaireState));
          pubSub.publish(getExitState(questionnaireState));
        }]
      };

      var fsPregnancyMidwife = {
        type: 'templateService',
        stateName: 'pregnancy.midwife',
        parent: 'pregnancy',
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
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(midwifeState)]
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(midwifeState));
          pubSub.publish(getExitState(midwifeState));
        }]
      };

      var fsPregnancyGeneral = {
        type: 'templateService',
        stateName: 'pregnancy.general',
        parent: 'pregnancy',
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
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(generalState)]
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(generalState));
          pubSub.publish(getExitState(generalState));
        }]
      };

      // --------------------------------------------------------
      // Register the future states.
      // --------------------------------------------------------
      $futureStateProvider.futureState(fsPregnancy);
      $futureStateProvider.futureState(fsPregnancyPrenatal);
      $futureStateProvider.futureState(fsPregnancyPrenatalExam);
      $futureStateProvider.futureState(fsPregnancyLabs);
      $futureStateProvider.futureState(fsPregnancyQuestionnaire);
      $futureStateProvider.futureState(fsPregnancyMidwife);
      $futureStateProvider.futureState(fsPregnancyGeneral);

      // --------------------------------------------------------
      // The State Factory that finalizes the UI Router states
      // at runtime when the templateService is available. Assumes
      // that the views['content@'].templateUrl needs to be
      // replaced at runtime.
      // --------------------------------------------------------
      $futureStateProvider.stateFactory('templateService',
          function($q, templateService, futureState) {
        var d = $q.defer();
        var template;
        var newTemplate;
        if (futureState.views &&
            futureState.views['content@'] &&
            futureState.views['content@'].templateUrl) {
          template = futureState.views['content@'].templateUrl;
          newTemplate = templateService.getTemplateUrl(template);
          futureState.views['content@'].templateUrl = newTemplate;
        }
        d.resolve(futureState);
        return d.promise;
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
   * getExitState()
   *
   * Returns the state name passed with "exit." prepended.
   *
   * param      state
   * return     exit state
   * -------------------------------------------------------- */
  var getExitState = function(state) {return "exit." + state;}

  /* --------------------------------------------------------
    * commonController()
    *
    * Returns a controller that is most likly useful for most
    * states. Expects a String that will serve as a key to
    * store the historyService registry id so that it can be
    * retrieved later from the stateHandles object when it is
    * time to unregister.
    *
    * The stateHandle parameter also serves to inform the
    * controller it's current state.
    *
    * The detId parameter, if passed, is defined per the context
    * or state and might be prenatalExamId in one context or
    * medicationId in another. When passed into the controller,
    * this was initated by a user clicking on a summary row on
    * another page.
    *
    * When arriving on a detail page while navigating via changes
    * per the historyControl, the detId will not be set, though
    * it will need to be. The stateHandle parameter is used to
    * determine what detId should be set to.
    *
    * param       stateHandle
    * param       detId
    * return      undefined
    * -------------------------------------------------------- */
  var commonController = function(stateHandle) {
    return function($scope, $state, historyService, templateService,
        pregId, detId) {
      var currViewport = templateService.getViewportSize();
      historyService.loadAsNeeded(pregId);
      historyService.registerPubSub(getExitState(stateHandle), function(data) {
        $scope.ctrl = data;
        $scope.func = commonFuncs;

        // --------------------------------------------------------
        // Make the UI-Router state available in $scope. The
        // historyControl component, for one, uses this in conjunction
        // with the historyService for record navigation. But since
        // this code is called toward the end of the page load, the
        // historyControl really uses this on the "next" use, not
        // the current page load.
        // --------------------------------------------------------
        if ($scope && $scope.$root) $scope.$root.hsState = stateHandle;

        // --------------------------------------------------------
        // If we are in a detail state and we are arriving to it
        // without the detId being set, set it based upon the
        // sources that have changed. If we are no longer in a
        // detail state, clear it.
        // --------------------------------------------------------
        if (! detId) {
          switch (stateHandle) {
            case 'pregnancy.prenatalExam':
              if (_.size($scope.ctrl.changed.prenatalExam) > 0) {
                $scope.detId = _.keys($scope.ctrl.changed.prenatalExam)[0];
                if ($scope && $scope.$root) $scope.$root.detId = $scope.detId;
              }
              break;
            default:
              $scope.detId = void 0;
              if ($scope && $scope.$root) $scope.$root.detId = void 0;
          }
        }
      });

      historyService.curr();
      $scope.pregId = pregId;
      if (detId) {
        $scope.detId = detId;
        $scope.$root.detId = $scope.detId;
      } else {
        $scope.detId = void 0;
        $scope.$root.detId = void 0;
      }

      // --------------------------------------------------------
      // Respond to resize events. If a template change is
      // required, reload page.
      // --------------------------------------------------------
      templateService.register(getExitState(stateHandle), function(viewPort) {
        if (templateService.needTemplateChange(currViewport)) {
          currViewport = templateService.getViewportSize();
          $state.go(stateHandle);
        }
      });
    };
  };


})(angular);
