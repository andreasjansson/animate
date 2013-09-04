root = exports ? this

class root.ElementsView extends Backbone.View

    el: '#screen'

    initialize: ->
        @elements = @options['elements']
        @elements.on('add', @addElement)

    addElement: (element) =>
        view = new ElementView(element: element)
        view.$el.appendTo(@$el)
        element.completeInitialization(imageWidth: view.width(), imageHeight: view.height())
