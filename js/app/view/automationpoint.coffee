root = exports ? this

class root.AutomationPointView extends Backbone.View

    initialize: ->
        @point = @options.point
        @point.on('change', @render)
        @point.on('delete', @remove)

        @scale = @options.scale

        html = _.template $('#automation-point-template').html(),
            value: @point.get('value')
        @$el = $(html)
        @render()
        @$el.appendTo(@options.$parent)
        
        @dragger = new Dragger(@$el, @options.$parent)
        @dragger.on('start', @click)
        @dragger.on('move', @drag)
        @dragger.on('release', @release)
        @dragger.on('click', @click)

    render: =>
        x = @point.get('time') * @scale.x
        y = @point.get('value') * @scale.y
        @$el.css(left: x, top: y)

        next = @point.next()
        prev = @point.prev()

        if next?
            nextTime = next.get('time')
            nextValue = next.get('value')
        else
            nextTime = DATA.analysis.Duration
            nextValue = @point.get('value')
        
    click: =>
        new AutomationPointOptionsView(model: @point)

    drag: (evt) =>
        if evt.dX
            @point.set('time', evt.relX / @scale.x)
        if evt.dY
            @point.set('value', evt.relY / @scale.y)
