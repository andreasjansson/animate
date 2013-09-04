`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    CurrentTime = require('./time').CurrentTime;
    Element = require('./element').Element;
}`
root = exports ? this

class root.ElementsCollection extends Backbone.Collection

    addElement: (url) =>
        element = new Element(url: url)
        @add(element)
        return element

    serialize: =>
        return (e.serialize() for e in @models)

    deserialize: (obj) ->
        for el in obj
            element = new Element(url: el.url, time: @time)
            element.completeInitialization(
                {imageWidth: el.imageWidth, imageHeight: el.imageHeight},
                {noInitial: true})
            @add(element)
            element.deserialize(el)
        return element
