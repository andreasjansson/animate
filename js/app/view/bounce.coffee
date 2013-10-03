root = exports ? this

class root.BounceView extends Backbone.View

    el: '#bounce'

    events:
        'click': 'bounce'

    bounce: =>
        data = elements: @options.elements.serialize()
        data = JSON.stringify(data)
        $.post('/save', {name: DATA.name, data: data})
