try
    window
catch # running on node
    _ = require('./../../node_modules/underscore')
    Backbone = require('./../../node_modules/backbone')

class Element extends Backbone.Model

    defaults:
        'url': null
        'x': 0,
        'y': 0,
        'width': 0
        'height': 0
        'opacity': 1
        'rotation': 0
        'zIndex': 0

try
    window and window.document
catch # running on node
    exports.Element = Element
