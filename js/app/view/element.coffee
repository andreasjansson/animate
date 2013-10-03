root = exports ? this

class root.ElementView extends Backbone.View

    initialize: ->
        @element = @options['element']
        @element.on('change', @render)

        html = _.template $('#element-template').html(),
            url: @element.get('url')
        @$el = $(html)
        @$img = @$('img')
        window.el1 = @

        @dragger = new Dragger(@$el, $('#screen'))
        @dragger.on('start', @click)
        @dragger.on('click', @click)
        @dragger.on('move', @drag)
        @dragger.on('release', @release)

    render: (element) =>
        changes = element.changed
        if 'x' of changes
            @$el.css('left', changes.x)
        if 'y' of changes
            @$el.css('top', changes.y)
        if 'width' of changes
            @$img.css('width', changes.width)
            @$img.css('left', -changes.width / 2)
        if 'height' of changes
            @$img.css('height', changes.height)
            @$img.css('top', -changes.height / 2)
        if 'opacity' of changes
            @$el.css('opacity', changes.opacity)
        if 'rotation' of changes
            rotation = changes.rotation
            rotateString = 'rotate(#{rotation}deg)'
            @$el.css('-webkit-transform', rotateString)
            @$el.css('-moz-transform', rotateString)
            @$el.css('-ms-transform', rotateString)
            @$el.css('-o-transform', rotateString)
        if 'zIndex' of changes
            @$el.css('z-index', changes.zIndex)

        if 'url' of changes
            @$img.attr('src', url)

    close: =>
        @dragger.off()

    width: =>
        return @$img.width()

    height: =>
        return @$img.height()

    click: (evt) =>
        new ElementOptionsView(model: @element)

    drag: (evt) =>
        @element.set(x: evt.grabRelX, y: evt.grabRelY)

    release: (evt) =>
        @element.set(x: evt.grabRelX, y: evt.grabRelY)
