root = exports ? this

class root.ElementsCollection extends Backbone.Collection

    initialize: ->
#        @time = @options['time']

    addElement: (url) =>
        element = new Element(url: url, time: time)
        @add(element)
