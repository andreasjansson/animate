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

    initialize: ->
        @automations = {}
        for [attr, maxValue] in @attrs
            do (attr) =>
                automation = new Automation(element: @, attribute: attr, time: @get('time'), maxValue: maxValue)
                @on 'change:' + attr, (element, value, options) =>
                    if not options.noAutomation
                        automation.addPoint(@get('time').get('time'), @get(attr))
                @automations[attr] = automation

    serialize: =>
        data = url: @url, automations: {}
        for attr, automation in automations:
            data.automations[attr] = automation.serialize()
        return data

    unserialize: (obj) ->
        for attr, a in automations
            @automations[attr].unserialize(a)
