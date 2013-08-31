try
    window and window.document
catch # running on node
    Backbone = require('./../../node_modules/backbone')

class Time extends Backbone.Model

    @CurrentTime = 0


try
    window and window.document
catch # running on node
    exports.Time = Time
