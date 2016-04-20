module.exports =
    restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
    inject: "#{FACTORY.DATA_MANAGER} as DataManager, #{FACTORY.DASHBOARD} as DashboardFactory"
    templateUrl: "template-#{DIRECTIVE.WIDGET_VALUE}"
    local:
        scope:
            widget: SCOPE
            flag: SCOPE
            channels: FACTORY.DASHBOARD
            channelNames: FACTORY.DASHBOARD
            value: LOCAL_PROPERTY
            
        value:
            new: null
            old: null
            
        saveOptions: ->
            @flag.flipped = false
            @DashboardFactory.save @widget

        onDataReceived: (data)->
            unless data?.length
                console.warn "Wrong data"
                return
            @value.old = @value.new     
            @value.new = (data[data.length-1][1]).toFixed(5)
            @value.old = @value.new unless @value.old?
            @$scope.$digest() unless @$scope.$$phase

        onWidgetRemove: ->
            @DataManager.unsubscribe @widget.data.currency, @onDataReceived

        onWidgetCurrencyChange: (currency, oldCurrency)->
            unless currency is oldCurrency
                @DataManager.unsubscribe oldCurrency, @onDataReceived
                @widget.data.name = currency.slice(0,3)+"/"+currency.slice(3)
            @DataManager.subscribe @widget.data.currency, @onDataReceived

        watch:
            'widget.data.name': 'onWidgetNameChange'
            'widget.data.currency': 'onWidgetCurrencyChange'

    link: ->
        @$scope.$on 'remove', @onWidgetRemove