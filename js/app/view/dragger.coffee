root = exports ? this

class root.Dragger extends Backbone.View

    constructor: (mouseDownEvent, $relative) ->
        @$rel = $relative
        offset = @$rel.offset()
        paddingLeft = parseInt(@$rel.css('margin-left')) + parseInt(@$rel.css('padding-left')) + parseInt(@$rel.css('border-left-width'))
        paddingTop = parseInt(@$rel.css('margin-top')) + parseInt(@$rel.css('padding-top')) + parseInt(@$rel.css('border-top-width'))
        @offset = x: offset.left + paddingLeft, y: offset.top + paddingTop
        @startAbsX = mouseDownEvent.pageX
        @startAbsY = mouseDownEvent.pageY
        @startRelX = @startAbsX - @offset.x
        @startRelY = @startAbsY - @offset.y
        @startTime = new Date().getTime() / 1000

        $(document).on('mousemove', @mouseMove)
        $(document).one('mouseup', @mouseUp)

    mouseMove: (evt) =>
        absX = evt.pageX
        absY = evt.pageY
        relX = absX - @offset.x
        relY = absY - @offset.y
        @trigger 'move',
            absX: absX
            absY: absY
            relX: relX
            relY: relY
            dX: relX - @startRelX
            dY: relY - @startRelY
            target: evt.target
            startAbsX: @startAbsX
            startAbsY: @startAbsY
            startRelX: @startRelX
            startRelY: @startRelY

    mouseUp: (evt) =>
        $(document).off('mousemove', @mouseMove)
        
        absX = evt.pageX
        absY = evt.pageY
        relX = absX - @offset.x
        relY = absY - @offset.y
        @trigger 'release',
            absX: absX
            absY: absY
            relX: relX
            relY: relY
            dX: relX - @startRelX
            dY: relY - @startRelY
            target: evt.target
            timePassed: (new Date().getTime() / 1000) - @startTime
            startAbsX: @startAbsX
            startAbsY: @startAbsY
            startRelX: @startRelX
            startRelY: @startRelY
