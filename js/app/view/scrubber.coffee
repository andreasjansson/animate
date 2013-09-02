root = exports ? this

CLICK_TIME = 0.2
CLICK_DRAG = 3

class root.ScrubberView extends Backbone.View

    events:
        'mousedown': 'mouseDown'

    initialize: ->
        @$el = $('#scrubber')
        @zoomStart = 0
        @zoomEnd = DATA.analysis.Duration
        @duration = DATA.analysis.Duration
        console.log(@)
        @time = @options['time']
        @time.on('change:time', @setCurrentPosition)

        @paper = Raphael(@$el[0], @$el.width(), @$el.height())
        @buildScrubber()

    buildScrubber: =>

        @orderedPoints = @orderPoints(DATA.analysis, [
            'Beats', 'Bars', 'Sections'])

        @redraw(0, @duration)

    redraw: (start, end) =>
        @zoomStart = start = Math.max(start, 0)
        @zoomEnd = end = Math.min(end, @duration)

        width = @$el.width()
        height = @$el.height()
        pxSec = width / (end - start)

        @paper.clear()
        
        oddBeat = true
        hue = 0
        for [time, duration, level] in @orderedPoints

            if time > end
                break

            if level == 2
                hue = (hue + 0.43) % 1
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
        @currentPosition.attr(stroke: 0, fill: 'black')

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
        @dragStartX = evt.offsetX
        @dragStartTime = new Date().getTime() / 1000
        @zoomRect = @paper.rect(@dragStartX, 0, 0, @$el.height())
        @zoomRect.attr(stroke: 0, 'fill-opacity': 0.5, fill: 'black')
        @$el.on('mousemove', @mouseMove)
        $('body').on('mouseup.zoom', @mouseUp)

    mouseUp: (evt) =>
        dragStopX = evt.offsetX
        dragStopTime = new Date().getTime() / 1000

        @zoomRect.remove()
        @$el.off('mousemove', @mouseMove)
        $('body').off('mouseup.zoom', @mouseUp)

        if (dragStopTime - @dragStartTime < CLICK_TIME and
            Math.abs(dragStopX - @dragStartX) < CLICK_DRAG) or
            @dragStartX - dragStopX == 0
                return @click(dragStopX)

        [startX, endX] = [@dragStartX, dragStopX].sort()

        width = @$el.width()
        scale = (@zoomEnd - @zoomStart) / width
        startTime = startX * scale + @zoomStart
        endTime = endX * scale + @zoomStart

        @redraw(startTime, endTime)
        @setCurrentPosition(@time)

    mouseMove: (evt) =>
        if evt.offsetX >= @dragStartX
            @zoomRect.attr(x: @dragStartX, width: evt.offsetX - @dragStartX)
        else
            @zoomRect.attr(x: evt.offsetX, width: @dragStartX - evt.offsetX)

    click: (x) =>
        scale = (@zoomEnd - @zoomStart) / @$el.width()
        time = x * scale + @zoomStart
        @time.set('time', time)

    setCurrentPosition: (time) =>
        scale = (@zoomEnd - @zoomStart) / @$el.width()
        x = (time.get('time') - @zoomStart) / scale
        console.log(@zoomStart, @zoomEnd, scale, time.get('time'), x)
        @currentPosition.attr(x: x)
