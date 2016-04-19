module.exports =
  restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
  inject: "#{FACTORY.DATA_MANAGER} as DataManager"
  templateUrl: "template-#{DIRECTIVE.WIDGET_CHART}"
  local:
    scope:
      widget: SCOPE
    highChartsOptions:{}
    $highChart: null
    highChart: null
    redraw: ->
      @highChart.reflow()

    initHighChart: ->
      options = @highChartsOptions
      @$highChart = @$element.find('.jsViewHighChart').highcharts options
      @highChart = @$highChart.highcharts()

  link: ->
    @initHighChart()
    @$scope.$on 'redraw', @redraw
    @DataManager.send()
    #setTimeout @redraw, 100
    #console.log @widget