module.exports =
    restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
    inject: [
        "#{FACTORY.DASHBOARD} as DashboardFactory"
        "$document"
        "$timeout"
    ]
    templateUrl: "template-#{DIRECTIVE.WIDGET}"
    scope:
        widget: '='
    local:
        scope:
            widget: SCOPE
            flag: LOCAL_PROPERTY
            dashboard: FACTORY.DASHBOARD
            remove: LOCAL_METHOD

        flag:
            animated: true
            flipped: false
            showControls: false
            dial: false
            resizeMode: false
            fullScreen: false
            hideContent: false

        $body: null
        movingWidget: {}
        
        remove: ->
            if @flag.flipped
                @flag.flipped = false
            else
                @$scope.$emit 'remove'
                @DashboardFactory.remove @widget
            
        redraw: ->
            @$timeout (=>@flag.hideContent = false), 400
            setTimeout (=>@$scope.$emit('redraw')), 400

        onWidgetCoordinatesChange: ->
            return unless @flag.animated
            xy = @DashboardFactory.getRealXY @widget.x, @widget.y
            wh = @DashboardFactory.getRealWH @widget.w, @widget.h

            @$widget.css
                left: xy.x
                top: xy.y
                width: wh.w
                height: wh.h
            @redraw()

        onWidgetTypeChange: ->
            tagName = "dashboard-widget-#{@widget.type.toLowerCase()}"
            el = @parent.$compile("<#{tagName}></#{tagName}>")(@$scope)
            @$body.html el

            setTimeout (=>
                @$widget
                .addClass('animation-xy-hw')
                .find('.opaque')
                .removeClass('opaque')
            ), 1000

        onMouseUp: ->
            @$document.off 'mousemove', @onMouseMove
            @$document.off 'mouseup', @onMouseUp
            @flag.animated = true
            @flag.resizeMode = false
            @$widget.addClass 'animation-xy-hw'
            @onWidgetCoordinatesChange()
            @removeHighZIndex()
            @DashboardFactory.saveAll()

        onMouseMove: (e)->
            x = e.pageX - @movingWidget.startX
            y = e.pageY - @movingWidget.startY

            if @flag.resizeMode
                widgetW = @movingWidget.realW + x
                widgetH = @movingWidget.realH + y

                widgetW = @movingWidget.maxW if widgetW > @movingWidget.maxW
                widgetW = @dashboard.widgetMinWidth if widgetW < @dashboard.widgetMinWidth
                widgetH = @dashboard.widgetMinHeight if widgetH < @dashboard.widgetMinHeight

                tableWH = @DashboardFactory.getTableWH widgetW, widgetH

                unless tableWH.w is @widget.w and tableWH.h is @widget.h
                    @widget.w = tableWH.w
                    @widget.h = tableWH.h
                    @DashboardFactory.getCollision @widget, @preparedWidgets

                @$widget.css
                    width: widgetW
                    height: widgetH

            else
                widgetX = @movingWidget.realX + x
                widgetY = @movingWidget.realY + y

                widgetX = 0 if widgetX < 0
                widgetY = 0 if widgetY < 0
                widgetX = @movingWidget.maxX if widgetX > @movingWidget.maxX

                tableXY = @DashboardFactory.getTableXY widgetX, widgetY

                unless tableXY.x is @widget.x and tableXY.y is @widget.y
                    @widget.x = tableXY.x
                    @widget.y = tableXY.y
                    @DashboardFactory.getCollision @widget, @preparedWidgets

                @$widget.css
                    left: widgetX
                    top: widgetY

        onResizeStart: ->
            @flag.hideContent = true
            @flag.resizeMode = true

        onMouseDown: (e)->
            return if @flag.fullScreen || e.button # left button is 0
            @$widget.addClass 'high-z-index'
            @flag.animated = false
            @$widget.removeClass 'animation-xy-hw'

            @preparedWidgets = @DashboardFactory.prepareWidgetsData @widget

            @startWidgetX = @widget.x
            @startWidgetY = @widget.y

            xy = @DashboardFactory.getRealXY @widget.x, @widget.y
            wh = @DashboardFactory.getRealWH @widget.w, @widget.h

            angular.extend @movingWidget,
                startX: e.pageX
                startY: e.pageY
                x: @widget.x
                y: @widget.y
                w: @widget.w
                h: @widget.h
                realX: xy.x
                realY: xy.y
                realW: wh.w
                realH: wh.h
                maxX: @dashboard.tableRealWidth - wh.w
                maxW: @dashboard.tableRealWidth - xy.x

            @$document.on 'mousemove', @onMouseMove
            @$document.on 'mouseup', @onMouseUp

        removeHighZIndex: ->
            setTimeout (=>
                @$widget.removeClass 'high-z-index'
            ), 500
        moveWidgetMode: (e)->
            e.button = 0
            @flag.showControls = false
            @onMouseDown e

        onFlagFullScreenChange: ->
            if @flag.fullScreen
                @flag.hideContent = true
                @$widget.addClass('high-z-index').css @dashboard.clientArea
                @redraw()
            else
                @flag.hideContent = true
                setTimeout @onWidgetCoordinatesChange, 100
                @removeHighZIndex()

        watch:
            'widget.type': 'onWidgetTypeChange'
            'flag.dial': -> @flag.dial = true if @flag.showControls
            '[widget.x, widget.y, widget.w, widget.h, dashboard.cellWidth]': 'onWidgetCoordinatesChange'
            '[flag.fullScreen, dashboard.clientArea]': 'onFlagFullScreenChange'

    events:
        'click .jsMoveWidgetMode': 'moveWidgetMode'
        'mousedown .jsWidgetResize': 'onResizeStart'
        'mousedown .jsWidgetFullScreen': -> @flag.fullScreen = !@flag.fullScreen
        'mousedown': 'onMouseDown'

    link: ->
        @$widget = @$element.find ".jsDashboardWidget"
        @$body = @$element.find ".jsDashboardWidgetBody"