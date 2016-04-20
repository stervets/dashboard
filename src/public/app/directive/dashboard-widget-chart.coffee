module.exports =
    restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
    inject: "#{FACTORY.DATA_MANAGER} as DataManager, #{FACTORY.DASHBOARD} as DashboardFactory"
    templateUrl: "template-#{DIRECTIVE.WIDGET_CHART}"
    local:
        scope:
            widget: SCOPE
            flag: SCOPE
            channels: FACTORY.DASHBOARD
            channelNames: FACTORY.DASHBOARD
            chartTypes: CHART_TYPES
            saveOptions: LOCAL_METHOD

        $chart: null
        chart: null

        chartsOptions:
            title:
                text: 'USD to EUR'
            xAxis:
                type: 'datetime'

            yAxis:
                title: null
            legend:
                enabled: false
            plotOptions:
                series:
                    marker:
                        enabled: false
                    lineWidth: 1,
                    states:
                        hover:
                            lineWidth: 2
                    threshold: null
            series: [{
                data: []
            }]

        saveOptions: ->
            @flag.flipped = false
            @DashboardFactory.save @widget

        onDataReceived: (data)->
            unless data?.length
                console.warn "Wrong data"
                return
            if data.length>1
                @serie.setData data
            else
                @serie.addPoint data[0], true, @serie.data.length>=DATA_CACHE

        redraw: ->
            @chart.reflow()
        
        
        initHighChart: ->
            @$chart = @$element.find('.jsViewHighChart').highcharts @chartsOptions
            @chart = @$chart.highcharts()
            @serie = @chart.series[0]

        onWidgetRemove: ->
            @DataManager.unsubscribe @widget.data.currency, @onDataReceived

        updateSerie: ->
            color = @DashboardFactory.getColorFromString @widget.data.name
            @serie.update
                name: @widget.data.name
                color: color
                type: @widget.data.type
                fillColor:
                    linearGradient:
                        x1: 0
                        y1: 0
                        x2: 0
                        y2: 1
                    stops: [
                        [0, color],
                        [1, Highcharts.Color(color).setOpacity(0).get('rgba')]
                    ]

        onWidgetNameChange: ->
            @chart.setTitle
                text: @widget.data.name
            @updateSerie()

        onWidgetCurrencyChange: (currency, oldCurrency)->
            unless currency is oldCurrency
                @DataManager.unsubscribe oldCurrency, @onDataReceived
                @widget.data.name = currency.slice(0,3)+" to "+currency.slice(3)
            @DataManager.subscribe @widget.data.currency, @onDataReceived
            @updateSerie()

        onWidgetTypeChange: ->
            @updateSerie()

        watch:
            'widget.data.name': 'onWidgetNameChange'
            'widget.data.currency': 'onWidgetCurrencyChange'
            'widget.data.type': 'onWidgetTypeChange'
            
    link: ->
        #@widget.data ||= {}
        #_.defaults @widget.data, @chartDefaultOptions
        @initHighChart()
        @$scope.$on 'redraw', @redraw
        @$scope.$on 'remove', @onWidgetRemove