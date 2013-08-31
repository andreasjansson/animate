if not Backbone?
    Backbone = require('./lib/backbone').Backbone

class Automation extends Backbone.Model

    events:
        'pointChange': @pointChange

    defaults:
        'element': null
        'attribute': null
        'points': new Tree()

    initialize: ->
        _.bindAll(@)

    addPoint: (time, value) ->
        point = new AutomationPoint(time: time, value: value, _originalTime: time)
        point.on('change:time', @changePointTime)
        point.on('change:value', @changePointValue)

        @points.insert(time, point)
        @trigger('newPoint', point)

        visibleChange = @getVisibleChange(point)
        if visibleChange?
            element.set(@attribute, visibleChange)

    changePointTime: (point, time) ->
        originalTime = point.get('_originalTime')
        before = @points.iterator(originalTime).prev().current().value
        after = @points.iterator(originalTime).next().current().value

        @points.move(originalTime, time, point)
        point.set('_originalTime', time)

        visibleChange = @getVisibleChangeAround(before, after)
        if visibleChange?
            element.set(@attribute, visibleChange)

    changePointValue: (point, value) ->
        visibleChange = @getVisibleChange(point)
        if visibleChange?
            element.set(@attribute, visibleChange)

    getVisibleChangeAround: (before, after) ->
        if CurrentTime > before.get('time') and CurrentTime < after.get('time')
            afterBefore = @points.iterator(before.get('time')).next().current().value

            if afterBefore == after
                return @interpolate(before, after, CurrentTime)

            if CurrentTime < afterBefore.get('time')
                return @interpolate(before, afterBefore, CurrentTime)

            return @interpolate(afterBefore, after, CurrentTime)

        return null

    getVisibleChange: (current) ->
        time = current.get('time')
        interpolationPoints = null

        if currentTime == time
            return currentTime.get('value')

        else if CurrentTime < time
            before = @points.iterator(time).prev().current().value
            if CurrentTime > before.get('time') and before.value.get('interpolate')
                return @interpolate(before, current, CurrentTime)

        else
            after = @points.iterator(time).next().current().value
            if CurrentTime < after.get('time')
                if not current.get('interpolate')
                    return current.get('value')
                return @interpolate(current, after, CurrentTime)

        return null
            
    interpolate: (before, after, time) ->
        factor = (time - before.get('time')) / (after.get('time') - before.get('time'))
        value = (after.get('value') - before.get('value')) * factor
        return value


class AutomationPoint extends Backbone.Model

    defaults:
        'time': null
        'value': null
        'interpolate': true
        '_originalTime': null

    initialize: ->
        _.bindAll(@)
