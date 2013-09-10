root = exports ? this

class root.AutomationGroupView extends Backbone.View

    events:
        'click .expand': 'expand'
        'click .collapse': 'collapse'

    initialize: ->
        @element = @options['element']
        html = _.template $('#automation-group-template').html(),
            url: @element.get('url')
        @$el = $(html)
        @views = []
        @collapsed = true
        @$expander = @$('.expander')

    scaleTitleImg: =>
        $img = @$('.title img')
        maxWidth = 40
        maxHeight = 50
        width = $img.width()
        height = $img.height()
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
        @$expander.removeClass('collapse').addClass('expand')
        @$('.automation-line').animate({height: 0}, 100)
        return false

    expand: =>
        @$expander.removeClass('expand').addClass('collapse')
        @$('.automation-line').animate({height: 55}, 100)
        return false
        
