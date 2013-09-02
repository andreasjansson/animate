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

    width: =>
        return @$el.width()

    height: =>
        return @$el.height()

    # TODO: disable interpolation while we're dragging
    startDrag: (evt) =>
        dragger = new Dragger(evt, $('#screen'))
        dragger.on('move', @drag)
        dragger.on('release', @release)
        evt.preventDefault()

    drag: (evt) =>
        @element.set(x: evt.grabRelX, y: evt.grabRelY)

    release: (evt) =>
        @element.set(x: evt.grabRelX, y: evt.grabRelY)
