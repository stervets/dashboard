routes =
  '/login':
    templateUrl: 'book.html'

  default:
    template: ''
    controller: CONTROLLER.DEFAULT_PAGE
    

disableHtml5Mode = ['$locationProvider', (locationProvider)->
  locationProvider.html5Mode
    enabled: false
]

module.exports =
  routes: routes
  disableHtml5Mode: disableHtml5Mode
