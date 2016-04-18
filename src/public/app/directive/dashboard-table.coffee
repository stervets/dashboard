module.exports =
  restrict: Triangle.DIRECTIVE_TYPE.ATTRIBUTE
  inject: ["#{FACTORY.DASHBOARD} as DashboardFactory", FACTORY.FIREBASE]
  local:
    scope:
      dashboard: FACTORY.DASHBOARD
      loaded: FACTORY.FIREBASE

    $window: null
    $table: null

    setCellsize: ->
      tablePosition = @$table.position()
      angular.extend @dashboard.clientArea,
        left: @dashboard.cellSpace-tablePosition.left
        top: @dashboard.cellSpace-tablePosition.top
        width: @$scroller.width()-@dashboard.cellSpace*2
        height: @$scroller.height()-@dashboard.cellSpace*2
      @DashboardFactory.setCellsize @$table.width()
      @$scope.$apply() unless @$scope.$$phase

    onLoadedWidgets: (loaded)->
      setTimeout(@setCellsize, 0) if loaded

    onDashboardScrollToChange: ->
        return unless @dashboard.scrollTo
        if widget = @DashboardFactory.getWidget @dashboard.scrollTo
          @$scroller.animate scrollTop: @DashboardFactory.getRealXY(0, widget.y).y , 'slow'
      
    watch:
      'loaded.widgets': 'onLoadedWidgets'
      'dashboard.scrollTo': 'onDashboardScrollToChange'

  link: ->
    @$window = $ window
    @$table = @$element.find '.jsDashboardTableBody'
    @$scroller = $ '.jsScroller'
    @$window.resize _.throttle(@setCellsize, 500, true)
