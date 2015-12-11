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
		}])

		.service('API', ['$http', function($http) {
			var route = 'http://localhost:8079/api/';

			this.getMeme = function() {
				return $http.jsonp(route + 'meme')
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
