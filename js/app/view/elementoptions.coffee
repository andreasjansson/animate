root = exports ? this

class root.ElementOptionsView extends root.OptionsBoxView

    form:
        X:
            type: FloatOptionView
            property: 'x'
        Y:
            type: FloatOptionView
            property: 'y'
        Width:
            type: FloatOptionView
            property: 'width'
        Height:
            type: FloatOptionView
            property: 'height'
        Opacity:
            type: FloatOptionView
            property: 'opacity'
        Rotation:
            type: FloatOptionView
            property: 'rotation'
        'Z Index':
            type: FloatOptionView
            property: 'zIndex'
