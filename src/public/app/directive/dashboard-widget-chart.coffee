module.exports =
  restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
  #inject: "#{FACTORY.DASHBOARD} as DashboardFactory, $document"
  templateUrl: "template-#{DIRECTIVE.WIDGET_CHART}"
  local:
    scope:
      widget: SCOPE
      
      
  link: ->
    #console.log @widget