root = exports ? this

class root.BoolOptionView extends root.OptionView

    templateID: 'bool-option-template'

    bindEvents: =>
        $input = @$('input')
        $input.on 'change', (value) =>
            @set($input.is(':checked') - 0)

    render: =>
        @$('input').attr('checked', @get())

    destroy: =>
        @$('input').off()
        @remove()
