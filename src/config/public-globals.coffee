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
FIREBASE_ADDR: "https://deeprest-dashboard.firebaseio.com"

# websocket data-server address
SOCKET_ADDR: "http://dashboard-data.deeprest.ru"

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
SCOPE: "Scope"

###
   Dashboard settings
###
DASHBOARD:
  TABLE_WIDTH: 8 # table horizontal cells count

  CELL:
    HEIGHT: 90 #cell height (px)
    SPACE: 10 #space between cells

WIDGET:
  MIN_WIDTH: 2
  MIN_HEIGHT: 2
  TYPE:
    CHART: 'chart'
    VALUE: 'value'
    CHAT: 'chat'
    ABOUT: 'about'

###
    Socket commands
###
SOCKET:
  SUBSCRIBE: 'subscribe'
  UNSUBSCRIBE: 'unsubscribe'
  DATA: 'data'

###
    Dta channels
###
CHANNEL:
  EURUSD: 'EURUSD'
  EURJPY: 'EURJPY'
  USDJPY: 'USDJPY'
  USDCAD: 'USDCAD'
  AUDUSD: 'AUDUSD'
  GBPUSD: 'GBPUSD'

###
   Chart options
###
DATA_CACHE: 100 #records amount stored in cache
CHART_TYPES: ['area', 'areaspline', 'line', 'bar', 'spline']

###
  Angular bundle generator section
###
FACTORY:
  FIREBASE: 'FirebaseFactory'
  USER: 'UserFactory'
  DASHBOARD: 'DashboardFactory'
  DATA_MANAGER: 'DataManagerFactory'

CONTROLLER:
  # /app/controller/default-page.coffee file will be required
  DASHBOARD_PAGE: 'DashboardPageController'
  LOGIN_PAGE: 'LoginPageController'

DIRECTIVE:
  TABLE: 'dashboardTable'
  WIDGET: 'dashboardWidget'
  WIDGET_CHART: 'dashboardWidgetChart'
  WIDGET_VALUE: 'dashboardWidgetValue'
  WIDGET_CHAT: 'dashboardWidgetChat'
  WIDGET_ABOUT: 'dashboardWidgetAbout'


