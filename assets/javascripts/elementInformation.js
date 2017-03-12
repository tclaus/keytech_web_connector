var elementInformation = angular.module('keytech', [ ]);

elementInformation.controller('elementInformation', function($scope, $http) {
  $http.get('/element/' + $elementKey +'?=format=json')
       .then(function(res){
          $scope.attributs = res.data;                
        });
});