jasmine = require('jasmine-node')
Automation = require('./../app/model/automation').Automation
Element = require('./../app/model/element').Element
Time = require('./../app/model/time').Time
CurrentTime = require('./../app/model/time').CurrentTime

describe 'automation.js', ->

    beforeEach ->
        @element = new Element(url: 'http://example.com/foo.jpg')
        @automation = new Automation(element: @element, attribute: 'foo')
        @p = (time, value) -> new AutomationPoint(time: time, value: value, _originalTime: time)

    it 'adds a point', ->
        @automation.addPoint(10, 10)
        expect(@automation.points.length).toEqual(1)
        @automation.addPoint(20, 10)
        expect(@automation.points.length).toEqual(2)
        @automation.addPoint(10, 5)
        expect(@automation.points.length).toEqual(2)
        expect(@automation.points[@automation.getIndexNear(10)].get('value')).toEqual(5)

    it 'deletes a point', ->
        @automation.addPoint(10, 10)
        expect(@automation.points.length).toEqual(1)
        @automation.addPoint(20, 10)
        expect(@automation.points.length).toEqual(2)
        @automation.deletePoint(10)
        expect(@automation.points.length).toEqual(1)
        @automation.deletePoint(20)
        expect(@automation.points.length).toEqual(0)

    it 'interpolates', ->
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 5)).toEqual(50)
        expect(@automation.interpolate(@p(10, 20), @p(30, 10), 20)).toEqual(15)
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 1)).toEqual(10)
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 9)).toEqual(90)
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 10)).toEqual(100)

    it 'gets a visible change with interpolation', ->
        CurrentTime.set('time', 10)
        point = @automation.addPoint(0, 10)
        expect(@automation.getVisibleChange(point)).toEqual(10)
        point = @automation.addPoint(0, 0)
        expect(@automation.getVisibleChange(point)).toEqual(0)
        point = @automation.addPoint(20, 20)
        expect(@automation.getVisibleChange(point)).toEqual(10)
        point = @automation.addPoint(0, 10)
        expect(@automation.getVisibleChange(point)).toEqual(15)

    it 'gets a visible change without interpolation', ->
        CurrentTime.set('time', 10)
        point = @automation.addPoint(0, 10)
        expect(@automation.getVisibleChange(point)).toEqual(10)
        point = @automation.addPoint(0, 0)
        point.set('interpolate', false)
        point = @automation.addPoint(20, 20)
        expect(@automation.getVisibleChange(point)).toEqual(0)
        point = @automation.addPoint(0, 10)
        point.set('interpolate', false)
        expect(@automation.getVisibleChange(point)).toEqual(10)

    it 'gets an invisible change', ->
        CurrentTime.set('time', 10)
        point = @automation.addPoint(20, 10)
        expect(@automation.getVisibleChange(point)).toBeFalsy()
        @automation.addPoint(0, 0)
        @automation.addPoint(10, 5)
        point = @automation.addPoint(0, -10)
        expect(@automation.getVisibleChange(point)).toBeFalsy()
        point = @automation.addPoint(5, -10)
        expect(@automation.getVisibleChange(point)).toBeFalsy()
        point = @automation.addPoint(15, -10)
        expect(@automation.getVisibleChange(point)).toBeFalsy()

    it 'gets a value near', ->
        @automation.addPoint(0, 0)
        @automation.addPoint(10, 100)
        @automation.addPoint(20, 300)
        @automation.addPoint(30, 0)

        spyOn(@automation, 'getIndexNear').andCallThrough()

        expect(@automation.recentPointIndex).toEqual(0)
        expect(@automation.getValueNear(0)).toEqual(0)
        expect(@automation.recentPointIndex).toEqual(0)
        expect(@automation.getIndexNear).not.toHaveBeenCalled()

        @automation.getIndexNear.reset()
        
        expect(@automation.getValueNear(5)).toEqual(50)
        expect(@automation.recentPointIndex).toEqual(0)
        expect(@automation.getIndexNear).not.toHaveBeenCalled()

        @automation.getIndexNear.reset()
        
        expect(@automation.getValueNear(7)).toEqual(70)
        expect(@automation.recentPointIndex).toEqual(0)
        expect(@automation.getIndexNear).not.toHaveBeenCalled()
       
        @automation.getIndexNear.reset()
        
        expect(@automation.getValueNear(11)).toEqual(120)
        expect(@automation.recentPointIndex).toEqual(1)
        expect(@automation.getIndexNear).not.toHaveBeenCalled()
        
        @automation.getIndexNear.reset()
        
        expect(@automation.getValueNear(3)).toEqual(30)
        expect(@automation.recentPointIndex).toEqual(0)
        expect(@automation.getIndexNear).toHaveBeenCalled()
        
        @automation.getIndexNear.reset()
        
        expect(@automation.getValueNear(50)).toEqual(0)
        expect(@automation.recentPointIndex).toEqual(3)
        expect(@automation.getIndexNear).toHaveBeenCalled()
        
        @automation.getIndexNear.reset()
        
        expect(@automation.getValueNear(60)).toEqual(0)
        expect(@automation.recentPointIndex).toEqual(3)
        expect(@automation.getIndexNear).not.toHaveBeenCalled()
