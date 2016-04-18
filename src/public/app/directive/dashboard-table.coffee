module.exports =
  restrict: Triangle.DIRECTIVE_TYPE.ATTRIBUTE
  inject: [FACTORY.DASHBOARD, FACTORY.FIREBASE]
  local:
    scope:
      dashboard: FACTORY.DASHBOARD
      loaded: FACTORY.FIREBASE

    $window: null
    $table: null

    setCellsize: ->
      @dashboard.cellWidth = @$table.width() / @dashboard.tableWidth
      @dashboard.cellInnerWidth = @dashboard.cellWidth - @dashboard.cellSpace
      @$scope.$apply() unless @$scope.$$phase

    onLoadedWidgets: (loaded)->
      setTimeout(@setCellsize, 0) if loaded
    watch:
      'loaded.widgets': 'onLoadedWidgets'


  link: ->
    @$window = $ window
    @$table = @$element.find '.jsDashboardTableBody'
    @$window.resize _.throttle(@setCellsize, 500, true)
