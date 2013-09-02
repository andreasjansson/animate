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

    add: (view) =>
        @views.add(view)
        @view.$el.appendTo(@$('.group'))

    collapse: =>
        @$el.removeClass('expanded')

    expand: =>
        @$el.addClass('expanded')
        
