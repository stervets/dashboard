module.exports =
    restrict: Triangle.DIRECTIVE_TYPE.ATTRIBUTE
    inject: [FACTORY.DASHBOARD]
    local:
        scope:
            dashboard: FACTORY.DASHBOARD

        $window: null
        $table: null

        setCellsize: ->
            @dashboard.cellWidth = @$table.width()/@dashboard.tableWidth
            @dashboard.cellInnerWidth = @dashboard.cellWidth - @dashboard.cellSpace
            @$scope.$apply() unless @$scope.$$phase

    link: ->
        @$window = $ window
        @$table = @$element.find '.jsDashboardTableBody'

        @$window.resize _.throttle(@setCellsize, 500, true)

        @setCellsize()
