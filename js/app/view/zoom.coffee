root = exports ? this

ZOOM_FACTOR = 1.6

class root.ZoomView extends Backbone.View

    el: '#zoom'

    events:
        'click .out': 'zoomOut'
        'click .in': 'zoomIn'
        'click .reset': 'reset'

    initialize: ->
        @zoom = @options['zoom']
        @time = @options['time']

    zoomOut: ->
        space = @zoom.get('end') - @zoom.get('start')
        mid = (@zoom.get('end') + @zoom.get('start')) / 2
        space *= ZOOM_FACTOR
        @zoom.set
            start: mid - space / 2
            end: mid + space / 2

    zoomIn: ->
        space = @zoom.get('end') - @zoom.get('start')
        if @time.get('time') >= @zoom.get('start') and @time.get('time') <= @zoom.get('end')
            mid = @time.get('time')
        else
            mid = (@zoom.get('end') + @zoom.get('start')) / 2
        space /= ZOOM_FACTOR
        @zoom.set
            start: mid - space / 2
            end: mid + space / 2

    reset: ->
        @zoom.reset()
