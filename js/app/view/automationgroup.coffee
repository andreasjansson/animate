root = exports ? this

class root.AutomationGroupView extends Backbone.View

    events:
        'click .collapse': 'collapse'
        'click .expand': 'expand'

    initialize: ->
        @element = @options['element']
        html = _.template $('#automation-group-template').html(),
            url: @element.get('url')
        @$el = $(html)
        @views = []
        @collapsed = true

    scaleTitleImg: =>
        $img = @$('.title img')
        maxWidth = 40
        maxHeight = 50
        width = $img.width()
        height = $img.height()
        console.log($img, width, height)
        if width > maxWidth or height > maxHeight
            aspect = width / height
            boxAspect = maxWidth / maxHeight
            if aspect < boxAspect
                scale = maxHeight / height
            else
                scale = maxWidth / width
            width = width * scale
            height = height * scale
            $img.width(width)
            $img.height(height)

    add: (view) =>
        @views.push(view)
        view.$el.appendTo(@$el)

    collapse: =>
        @$el.removeClass('expanded')

    expand: =>
        @$el.addClass('expanded')
        
