root = exports ? this

class root.Zoom extends Backbone.Model

    defaults: ->
        start: 0
        end: DATA.analysis.Duration

    set: (key, val, options) ->
        if typeof key == 'object'
            attrs = key
            options = val
        else
            (attrs = {})[key] = val

        console.log('validate')
        duration = DATA.analysis.Duration
        if attrs.start < 0
            attrs.start = 0
        if attrs.start > duration
            attrs.start = duration
        if attrs.end < 0
            attrs.end = 0
        if attrs.end > duration
            attrs.end = duration
        if attrs.start >= attrs.end
            attrs.start = attrs.end - .1

        super(attrs, options)

    reset: ->
        @set(start: 0, end: DATA.analysis.Duration)
