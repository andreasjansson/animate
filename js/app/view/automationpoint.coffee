root = exports ? this

class root.AutomationPointView extends Backbone.View

    initialize: ->
        @point = @options['point']
        @point.on('change', @render)
        @point.on('delete', @remove)

        @scale = @options['scale']

        html = _.template $('#automation-point-template').html(),
            value: @point.get('value')
        @$el = $(html)
        @render()

    render: =>
        x = @point.get('time') * @scale.x
        y = @point.get('value') * @scale.y
        @$el.css(left: x, top: y)
