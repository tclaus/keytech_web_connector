angular.module('keytech', [ ])
.controller('elementInformation', function($scope, $http, $attrs) {
  $http.get('/elementdata/' + $attrs.key )
       .then(function(res){
          $scope.element = res.data;                
        });
});