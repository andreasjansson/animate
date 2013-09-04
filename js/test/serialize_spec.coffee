jasmine = require('jasmine-node')
Automation = require('./../app/model/automation').Automation
ElementsCollection = require('./../app/model/elementscollection').ElementsCollection
Element = require('./../app/model/element').Element
Time = require('./../app/model/time').Time

describe 'serialization', ->

    beforeEach ->
        CurrentTime.set('time', 0)

    it 'deserializes what it previously serialized', ->

        elements = new ElementsCollection()

        foo = elements.addElement('foo')
        foo.completeInitialization(imageWidth: 10, imageHeight: 20)
        bar = elements.addElement('bar')
        bar.completeInitialization(imageWidth: 99, imageHeight: 9)

        foo.automations['x'].addPoint(0, 100)
        foo.automations['x'].addPoint(50, 200)
        bar.automations['y'].addPoint(100, 10)
        bar.automations['width'].addPoint(50, 200)

        serialized = elements.serialize()

        elements2 = new ElementsCollection()        
        elements2.deserialize(serialized)

        serialized2 = elements2.serialize()

        expect(serialized2).toEqual(serialized)
