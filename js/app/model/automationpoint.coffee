root = exports ? this

class AutomationPoint extends Backbone.Model

    defaults: ->
        'time': null
        'value': null
        'interpolate': true
        '_originalTime': null

    serialize: =>
        return time: @time, value: @value, interpolate: @interpolate

    @unserialize: (o) ->
        return new AutomationPoint(o)
