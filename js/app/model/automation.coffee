`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    AutomationPoint = require('./automationpoint').AutomationPoint;
    CurrentTime = require('./time').CurrentTime;
}`
root = exports ? this

class root.Automation extends Backbone.Model

    defaults: =>
        'element': null
        'attribute': null
        'points': null

    initialize: ->
        @points = []
        @recentPointIndex = 0 # caching

        CurrentTime.on('change', @checkVisibleChange)

    addPoint: (time, value, interpolate=true) =>
        index = @getIndexNear(time)

        if index? and @points[index].get('time') == time
            point = @points[index]
            point.set('value', value)
            point.set('interpolate', interpolate)

        else
            point = new AutomationPoint
                time: time
                value: value
                interpolate: interpolate
                _originalTime: time
            point.on('change:time', @changePointTime)
            point.on('change:value', @changePointValue)

            inserted = false
            for p, i in @points
                if time < p.get('time')
                    @points.splice(i, 0, point)
                    index = i
                    inserted = true
                    break
            if not inserted
                index = @points.length - 1
                @points.push(point)

            @trigger('newPoint', point)

        visibleChange = @getVisibleChange(point, index)
        if visibleChange?
            @get('element').set(@get('attribute'), visibleChange)

        return point

    deletePoint: (time) =>
        time = Math.round(time * 10) / 10
        index = @getIndexNear(time)
        if index? and @points[index].get('time') == time
            @points.splice(index, 1)

    changePointTime: (point, time) =>
        # for now, optimise later
        @deletePoint(point._originalTime)
        @addPoint(time, point.get('value'))

    changePointValue: (point, value) =>
        index = @getIndexNear(point.get('time'))
        visibleChange = @getVisibleChange(point, index)
        if visibleChange?
            @get('element').set(@get('attribute'), visibleChange, noAutomation: true)

    getVisibleChange: (current, index) =>
        if !index?
            index = @getIndexNear(current.get('time'))

        time = current.get('time')
        interpolationPoints = null

        if CurrentTime.get('time') == time
            return current.get('value')

        else if CurrentTime.get('time') < time
            before = @points[index - 1]

            if not before?
                return null

            if CurrentTime.get('time') > before.get('time')
                return @interpolate(before, current, CurrentTime.get('time'))

        else
            after = @points[index + 1]
            if not after?
                return current.get('value')

            if CurrentTime.get('time') < after.get('time')
                return @interpolate(current, after, CurrentTime.get('time'))

        return null
            
    interpolate: (before, after, time) =>
        if before.get('value') == after.get('value') or not before.get('interpolate')
            return before.get('value')
        factor = (time - before.get('time')) / (after.get('time') - before.get('time'))
        value = (after.get('value') - before.get('value')) * factor + before.get('value')
        return value

    getValueNear: (time) =>
        # TODO: non-interpolated case

        # try the most recent one, if it's not there do a binary search
        recentPoint = @points[@recentPointIndex]
        if recentPoint?
            if time == recentPoint.get('time')
                return recentPoint.get('value')
            if time > recentPoint.get('time')
                nextPoint = @points[@recentPointIndex + 1]
                if not nextPoint?
                    return recentPoint.get('value')
                if recentPoint.get('time') < time and nextPoint.get('time') > time
                    return @interpolate(recentPoint, nextPoint, time)
                if time == nextPoint.get('time')
                    return nextPoint.get('value')
                if time > nextPoint.get('time')
                    followingPoint = @points[@recentPointIndex + 2]
                    if not followingPoint?
                        @recentPointIndex += 1
                        return nextPoint.get('value')
                    if time < followingPoint.get('time')
                        @recentPointIndex += 1
                        return @interpolate(nextPoint, followingPoint, time)

        index = @getIndexNear(time)
        if !index?
            return null

        point = @points[index]

        if time == point.get('time')
            @recentPointIndex = index
            return point.get('value')

        if time < point.get('time')
            prev = @points[index - 1]
            if not prev?
                return null
            @recentPointIndex = index - 1
            return @interpolate(prev, point, time)
        next = @points[index + 1]
        @recentPointIndex = index
        if not next?
            return point.get('value')
        return @interpolate(point, next, time)

    checkVisibleChange: (time) =>
        change = @getValueNear(time.get('time'))
        if change?
            @get('element').set(@get('attribute'), change, noAutomation: true)

    getIndexNear: (time) =>
        if !@points.length
            return null

        start = 0
        end = @points.length
        mid = null
        while start <= end and start < @points.length
            mid = Math.floor((end - start) / 2) + start
            if @points[mid].get('time') == time
                return mid
            if time < @points[mid].get('time')
                end = mid - 1
            else
                start = mid + 1
        return mid

    serialize: =>
        obj = points: []
        for point in @points
            obj.points.push(point.serialize())
        return obj

    deserialize: (obj) =>
        for p in obj.points
            @addPoint(p.time, p.value)
