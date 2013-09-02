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

    initialize: ->
        attrs = ['x', 'y', 'width', 'height', 'opacity', 'rotation', 'zIndex']
        @automations = {}
        for attr in attrs
            do (attr) =>
                automation = new Automation(element: @, attribute: attr, time: @get('time'))
                @on 'change:' + attr, (element, value, options) =>
                    if not options.noAutomation
                        automation.addPoint(@get('time').get('time'), @get(attr))
                @automations[attr] = automation
