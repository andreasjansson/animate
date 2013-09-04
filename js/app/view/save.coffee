root = exports ? this

class root.SaveView extends Backbone.View

    el: '#save'

    events:
        'click': 'save'

    save: =>
        data =
            elements: @options.elements.serialize()
        data = JSON.stringify(data)
        $.post('/save', {name: DATA.name, data: data})
            .done(@success)
            .fail(@error)

    success: =>
        @$el.fadeOut().fadeIn()

    error: =>
        alert('Save failed! Please try again.')
