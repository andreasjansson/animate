    
        


class Screen extends Backbone.View
    $el: $('#screen')

    events:
        'submit .dimensions': @dimensionsSubmit

    initialize: ->
        _.bindAll(@)
        @model.on('change', @render)

    render: ->
        width = @model.get('width')
        height = @model.get('height')
        @$('.panel').width(width).height(height)
        @$('.width').val('width', width)
        @$('.height').val('height', height)

    dimensionsSubmit: ->
        model.set(
            'width': @$('.width').val('width')
            'height': @$('.height').val('height'))

class ElementAdder extends Backbone.View

    $el: $('#element-adder')

    events: 'click .add': @toggleOverlay

    initialize: ->
        _.bindAll(@)
        @overlay = new ElementAdderOverlay()
        @overlay.on('done', (url) -> @trigger('add', url))

    toggleOverlay: ->
        @overlay.toggleShow()

class ElementAdderOverlay extends Backbone.View

    $el: $('#element-adder-overlay')

    events: 'click .done': @done

    initialize: ->
        _.bindAll(@)

    done: ->
        @trigger('done', url: @$('.url').val())
        @close()

    open: ->
        @$el.show()

    close: ->
        @$el.hide()

    toggleOverlay: ->
        if @$el.is(':visible')
            @close
        else
            @open


class Element extends Backbone.View

    initialize: ->
        _.bindAll(@)
        @model.on('change', @render)
        @$el = $('<img src="#{@url}" class="element" />')

    appendTo: ($parent) ->
        $parent.append(@$el)

    render: (model, changes) ->
        cssChanges = {}
        if 'x' of changes
            cssChanges['left'] = changes['x']
        if 'y' of changes
            cssChanges['top'] = changes['y']
        if 'width' of changes
            cssChanges['width'] = changes['width']
        if 'height' of changes
            cssChanges['height'] = changes['height']
        if 'opacity' of changes
            cssChanges['opacity'] = changes['opacity']
        if 'rotation' of changes
            rotation = changes['rotation']
            rotateString = 'rotate(#{rotation}deg)'
            cssChanges['-webkit-transform'] = rotateString
            cssChanges['-moz-transform'] = rotateString
            cssChanges['-ms-transform'] = rotateString
            cssChanges['-o-transform'] = rotateString
        if 'zIndex' of changes
            cssChanges['z-index'] = changes['zIndex']

        if cssChanges
            @$el.css(cssChanges)

        if 'url' of changes
            @$el.attr('src', url)


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

    initialize: ->
        _.bindAll(@)

# TODO only change model on mouse down
class AutomationPointView extends Backbone.View

    initialize: ->
        _.bindAll(@)
        @model.on('change', @render)




class App

    constructor: ->
        @elements = new lib.Collection()

        @screen = new model.Screen()
        new view.Screen(model: @screen)

        @time = new model.Time()
        new view.Scrubber(model: @time)

        @player = new model.Player()
        new view.PlayerControl(model: @player)

        @elementAdderView = new view.ElementAdder()
        @elementAdderView.on('add', @addElement)

        @exportButton = new Backbone.View($el: $('#export'))
        @exportButton.on('click', @export)

    addElement: (url) ->
        element = new model.Element(url: url)

    elementeAdder$select: (url) ->
        element = models.Element(url)
        @addElement(element)

    _$removeElement: (elementID) ->
        element = @elements.get(elementID)
        element.delete()

    addElement: (element) ->
        @elements.add(element)
        @screen.addView(element)
        @control.addView(element)

    save: ->
        saver = new Saver(@elements)

    elements$change: ->
        @save()

    exportButton$click: ->
        @export()

    player$tick: (time) ->
        @elements.set('time', time)

