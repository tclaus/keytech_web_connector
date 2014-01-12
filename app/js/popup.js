var elementInformation = angular.module('myModule', ['ui.bootstrap']);
// Popover function
var PopoverDemoCtrl = function ($scope) {
  $scope.dynamicPopover = "Hello, World!";
  $scope.dynamicPopoverTitle = "Title";
};

// Loading Element details information


elementInformation.controller('elementInformation', function($scope, $http) {

  $http.get('/elementdetails/' + $scope.param +'?format=json')
       .success(function(res){
          $scope.element = res;                
        });

});
