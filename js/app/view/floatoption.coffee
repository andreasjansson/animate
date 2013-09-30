root = exports ? this

class root.FloatOptionView extends root.OptionView

    templateID: 'float-option-template'

    bindEvents: =>
        $input = @$('input')
        $input.on 'change', (value) =>
            @set($input.val() - 0)

    render: =>
        @$('input').val(@get())

    get: =>
        return Math.round(@model.get(@options['property']) * 1000) / 1000

    destroy: =>
        @$('input').off()
        @remove()
