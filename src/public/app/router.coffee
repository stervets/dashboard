checkAuth = ['$location', FACTORY.USER, '$rootScope', ($location, UserFactory, $rootScope)->
  $rootScope.userStatus = UserFactory.userStatus
  $rootScope.$watch 'userStatus.gotAuthStatus', (gotAuth)->
    if gotAuth and !UserFactory.userStatus.auth
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
