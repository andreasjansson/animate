root = exports ? this

class root.ElementsCollection extends Backbone.Collection

    initialize: ->
        @time = @options['time']

    addElement: (url) =>
        element = new Element(url: url, time: @time)
        @add(element)
        return element

    serialize: =>
        return (e.serialize() for e in @models)

    unserialize: (obj) ->
        for el in obj
            element = @addElement(el.url)
            element.unserialize(el)
        return elements
