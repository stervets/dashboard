module.exports =
    restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
    inject: ["#{FACTORY.DASHBOARD} as DashboardFactory"]
    templateUrl: "template-#{DIRECTIVE.WIDGET}"
    scope:
        widget: '='
    local:
        scope:
            widget: SCOPE
            flag: LOCAL_PROPERTY
            dashboard: FACTORY.DASHBOARD

        flag:
            animated: true

        onWidgetCoordinatesChange: ->
            return unless @flag.animated
            xy = @DashboardFactory.getRealXY @widget.x, @widget.y
            wh = @DashboardFactory.getRealWH @widget.w, @widget.h

            @$widget.css
                left: xy.x
                top: xy.y
                width: wh.w
                height: wh.h

        onWidgetTypeChange: ->
                return
                tagName = "widget-#{@widget.type.toLowerCase()}"
                el = @parent.$compile("<#{tagName}></#{tagName}>")(@$scope)
                @$body.html el
                @table.loadWidget @widget

        watch:
            'widget.type': 'onWidgetTypeChange'
            '[widget.x, widget.y, widget.w, widget.h, dashboard]': 'onWidgetCoordinatesChange'
    events:
        #'click .jsMoveWidgetMode': 'moveWidgetMode'
        #'mousedown .jsWidgetResize': 'onResizeStart'
        'mousedown': 'onMouseDown'

    link: ->
        @$widget = @$element.find ".jsDashboardWidget"
