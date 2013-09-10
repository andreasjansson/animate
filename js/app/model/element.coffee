`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    Automation = require('./automation').Automation;
    CurrentTime = require('./time').CurrentTime;
}`
root = exports ? this

# an element *in the current time slice*
class root.Element extends Backbone.Model

    defaults: ->
        'url': null
        'imageWidth': null
        'imageHeight': null
        'x': 0,
        'y': 0,
        'width': 0
        'height': 0
        'opacity': 1
        'rotation': 0
        'zIndex': 0

    attributeSpecs:
        [['x', ((e) -> e.get('imageWidth') / 2), 700],
         ['y', ((e) -> e.get('imageHeight') / 2), 393],
         ['width', ((e) -> e.get('imageWidth')), 700],
         ['height', ((e) -> e.get('imageHeight')), 393],
         ['opacity', 1, 1],
         ['rotation', 0, 360],
         ['zIndex', 10, 20]]

    initialize: (attrs) ->
        @automations = {}

    # we need the view to tell us the width and height before we
    # can create the automation
    completeInitialization: (imageWidth, imageHeight) =>
        @set(imageWidth: imageWidth, imageHeight: imageHeight)
        for [attr, defaultValue, maxValue] in @attributeSpecs
            do (attr) =>
                value = if typeof defaultValue == 'function' then defaultValue(@) else defaultValue
                @set(attr, value)

                automation = new Automation
                    element: @
                    attribute: attr
                    maxValue: maxValue

                automation.addPoint(0, (if attr == 'opacity' then 0 else value), false)
                automation.addPoint(CurrentTime.get('time'), value)
                @on 'change:' + attr, (element, value, options) =>
                    if not options.noAutomation
                        automation.addPoint(CurrentTime.get('time'), @get(attr))
                @automations[attr] = automation

    serialize: =>
        obj =
            url: @get('url')
            imageWidth: @get('imageWidth')
            imageHeight: @get('imageHeight')
            automations: {}
        for attr, automation of @automations
            obj.automations[attr] = automation.serialize()
        return obj

    deserialize: (obj) =>
        for attr, automation of @automations
            @automations[attr].deserialize(obj.automations[attr])
