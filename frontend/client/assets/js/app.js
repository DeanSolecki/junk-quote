(function() {
  'use strict';

  angular.module('application', [
      'ui.router',
      'ngAnimate',

      //foundation
      'foundation',
      'foundation.dynamicRouting',
      'foundation.dynamicRouting.animations'
  ])
    .controller('HomeCtrl', ['$scope', 'API', function($scope, API) {
      API.getMeme().then(function(meme) {
        $scope.meme = meme;
      });

      $scope.next = function() {
        API.getMeme().then(function(meme) {
          $scope.meme = meme;
        });
      };
    }])

  .service('API', ['$http', function($http) {
    var route = '/api/';

    this.getMeme = function() {
      return $http.get(route + 'meme')
        .then(function(response) {
          return response.data;
        })
    };
  }])

  .config(config)
    .run(run)
    ;

  config.$inject = ['$urlRouterProvider', '$locationProvider'];

  function config($urlProvider, $locationProvider) {
    $urlProvider.otherwise('/');

    $locationProvider.html5Mode({
      enabled:false,
      requireBase: false
    });

    $locationProvider.hashPrefix('!');
  }

  function run() {
    FastClick.attach(document.body);
  }

})();
