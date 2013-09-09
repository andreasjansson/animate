# TODO: hang on a little "handle" to currentPosition that you can use to scrub

root = exports ? this

CLICK_TIME = 0.2
CLICK_DRAG = 3

class root.ScrubberView extends Backbone.View

    el: '#scrubber'

    initialize: ->
        @duration = DATA.analysis.Duration
        CurrentTime.on('change:time', @setCurrentPosition)
        @zoom = @options['zoom']
        @zoom.on('change', @render)

        @paper = Raphael(@$el[0], @$el.width(), @$el.height())
        @buildScrubber()

        @dragger = new Dragger(@$el)
        @dragger.on('start', @mouseDown)
        @dragger.on('move', @drag)
        @dragger.on('release', @release)

    buildScrubber: =>

        @orderedPoints = @orderPoints(DATA.analysis, [
            'Beats', 'Bars', 'Sections'])

        @render()

    render: =>
        start = @zoom.get('start')
        end = @zoom.get('end')

        width = @$el.width()
        height = @$el.height()
        pxSec = width / (end - start)

        @paper.clear()
        
        oddBeat = true
        # seed hue from name
        hue = ((parseInt(DATA.name.substr(0, 3), 36) % 100) / 100) || 0
        for [time, duration, level] in @orderedPoints

            if time > end
                break

            if level == 2
                hue = (hue + 0.58) % 1
            saturation = 0.6
            if level >= 1
                oddBeat = true
            else
                oddBeat = !oddBeat
            lightness = 0.4 + (0.1 * oddBeat) + (0.1 * (level >= 1))

            if time + duration < start
                continue

            rect = @paper.rect(Math.max(time - start, 0) * pxSec, 0, duration * pxSec + 1, height)
            rect.attr(fill: Raphael.hsl(hue, saturation, lightness), stroke: 0)

        # since we clear we have to create a new one
        @currentPosition = @paper.rect(0, 0, 2, @$el.height())
        @currentPosition.attr(stroke: 0, fill: '#222222')
        @setCurrentPosition()

    orderPoints: (analysis, keys) =>
        pointsDict = {}
        for key, i in keys
            for t in analysis[key]
                pointsDict[t] = i
        times = Object.keys(pointsDict)
        points = []
        for t, i in times
            if i < times.length - 1
                duration = times[i + 1] - t
            else
                duration = analysis.Duration - t
            level = pointsDict[t]
            points.push([t, duration, level])
        return points

    mouseDown: (evt) =>
        @zoomRect = @paper.rect(evt.absX, 0, 0, @$el.height())
        @zoomRect.attr(stroke: 0, 'fill-opacity': 0.5, fill: '#222222')

    release: (evt) =>
        @zoomRect.remove()

        if (evt.timePassed < CLICK_TIME and Math.abs(evt.dX) < CLICK_DRAG) or evt.dX == 0
            return @click(evt.relX)

        [startX, endX] = [evt.startRelX, evt.relX]
        if startX > endX
            [startX, endX] = [endX, startX]

        width = @$el.width()
        scale = (@zoom.get('end') - @zoom.get('start')) / width
        startTime = startX * scale + @zoom.get('start')
        endTime = endX * scale + @zoom.get('start')

        @zoom.set(start: startTime, end: endTime)

    drag: (evt) =>
        if evt.dX > 0
            @zoomRect.attr(x: evt.startRelX, width: evt.dX)
        else
            @zoomRect.attr(x: evt.relX, width: -evt.dX)

    click: (x) =>
        scale = (@zoom.get('end') - @zoom.get('start')) / @$el.width()
        time = x * scale + @zoom.get('start')
        CurrentTime.set('time', time)

    setCurrentPosition: () =>
        scale = (@zoom.get('end') - @zoom.get('start')) / @$el.width()
        x = (CurrentTime.get('time') - @zoom.get('start')) / scale
        @currentPosition.attr(x: x)
