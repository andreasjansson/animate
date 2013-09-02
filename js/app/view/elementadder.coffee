root = exports ? this

class root.ElementAdderView extends Backbone.View

    el: '#add-element'

    events:
        'submit form': 'addElement'

    initialize: =>
        @elements = @options['elements']

    addElement: =>
        url = @$('.url').val()
        p = @isValidImageURL(url)
        p.done =>
            @elements.addElement(url)
        p.fail =>
            alert('Sorry, that looks like a broken image')
        @$('input').blur()
        return false

    isValidImageURL: (url) =>
        promise = $.Deferred()
        img = new Image()
        img.onload = promise.resolve
        img.onerror = promise.reject
        img.src = url
        return promise
