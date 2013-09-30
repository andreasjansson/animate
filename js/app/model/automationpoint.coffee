`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    CurrentTime = require('./time').CurrentTime;
}`
root = exports ? this

class root.AutomationPoint extends Backbone.Model

    defaults:
        'time': null
        'value': null
        'interpolate': true
        'automation': null

    prev: =>
        return @get('automation').pointBefore(@)

    next: =>
        return @get('automation').pointAfter(@)

    serialize: =>
        return time: @get('time'), value: @get('value'), interpolate: @get('interpolate')
