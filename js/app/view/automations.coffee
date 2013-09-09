root = exports ? this

class root.AutomationsView extends Backbone.View

    el: '#automations'

    initialize: ->
        @elements = @options['elements']
        @elements.on('addComplete', @addElement)

    addElement: (element) =>
        group = new AutomationGroupView(element: element)
        group.$el.appendTo(@$el)
        group.scaleTitleImg()
        for attr, automation of element.automations
            view = new AutomationView(automation: automation)
            group.add(view)
