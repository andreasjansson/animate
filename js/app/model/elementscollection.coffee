root = exports ? this

class root.ElementsCollection extends Backbone.Collection

    initialize: (models, options) ->
        @time = options['time']

    addElement: (url) =>
        element = new Element(url: url, time: @time)
        @add(element)

    serialize: =>
        return (e.serialize() for e in @models)

    unserialize: (obj) ->
        for el in obj
            element = new Element({url: el.url, time: @time}, {noInitial: true})
            @add(element)
            element.unserialize(el)
        return elements
