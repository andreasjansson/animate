jasmine = require('jasmine-node')
automation = require('./../app/model/automation')
Automation = automation.Automation
AutomationPoint = automation.AutomationPoint
Element = require('./../app/model/element').Element
Time = require('./../app/model/time').Time

describe 'automation.js', ->

    beforeEach ->
        @element = new Element(url: 'http://example.com/foo.jpg')
        @automation = new Automation(element: @element, attribute: 'foo')
        @p = (time, value) -> new AutomationPoint(time: time, value: value, _originalTime: time)
        Time.CurrentTime = 0

    it 'adds a point', ->
        @automation.addPoint(10, 10)
        expect(@automation.get('points').size()).toEqual(1)
        @automation.addPoint(20, 10)
        expect(@automation.get('points').size()).toEqual(2)
        @automation.addPoint(10, 5)
        expect(@automation.get('points').size()).toEqual(2)
        expect(@automation.get('points').find(10).get('value')).toEqual(5)

    it 'deletes a point', ->
        @automation.addPoint(10, 10)
        expect(@automation.get('points').size()).toEqual(1)
        @automation.addPoint(20, 10)
        expect(@automation.get('points').size()).toEqual(2)
        @automation.deletePoint(10)
        expect(@automation.get('points').size()).toEqual(1)
        @automation.deletePoint(20)
        expect(@automation.get('points').size()).toEqual(0)

    it 'interpolates', ->
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 5)).toEqual(50)
        expect(@automation.interpolate(@p(10, 20), @p(30, 10), 20)).toEqual(15)
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 1)).toEqual(10)
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 9)).toEqual(90)
        expect(@automation.interpolate(@p(0, 0), @p(10, 100), 10)).toEqual(100)

    it 'gets a visible change with interpolation', ->
        Time.CurrentTime = 10
        point = @automation.addPoint(0, 10)
        expect(@automation.getVisibleChange(point)).toEqual(10)
        point = @automation.addPoint(0, 0)
        expect(@automation.getVisibleChange(point)).toEqual(0)
        point = @automation.addPoint(20, 20)
        expect(@automation.getVisibleChange(point)).toEqual(10)
        point = @automation.addPoint(0, 10)
        expect(@automation.getVisibleChange(point)).toEqual(15)

    it 'gets a visible change without interpolation', ->
        Time.CurrentTime = 10
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
        Time.CurrentTime = 10
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

    it 'gets a visible change around', ->
        Time.CurrentTime = 5
        point1 = @automation.addPoint(0, 0)
        point2 = @automation.addPoint(10, 100)
        point3 = @automation.addPoint(20, -100)
        expect(@automation.getVisibleChangeAround(point1, point2)).toEqual(50)
        expect(@automation.getVisibleChangeAround(point2, point3)).toBeFalsy()
        expect(@automation.getVisibleChangeAround(point1, point3)).toEqual(50)
        Time.CurrentTime = 15
        expect(@automation.getVisibleChangeAround(point1, point3)).toEqual(0)
