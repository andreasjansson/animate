root = exports ? this

class root.AutomationView extends Backbone.View

    initialize: ->
        @automation = @options['automation']
        @points = []
        html = _.template $('#automation-template').html(),
            attribute: @automation.get('attribute')
        @$el = $(html)

        @automation.on('newPoint', @newPoint)

    newPoint: (point) =>
        scale =
            x: @$('.timeline').width() / DATA.analysis.Duration
            y: @$('.timeline').height() / @automation.get('maxValue')
        view = new AutomationPointView(point: point, scale: scale)
        view.$el.appendTo(@$('.timeline'))
