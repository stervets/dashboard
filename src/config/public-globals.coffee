APPLICATION:
  # ng-app name
  NAME: 'DashboardApplication'

  # browser tab title
  TITLE: 'Dashboard demo application'

  # angular application depends
  MODULES: [
    'ngRoute'
    'ngAnimate'
    'ngMaterial'
    'firebase'
  ]

# firebase db address
FIREBASE_ADDR: 'https://deeprest-dashboard.firebaseio.com'

# pages with no auth required
PUBLIC_PAGES: [
  '/login'
  '/about'
]

# material design theme
THEME:
  DARK: true
  PRIMARY_PALETTE: 'indigo'
  ACCENT_PALETTE: 'amber'

LOCAL_PROPERTY: "LocalProperty"
LOCAL_METHOD: "LocalMethod"

###
  Angular bundle generator section
###
FACTORY:
  FIREBASE: 'FirebaseFactory'
  USER: 'UserFactory'

CONTROLLER:
  # /app/controller/default-page.coffee file will be required
  DASHBOARD_PAGE: 'DashboardPageController'
  LOGIN_PAGE: 'LoginPageController'

DIRECTIVE: {}


