`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
}`
root = exports ? this


class root.Time extends Backbone.Model

    defaults: ->
        time: 0
        fps: 20


try
    window and window.document
catch # running on node
    exports.Time = Time
