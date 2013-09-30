root = exports ? this

class root.OptionView extends Backbone.View

    initialize: =>
        html = _.template $('#' + @templateID).html(),
            name: @options.name
            value: @get()
        @$el = $('<div class="option">' + html + '</div>')
        @model.on('change', @render)

    set: (value) =>
        @model.set(@options['property'], value)

    get: =>
        return @model.get(@options['property'])
