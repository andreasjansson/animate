root = exports ? this

class root.AutomationView extends Backbone.View

    initialize: ->
        @automation = options['automation']
        @points = []
        html = _.template $('#automation-template').html(),
            url: @automation.get('attribute')
        @$el = $(html)

        @automation.on('newPoint', @newPoint)

    newPoint: (point) ->
        scale =
            x: @$el.width() / DATA.analysis.Duration
            y: @$el.height() / @automation.maxValue
        view = new AutomationPointView(point: point, scale: scale)
        view.$el.appendTo(@$el)
