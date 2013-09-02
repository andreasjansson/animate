root = exports ? this

class root.ElementView extends Backbone.View

    initialize: ->
        @element = @options['element']
        @element.on('change', @render)

        @$el = $('<img src="' + @element.get('url') + '" />')
        @$el.on 'mousedown', @startDrag

    render: (element) =>
        changes = element.changed
        cssChanges = {}
        if 'x' of changes
            cssChanges['left'] = changes['x']
        if 'y' of changes
            cssChanges['top'] = changes['y']
        if 'width' of changes
            cssChanges['width'] = changes['width']
        if 'height' of changes
            cssChanges['height'] = changes['height']
        if 'opacity' of changes
            cssChanges['opacity'] = changes['opacity']
        if 'rotation' of changes
            rotation = changes['rotation']
            rotateString = 'rotate(#{rotation}deg)'
            cssChanges['-webkit-transform'] = rotateString
            cssChanges['-moz-transform'] = rotateString
            cssChanges['-ms-transform'] = rotateString
            cssChanges['-o-transform'] = rotateString
        if 'zIndex' of changes
            cssChanges['z-index'] = changes['zIndex']

        if cssChanges
            @$el.css(cssChanges)

        if 'url' of changes
            @$el.attr('src', url)

    # TODO: use absolute values, disable interpolation
    # while we're dragging
    startDrag: (evt) =>
        @startDragX = evt.clientX
        @startDragY = evt.clientY
        @startX = @element.get('x')
        @startY = @element.get('y')
        $('body').on('mousemove', @drag)
        $('body').on('mouseup', @stopDrag)

    drag: (evt) =>
        x = evt.clientX - @startDragX + @startX
        y = evt.clientY - @startDragY + @startY
        @element.set(x: x, y: y)

    stopDrag: (evt) =>
        $('body').off('mousemove', @drag)
        $('body').off('mouseup', @stopDrag)

        x = evt.clientX - @startDragX + @startX
        y = evt.clientY - @startDragY + @startY
        @element.set(x: x, y: y)
