(function() {
  var posts = [];

  var app = angular.module('ihatejsf', ['ihatejsf-directives', 'ihatejsf-filters', 'ui.bootstrap']);

  app.controller('PostsController', function(PostsService) {
    var controller = this;
    this.posts = [];
    PostsService.getAllPosts().success(function(data) {
      controller.posts = data;
      posts = data;
    });
  });

  app.controller('ComplaintController', function(PostsService, $modal, $scope) {
    $scope.open = function() {
      var modalInstance = $modal.open({
        templateUrl: 'add-complaint.html',
        controller: function($scope, $modalInstance, $log) {
          $scope.data = { author: "Anonymous", text: "" };

          $scope.ok = function() {
            $modalInstance.close({ data: $scope, author: $scope.data.author, text: $scope.data.text });
          };

          $scope.cancel = function() {
            $modalInstance.dismiss('cancel');
          };
        }
      });

      modalInstance.result.then(function(complaint) {
        PostsService.addPost(complaint);
      });
    };
  });

  app.service('PostsService', function($http) {
    this.getAllPosts = function() {
      return $http.get("/api/posts");
    };
    this.addPost = function(post) {
      post.created = new Date();
      posts.unshift(post);
      console.log(post);
      $http.post("/complain2", { nick: post.author, text: post.text }).success(function(response) { console.log(response); });
    };
  });
})();

(function() {
  var app = angular.module('ihatejsf-directives', []);
  app.directive('post', function() {
    return {
      restrict: 'E',
      scope: {
        post: '='
      },
      templateUrl: '_post.html',
      controller: function($scope, $sce) {
        var facebookLikeLink = "http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fihatejsf.com%2Fpost/" + $scope.post._id + "&amp;send=true&amp;layout=button_count&amp;width=250&amp;show_faces=true&amp;action=like&amp;colorscheme=light&amp;font&amp;height=21";
        $scope.post.facebookLikeLink = $sce.trustAsResourceUrl(facebookLikeLink);
      }
    };
  });
})();

(function() {
  var app = angular.module('ihatejsf-filters', []);
  app.filter('since', function() {
    return function(date) {
      return moment(date).fromNow();
    }
  });
})();
