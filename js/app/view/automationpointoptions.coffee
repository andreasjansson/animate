root = exports ? this

class root.AutomationPointOptionsView extends root.OptionsBoxView

    form:
        Time:
            type: FloatOptionView
            args:
                min: 0
                max: DATA.analysis.Duration,
            property: 'time'
        Value:
            type: FloatOptionView
            property: 'value'
        Interpolate:
            type: BoolOptionView
            property: 'interpolate'
