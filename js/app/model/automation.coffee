` try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    Tree = require('./tree').Tree;
}`
root = exports ? this

class root.Automation extends Backbone.Model

    defaults: ->
        'element': null
        'attribute': null
        'points': null

    initialize: ->
        @set('points', new Tree())
        @get('time').on('change', @checkVisibleChange)
        @addPoint(@get('time').get('time'), @get('element').get(@get('attribute')))

    addPoint: (time, value) =>
        time = Math.round(time * 10) / 10
        existing = @get('points').find(time)
        if existing?
            point = existing
            point.set('value', value)

        else
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
        time = Math.round(time * @get('time').get('fps')) / @get('time').get('fps')
        originalTime = point.get('_originalTime')
        before = @get('points').prev(originalTime)
        after = @get('points').next(originalTime)

        @get('points').move(originalTime, time, point)
        point.set('_originalTime', time)

        visibleChange = @getVisibleChangeAround(before, after)
        if visibleChange?
            @get('element').set(@attribute, visibleChange, noAutomation: true)

    changePointValue: (point, value) =>
        visibleChange = @getVisibleChange(point)
        if visibleChange?
            @get('element').set(@get('attribute'), visibleChange, noAutomation: true)

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
        if before.get('value') == after.get('value')
            return before.get('value')
        factor = (time - before.get('time')) / (after.get('time') - before.get('time'))
        value = (after.get('value') - before.get('value')) * factor + before.get('value')
        return value

    getVisibleChangeNear: (time) =>
        # TODO: cache nearest and use iterator
        t = time.get('time')
        before = @get('points').searchPrev(t)

        if not before
            return null

        if not before.get('interpolate')
            return before.get('value')
        after = @get('points').next(before.get('time'))
        if not after
            return before.get('value')

        return @interpolate(before, after, t)

    checkVisibleChange: (time) =>
        change = @getVisibleChangeNear(time)
        if change?
            @get('element').set(@get('attribute'), change, noAutomation: true)


class AutomationPoint extends Backbone.Model

    defaults: ->
        'time': null
        'value': null
        'interpolate': true
        '_originalTime': null


try
    window and window.document
catch # running on node
    exports.Automation = Automation
    exports.AutomationPoint = AutomationPoint
