`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
}`
root = exports ? this

class root.Player extends Backbone.Model

    events:
        'change time': 'timeChanged'

    initialize: ->
        soundManager.onready =>
            @sound = soundManager.createSound
                id: 'player'
                url: DATA.audioURL
                autoLoad: true
                autoPlay: false

    play: =>
        @sound.play(position: time.get('time') * 1000, onfinish: @stop)
        @interval = window.setInterval(@updateTime, 1000 / @get('time').get('fps'))

    pause: =>
        @sound.pause()
        window.clearInterval(@interval)

    stop: =>
        @sound.setPosition(0)
        @updateTime()
        console.log 'stop'
        @trigger('stop')

    updateTime: =>
        @stopListening(@get('time'), 'change')
        @get('time').set('time', @sound.position / 1000)
        @listenTo(@get('time'), 'change', @timeChanged)

    timeChanged: (time) =>
        @sound.setPosition(time.get('time') * 1000)

    isPlaying: =>
        return @sound.playState == 1 and not @sound.paused
