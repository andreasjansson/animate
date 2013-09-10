`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    CurrentTime = require('./time').CurrentTime;
    Element = require('./element').Element;
}`
root = exports ? this

class root.ElementsCollection extends Backbone.Collection

    addElement: (url, options) =>
        element = new Element(url: url)
        @add(element, options)
        return element

    serialize: =>
        return (e.serialize() for e in @models)

    deserialize: (obj) =>
        for el in obj
            element = @addElement(el.url)
            element.deserialize(el)
        return element
