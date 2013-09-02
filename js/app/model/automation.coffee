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
        @points = []
        @pointsIndex = {}
        @recentPointIndex = null

        @get('time').on('change', @checkVisibleChange)
        @addPoint(@get('time').get('time'), @get('element').get(@get('attribute')))

    addPoint: (time, value) =>
        time = Math.round(time * 10) / 10
        existing = @points[@pointsIndex[time]]
        if existing?
            point = existing
            point.set('value', value)

        else
            point = new AutomationPoint(time: time, value: value, _originalTime: time)
            point.on('change:time', @changePointTime)
            point.on('change:value', @changePointValue)

            inserted = false
            for p, i in @points
                if time < p.get('time')
                    @points.splice(i, 0, point)
                    @pointsIndex[time] = i
                    inserted = true
                    break
            if not inserted
                @points.push(point)
                @pointsIndex[time] = @points.length - 1

            @trigger('newPoint', point)

            visibleChange = @getVisibleChange(point)
            if visibleChange?
                @get('element').set(@attribute, visibleChange)

        return point

    deletePoint: (time) =>
        i = @pointsIndex[time]
        @points.splice(i, 1)
        delete @pointsIndex[time]

    changePointTime: (point, time) =>
        # for now, optimise later
        @deletePoint(point._originalTime)
        @addPoint(time, point.get('value'))

    changePointValue: (point, value) =>
        visibleChange = @getVisibleChange(point)
        if visibleChange?
            @get('element').set(@get('attribute'), visibleChange, noAutomation: true)

    getVisibleChange: (current) =>
        time = current.get('time')
        interpolationPoints = null

        if Time.CurrentTime == time
            return current.get('value')

        else if Time.CurrentTime < time
            before = @points[@pointsIndex[time] - 1]

            if not before?
                return null

            if Time.CurrentTime > before.get('time')
                if before.get('interpolate')
                    return @interpolate(before, current, Time.CurrentTime)
                else
                    return before.get('value')

        else
            after = @points[@pointsIndex[time] + 1]
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
        # TODO: non-interpolated case
        if time of @pointsIndex
            return @points[@pointsIndex[time]].get('value')

        # try the most recent one, if it's not there do a binary search
        if @recentPointIndex?
            recentPoint = @points[@recentPointIndex]
            if time > recentPoint.get('time')
                nextPoint = @points[@recentPointIndex + 1]
                if not nextPoint?
                    return recentPoint.get('value')
                if recentPoint.get('time') < time and nextPoint.get('time') > time
                    return @interpolate(recentPoint, nextPoint, time)
                if time > nextPoint.get('time')
                    followingPoint = @points[@recentPointIndex + 2]
                    if not followingPoint?
                        @recentPointIndex += 1
                        return nextPoint.get('value')
                    if followingPoint.get('time') > time
                        @recentPointIndex += 1
                        return @interpolate(nextPoint, followingPoint, time)

        start = 0
        end = @points.length
        mid = 0
        while start < end - 1
            mid = Math.floor((end - start) / 2) + start
            if time < @points[mid].get('time')
                end = mid
            else
                start = mid

        if @get('attribute') == 'x'
            console.log(mid)

        @recentPointIndex = mid
        point = @points[mid]
        if time < point.get('time')
            prev = @points[mid - 1]
            if not prev?
                return null
            return @interpolate(prev, point, time)
        next = @points[mid + 1]
        if not next?
            return point.get('value')
        return @interpolate(point, next, time)

    checkVisibleChange: (time) =>
        change = @getVisibleChangeNear(time.get('time'))
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
