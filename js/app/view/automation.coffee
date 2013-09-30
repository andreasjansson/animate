root = exports ? this

class root.AutomationView extends Backbone.View

    initialize: ->
        @automation = @options['automation']
        @points = []
        html = _.template $('#automation-template').html(),
            attribute: @automation.get('attribute')
        @$el = $(html)
        @lines = null
        @scale = null

        @automation.on('newPoint', @newPoint)

    newPoint: (point) =>
        $timeline = @$('.timeline')
        if not @scale?
            @scale =
                x: $timeline.width() / DATA.analysis.Duration
                y: $timeline.height() / @automation.get('maxValue')
        view = new AutomationPointView(point: point, scale: @scale, $parent: $timeline)
        point.on('change', @render)
        point.on('destroy', @render)
        @render()

    render: =>
        # TODO: optimise this so we don't have to redraw the whole thing (if that's faster)
        if not @lines?
            $timeline = @$('.timeline')
            paper = Raphael($timeline[0], $timeline.width(), $timeline.height())
            @lines = paper.path()

        path = ''

        # TODO: actual for loop
        i = 0
        while i < @automation.points.length
            point = @automation.points[i]
            x1 = Math.round(point.get('time') * @scale.x)
            y1 = Math.round(point.get('value') * @scale.y)

            if i == 0
                path += 'M' + x1 + ',' + y1

            if i < @automation.points.length - 1
                next = @automation.points[i + 1]
                x2 = Math.round(next.get('time') * @scale.x)
                y2 = Math.round(next.get('value') * @scale.y)
            else
                x2 = Math.round(DATA.analysis.Duration * @scale.x)
                y2 = y1

            if point.get('interpolate')
                path += 'L' + x2 + ',' + y2
            else
                path += 'L' + x2 + ',' + y1 + 'L' + x2 + ',' + y2

            i += 1

        @lines.attr('path', path)
