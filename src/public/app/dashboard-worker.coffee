_ = require '../../../vendor/underscore/underscore.js'

class DashboardWorker
  global: null

# Get collision between widget (w) and other widgets
  getCollision: (w, widgets)->
    collided = []
    widgets.forEach (ww) ->
      collided.push ww if (w.y < ww.y + ww.h and w.y + w.h > ww.y) and (w.x < ww.x + ww.w and w.x + w.w > ww.x)
    collided

# Get free place for widget
  getFreePlace: (w, widgets, tableWidth)->
    if w.w > tableWidth
      console.warn "Error: widget '#{w.id} width (#{w.w}) > table width (#{tableWidth})'"
      return w
    for y in [0..0xFFFFFF]
      for x in [0..(tableWidth - w.w)]
        w.x = x
        w.y = y
        unless @getCollision(w, widgets).length
          return w
    return w

  getTableHeight: (widgets)->
    height = 0
    widgets.forEach (widget)->
      widgetBottom = widget.y + widget.h
      height = widgetBottom if widgetBottom > height
    height

# Send new widgets coordinates
  moveWidgets: (widgets, scrollTo, deferId, widget)->
    allWidgets = widgets
    allWidgets.push widget if widget?
    @global.postMessage
      com: 'moveWidgets'
      widgets: widgets
      scrollTo: scrollTo
      deferId: deferId
      tableHeight: @getTableHeight allWidgets

# Sort widgets by position
  sortWidgets: (widgets, tableWidth)-> widgets.sort (a, b)->
    aa = a.y * tableWidth + a.x
    bb = b.y * tableWidth + b.x
    return 0 if aa is bb
    return if aa < bb then -1 else 1

  handlers:
# Get collisions between widgets
    getCollision: (data)->
      if (collided = @getCollision(data.widget, data.widgets)).length
        collided.forEach (widget)=>
          @getFreePlace(widget, _(data.widgets).without(widget).concat([data.widget]), data.tableWidth)
      @moveWidgets data.widgets, null, data.deferId, data.widget

# Find free place for given widget
    getFreePlace: (data)->
      @moveWidgets [@getFreePlace(data.widget, data.widgets, data.tableWidth)], data.scrollTo, data.deferId, data.widget

# Close gaps between all widgets
    arrangeWidgets: (data)->
      @sortWidgets data.widgets, data.tableWidth
      sliceIndex = if data.widget? then data.widgets.indexOf(_(data.widgets).findWhere(id: data.widget.id)) else 0
      widgets = data.widgets.slice 0, sliceIndex
      for widgetIndex in [sliceIndex...data.widgets.length]
        widgets.push @getFreePlace(data.widgets[widgetIndex], widgets, data.tableWidth)
      @moveWidgets widgets.slice(sliceIndex), data.scrollTo, data.deferId, data.widget

  constructor: (@global)->
    @global.addEventListener 'message', (event)=>
      data = event.data
      @handlers[data.com].call @, data if @handlers[data.com]?

module.exports = (global)->
  new DashboardWorker global
