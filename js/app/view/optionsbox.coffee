root = exports ? this

class root.OptionsBoxView extends Backbone.View

    @current = null

    el: '#options'
    optionViews: []

    initialize: =>
        if root.OptionsBoxView.current?
            root.OptionsBoxView.current.destroy()
        root.OptionsBoxView.current = @

        @$el.html('') # TODO: clear

        for name, spec of @form
            option = new spec.type
                name: name
                args: spec.args
                property: spec.property
                model: @model
            @optionViews.push(option)
            @$el.append(option.$el)
            option.bindEvents()

        console.log(@$el)
        console.log(@form)
        console.log(@optionViews)

    destroy: =>
        for option in @optionViews
            option.destroy()
