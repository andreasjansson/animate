`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
}`
root = exports ? this

class root.Time extends Backbone.Model

    @FPS: 20

    defaults: ->
        time: 0

root.CurrentTime = new root.Time()
