;(function(angular) {

  'use strict';

  // ========================================================
  // ========================================================
  // A word about templates and viewport sizes.
  //
  // The application uses a combination of adaptive web design
  // (AWD) and responsive web design (RWD) in order to
  // appropriately handle the variety of viewport sizes of the
  // clients. Both AWD and RWD are used for the more complicated
  // portions of the application, for example, the 'content@'
  // views below in the Future States definitions as well as
  // some of the components. This allows these more complicated
  // layouts to be addressed at the course level by AWD, ie,
  // currently one of three breakpoints at 480, 600, and 992.
  // Then the more granular level, RWD provides the "in-between"
  // viewport sizes.
  //
  // Less complicated views and components will likely only
  // use RWD seeing that their needs can adequately be addressed
  // by a smattering of media queries and/or Bootstrap visibility
  // classes.
  //
  // templateService provides the application an interface
  // both to resize events as well as a means to swap templates
  // into $templateCache behind the scenes to allow on the fly
  // transistions to different templates entirely (AWD) when
  // breakpoints are crossed. Components and various UI Router
  // states can register with templateService in order to
  // properly respond to these resize events.
  // ========================================================
  // ========================================================

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
      var prenatalExamState      = 'pregnancy.prenatalExam';
      var labsState              = 'pregnancy.labs';
      var questionnaireState     = 'pregnancy.questionnaire';
      var midwifeState           = 'pregnancy.midwife';
      var pregHistoryState       = 'pregnancy.pregnancyHistory';
      var generalState           = 'pregnancy.general';

      $urlRouterProvider.otherwise('/');

      // ========================================================
      // ========================================================
      // State definition for UI Router Future States which allows
      // the final state definition to be deferred until runtime
      // when the templateService is available.
      //
      // UI-Router-Extras Future States allow us to defer the
      // specification of the templateUrl for the context@ view
      // until runtime. At that point, templateService.loadTemplateToCache()
      // is called that swaps the proper template into the
      // $templateCache key/value store identified by the
      // templateUrls below that have RES in the name.
      // loadTemplateToCache() retrieves the actual template to
      // use based upon the current viewport.
      //
      // Note that this only works for the initial load. After
      // that the various components, ie, historyControl and
      // patientWell, and the Future State views here that need
      // to swap templates after initialization due to user resize
      // events, will rely upon templateService to swap templates
      // in the background in order to properly handle these events
      // with the correct template for the viewport size.
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
            template: '<p>Loading ...</p>'
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
          pubSub.publish(retireExitState(prenatalState));
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
            template: '<h2>{{title}}</h2>',
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
          pubSub.publish(retireExitState(prenatalExamState));
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
            templateUrl: '/angular/views/prenatalLabs.RES.html',
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(labsState)],
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(labsState));
          pubSub.publish(retireExitState(labsState));
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
            templateUrl: '/angular/views/prenatalQuestionnaire.RES.html',
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(questionnaireState)]
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(questionnaireState));
          pubSub.publish(retireExitState(questionnaireState));
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
              $scope.title = 'Midwife';
            }
          },
          'content@': {
            templateUrl: '/angular/views/prenatalMidwifeInterview.RES.html',
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(midwifeState)]
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(midwifeState));
          pubSub.publish(retireExitState(midwifeState));
        }]
      };

      var fsPregnancyHistory = {
        type: 'templateService',
        stateName: 'pregnancy.pregnancyHistory',
        parent: 'pregnancy',
        url: '/preghistory/:phid',
        resolve: {
          phId: ['$stateParams', function($stateParams) {
            return $stateParams.phid;
          }]
        },
        views: {
          'tabs@': {
            template: '<span></span>'    // We don't want tabs to show.
          },
          'title@': {
            template: '<h2>{{title}}</h2>',
            controller: function($scope) {
              $scope.title = 'Hist Pregnancy';
            }
          },
          'content@': {
            templateUrl: '/angular/views/prenatalPregnancyHistory.RES.html',
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId', 'phId',
                commonController(pregHistoryState)],
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(pregHistoryState));
          pubSub.publish(retireExitState(pregHistoryState));
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
            templateUrl: '/angular/views/prenatalGeneral.RES.html',
            controller: ['$scope', '$state', 'historyService', 'templateService', 'pregId',
                commonController(generalState)]
          }
        },
        onExit: ['historyService', 'minPubSubNg', function(historyService, pubSub) {
          // --------------------------------------------------------
          // Clean up the registrations for this state.
          // --------------------------------------------------------
          console.log('Publishing: ' + getExitState(generalState));
          pubSub.publish(retireExitState(generalState));
        }]
      };

      // --------------------------------------------------------
      // Register the future states.
      // --------------------------------------------------------
      var allStates = [fsPregnancy, fsPregnancyPrenatal, fsPregnancyPrenatalExam,
          fsPregnancyLabs, fsPregnancyQuestionnaire, fsPregnancyMidwife,
          fsPregnancyHistory, fsPregnancyGeneral];
      _.each(allStates, function(state) {
        $futureStateProvider.futureState(state);
      });

      // --------------------------------------------------------
      // Create a collection of generic templateUrls so that the
      // first state to be initialized by stateFactory below
      // can register them all in templateService. This will allow
      // templateService to reload all of the templateUrls
      // upon resize events that cross breakpoint boundaries.
      // --------------------------------------------------------
      var genericTemplatesRegistered = false;
      var genericTemplates = [];
      _.each(allStates, function(state) {
        if (state.views && state.views['content@'] && state.views['content@'].templateUrl) {
          genericTemplates.push({stateName: state.name, templateUrl: state.views['content@'].templateUrl});
        }
      });

      // --------------------------------------------------------
      // The State Factory that finalizes the UI Router states
      // at runtime when the templateService is available. Assumes
      // that when templateUrl elements have 'RES' in the value,
      // that they need to be replaced at runtime.
      //
      // Note that this only runs once when the state is initialized
      // or finalized or whatever you want to call it. After that,
      // resize events in coordination with the templateService
      // is used to swap in the proper template whenever viewport
      // breakpoints are crossed.
      // --------------------------------------------------------
      $futureStateProvider.stateFactory('templateService',
          function($q, templateService, futureState) {
        var d = $q.defer();

        // --------------------------------------------------------
        // For this state, load the appropriate template to
        // $templateCache.
        // --------------------------------------------------------
        _.each(futureState.views, function(obj, name) {
          if (_.has(obj, 'templateUrl')) {
            templateService.loadTemplateToCache(obj.templateUrl);
          }
        });

        // --------------------------------------------------------
        // The first state intialized will also register all of the
        // generic templateUrls found in the states above. This will
        // enable the templateService to reload all of these templates
        // whenever resize events cross established breakpoints.
        // --------------------------------------------------------
        if (! genericTemplatesRegistered) {
          _.each(genericTemplates, function(st) {
            templateService.registerGenericTemplateUrl(st.templateUrl);
          });
          genericTemplatesRegistered = true;
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
   * retireExitState()
   *
   * Allows use of a unique identifier tied to a particular
   * state as defined by the caller until the unique identifier
   * is no longer needed.
   *
   * getExitState() returns a unique identifier for the state
   * passed, generating one if one does not already exist, and
   * returning the same one if one already exists.
   *
   * retireExitState() returns the already existing unique
   * identifer corresponding to the state passed and then
   * deletes the unique identifier. If the state does not exist,
   * it returns undefined and issues a warning to the console.
   *
   * param      state
   * return     exit state
   * -------------------------------------------------------- */
  var exitStates = {};
  var getExitState = function(state) {
    if (exitStates.state) {
      return exitStates.state;
    } else {
      exitStates.state = 'exit.' + state + '.' + (Math.random() * 99999999);
      return exitStates.state;
    }
  };
  var retireExitState = function(state) {
    var tmpState;
    if (exitStates.state) {
      tmpState = exitStates.state;
      delete exitStates.state;
      return tmpState;
    } else {
      console.log('WARNING: retireExitState() did not find ' + state + '.');
    }
  };

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

        // TESTING
        console.log(stateHandle);
        console.dir($scope.ctrl);

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
            // Add states here for detail pages as necessary.
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
      // required because a breakpoint has been called, the
      // $templateCache will already have been primed with the
      // proper template by the time this callback is called.
      // Therefore, the state just needs to be reloaded in order
      // to utilize the new template for the new size.
      //
      // NOTE: currently this is for the content@ view in whatever
      // state which is the complicated view across the states. For
      // simpler views, we don't use an adaptive web design approach
      // but instead rely completely on responsive web design using
      // media queries and/or Bootstrap visibility classes, etc.
      // --------------------------------------------------------
      var stateObj = $state.get(stateHandle);
      templateService.register(getExitState(stateHandle), function(viewPort) {
        if (templateService.needTemplateChange(currViewport)) {
          currViewport = templateService.getViewportSize();
          $state.reload(stateHandle);
        }
      });
    };
  };

})(angular);
