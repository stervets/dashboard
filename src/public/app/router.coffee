checkAuth =
  checkUserAuth: ['$location', FACTORY.USER, '$rootScope', ($location, $user, $rootScope)->
    $rootScope.user = $user.user

    $rootScope.$watch 'user.authenticated', (authenticated)->
      if authenticated
        unless $rootScope.user.name
          angular.extend $rootScope.user,
            name: "Anonymous"
            avatar: "/img/anonym.png"
      else
        $location.url '/login'
  ]

routes =
  '/login':
    templateUrl: '/view/login.html'
    controller: CONTROLLER.LOGIN_PAGE

  '/dashboard':
    templateUrl: '/view/dashboard.html'
    resolve: checkAuth
    controller: CONTROLLER.DASHBOARD_PAGE

  default:
    redirectTo: '/dashboard/'

disableHtml5Mode = ['$locationProvider', (locationProvider)->
  locationProvider.html5Mode
    enabled: false
]

module.exports =
  routes: routes
  disableHtml5Mode: disableHtml5Mode
