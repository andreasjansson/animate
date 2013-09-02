`
try {
    window
} catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    Tree = require('./tree').Tree;
    Time = require('./time').Time;
}
`

class Automation extends Backbone.Model

    events:
        'pointChange': @pointChange

    defaults:
        'element': null
        'attribute': null
        'points': null

    initialize: ->
        @set('points', new Tree())

    addPoint: (time, value) =>
        point = new AutomationPoint(time: time, value: value, _originalTime: time)
        point.on('change:time', @changePointTime)
        point.on('change:value', @changePointValue)

        @get('points').insert(time, point)
        @trigger('newPoint', point)

        visibleChange = @getVisibleChange(point)
        if visibleChange?
            @get('element').set(@attribute, visibleChange)

        return point

    deletePoint: (time) =>
        @get('points').delete(time)

    changePointTime: (point, time) =>
        originalTime = point.get('_originalTime')
        before = @get('points').prev(originalTime)
        after = @get('points').next(originalTime)

        @get('points').move(originalTime, time, point)
        point.set('_originalTime', time)

        visibleChange = @getVisibleChangeAround(before, after)
        if visibleChange?
            @get('element').set(@attribute, visibleChange)

    changePointValue: (point, value) =>
        visibleChange = @getVisibleChange(point)
        if visibleChange?
            @get('element').set(@attribute, visibleChange)

    getVisibleChangeAround: (before, after) =>
        if Time.CurrentTime > before.get('time') and Time.CurrentTime < after.get('time')
            afterBefore = @get('points').next(before.get('time'))

            if afterBefore == after
                return @interpolate(before, after, Time.CurrentTime)

            if Time.CurrentTime < afterBefore.get('time')
                return @interpolate(before, afterBefore, Time.CurrentTime)

            return @interpolate(afterBefore, after, Time.CurrentTime)

        return null

    getVisibleChange: (current) =>
        time = current.get('time')
        interpolationPoints = null

        if Time.CurrentTime == time
            return current.get('value')

        else if Time.CurrentTime < time
            before = @get('points').prev(time)

            if not before?
                return null

            if Time.CurrentTime > before.get('time')
                if before.get('interpolate')
                    return @interpolate(before, current, Time.CurrentTime)
                else
                    return before.get('value')

        else
            after = @get('points').next(time)
            if not after?
                return current.get('value')

            if Time.CurrentTime < after.get('time')
                if not current.get('interpolate')
                    return current.get('value')
                return @interpolate(current, after, Time.CurrentTime)

        return null
            
    interpolate: (before, after, time) =>
        factor = (time - before.get('time')) / (after.get('time') - before.get('time'))
        value = (after.get('value') - before.get('value')) * factor + before.get('value')
        return value


class AutomationPoint extends Backbone.Model

    defaults:
        'time': null
        'value': null
        'interpolate': true
        '_originalTime': null


try
    window and window.document
catch # running on node
    exports.Automation = Automation
    exports.AutomationPoint = AutomationPoint
