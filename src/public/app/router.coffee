checkAuth =
  checkUserAuth: ['$location', FACTORY.USER, '$rootScope', ($location, $user, $rootScope)->
    $rootScope.user = $user.user
    $rootScope.$watch 'user.authenticated', (authenticated)->
      $location.url '/login' unless authenticated
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
