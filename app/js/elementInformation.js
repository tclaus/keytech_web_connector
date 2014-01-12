var elementInformation = angular.module('myModule', []);

elementInformation.controller('elementInformation', function($scope, $http) {
	alert("Hallo")
  $http.get('/element/' + $elementKey +'?=format=json')
       .then(function(res){
          $scope.attributs = res.data;                
        });
});