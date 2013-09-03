`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
}`
root = exports ? this

# an element *in the current time slice*
class root.Element extends Backbone.Model

    defaults: ->
        'url': null
        'x': 0,
        'y': 0,
        'width': 0
        'height': 0
        'opacity': 1
        'rotation': 0
        'zIndex': 0

    attrs:
        [['x', 700], # TODO: make less horrid
         ['y', 393],
         ['width', 700],
         ['height', 393],
         ['opacity', 1],
         ['rotation', 360],
         ['zIndex', 20]]

    initialize: (attrs, options) ->
        @automations = {}
        for [attr, maxValue] in @attrs
            do (attr) =>
                automation = new Automation(element: @, attribute: attr, time: @get('time'), maxValue: maxValue)
                if not (options and options.noInitial)
                    automation.addPoint(@get('time').get('time'), @get('attribute'))
                @on 'change:' + attr, (element, value, options) =>
                    if not options.noAutomation
                        automation.addPoint(@get('time').get('time'), @get(attr))
                @automations[attr] = automation

    serialize: =>
        obj = url: @get('url'), automations: {}
        for attr, automation of @automations
            console.log(attr, automation)
            obj.automations[attr] = automation.serialize()
        return obj

    unserialize: (obj) ->
        for attr, automation of @automations
            @automations[attr].unserialize(obj.automations[attr])
