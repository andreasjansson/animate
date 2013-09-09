root = exports ? this

class root.Dragger extends Backbone.View

    constructor: ($el, $rel) ->
        @$el = $el
        @$rel = $rel or $el
        @$el.on('mousedown', @mouseDown)

    mouseDown: (evt) =>
        target = $(evt.target)
        offset = @$rel.offset()
        paddingLeft = parseInt(parseInt(@$rel.css('border-left-width')))
        paddingTop = parseInt(parseInt(@$rel.css('border-top-width')))
        @offset = x: offset.left + paddingLeft, y: offset.top + paddingTop
        @startAbsX = evt.pageX
        @startAbsY = evt.pageY
        @startRelX = @startAbsX - @offset.x
        @startRelY = @startAbsY - @offset.y

        @grabOffset =
            x: @startAbsX - @$el.offset().left
            y: @startAbsY - @$el.offset().top
        @startTime = new Date().getTime() / 1000

        $(document).on('mousemove', @mouseMove)
        $(document).one('mouseup', @mouseUp)

        @trigger 'start',
            absX: @startAbsX
            absY: @startAbsY
            relX: @startRelX
            relY: @startRelY

        evt.preventDefault()
        return false

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
            grabRelX: relX - @grabOffset.x
            grabRelY: relY - @grabOffset.y
        evt.preventDefault()
        return false

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
            grabRelX: relX - @grabOffset.x
            grabRelY: relY - @grabOffset.y

        evt.preventDefault()
        return false
