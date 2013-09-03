root = exports ? this

class root.AutomationPoint extends Backbone.Model

    defaults: ->
        'time': null
        'value': null
        'interpolate': true
        '_originalTime': null

    serialize: =>
        return time: @get('time'), value: @get('value'), interpolate: @get('interpolate')
