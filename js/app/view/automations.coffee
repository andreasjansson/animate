root = exports ? this

class root.AutomationsView extends Backbone.View

    el: '#automations'

    initialize: ->
        @elements = @options['elements']
        @elements.on('add', @addElement)

    addElement: (element) =>
        group = new AutomationGroupView(element: element)
        for automation in element.automations
            view = new AutomationView(automation: automation)
            group.add(view)
        group.$el.appendTo(@$el)
