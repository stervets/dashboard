module.exports =
  restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
  inject: [
    "#{FACTORY.DASHBOARD} as DashboardFactory"
    "$document"
  ]
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
      flipped: false
      showControls: false
      dial: false
      moving: false


    $body: null
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
      tagName = "dashboard-widget-#{@widget.type.toLowerCase()}"
      el = @parent.$compile("<#{tagName}></#{tagName}>")(@$scope)
      @$body.html el
      setTimeout (=>@$body.find(".jsDashboardWidgetBack").removeClass('flipped')), 100
      
    onMouseUp: ->
      @$document.off 'mousemove', @onMouseMove
      @$document.off 'mouseup', @onMouseUp
      @flag.animated = true
      @$widget.addClass 'animation-xy-hw'
      @size = null if @size
      @onWidgetCoordinatesChange()
      @DashboardFactory.save()

    onMouseMove: (e)->
      x = e.pageX - @startX
      y = e.pageY - @startY
    
      if @size
        return
        maxWidth = dashboard.tableWidth * @dashboard.cellWidth - @size.w
        x = maxWidth if x > maxWidth
        maxWidth = dashboard.tableWidth * @dashboard.cellWidth - @size.w
    
        minWidth = @dashboard.cellWidth * 2 - @size.w - CELL.SPACE
        x = minWidth if x<minWidth
    
        minHeight = CELL.INNER_Y - @size.h
        y = minHeight if y<minHeight
    
        wh = @getTableWH @size.w + x - @size.x, @size.h + y - @size.y
        return if wh.w<2 or wh.h<1
        @$widget.css
          width: @size.w + x - @size.x
          height: @size.h + y - @size.y
    
        if wh.w isnt @widget.w or wh.h isnt @widget.h
          @widget.w = wh.w
          @widget.h = wh.h
          @DashboardFactory.getCollision @widget, @preparedWidgets
          setTimeout @widget.redraw, 100
      else
        x = 0 if x < 0
        y = 0 if y < 0
    
        maxWidth = (@dashboard.tableWidth - @widget.w) * @dashboard.cellWidth
        x = maxWidth if x > maxWidth
    
        tableXY = @DashboardFactory.getTableXY x, y
        @widget.x = tableXY.x
        @widget.y = tableXY.y
    
        if tableXY.x isnt @savedX or tableXY.y isnt @savedY
          @savedX = tableXY.x
          @savedY = tableXY.y
          @DashboardFactory.getCollision @widget, @preparedWidgets
    
        @$widget.css
          left: x
          top: y
      
    onMouseDown: (e)->
      return if e.button # left button is 0
      @flag.animated = false
      @$widget.removeClass 'animation-xy-hw'

      @preparedWidgets = @DashboardFactory.prepareWidgetsData @widget

      @savedX = @widget.x
      @savedY = @widget.y

      position = @$widget.position()
      @startX = e.pageX - position.left
      @startY = e.pageY - position.top

      @$document.on 'mousemove', @onMouseMove
      @$document.on 'mouseup', @onMouseUp

    watch:
      'widget.type': 'onWidgetTypeChange'
      'flag.dial': ->
        @flag.dial = true if @flag.showControls
      '[widget.x, widget.y, widget.w, widget.h, dashboard]': 'onWidgetCoordinatesChange'
  events:
    'click .jsMoveWidgetMode': 'moveWidgetMode'
    'mousedown .jsWidgetResize': 'onResizeStart'
    'mousedown': 'onMouseDown'

  link: ->
    @$widget = @$element.find ".jsDashboardWidget"
    @$body = @$element.find ".jsDashboardWidgetBody"
    @widget.$move = @onWidgetCoordinatesChange
