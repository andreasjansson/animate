`try { window } catch(e) { // running on node
    _ = require('./../../node_modules/underscore');
    Backbone = require('./../../node_modules/backbone');
    CurrentTime = require('./time').CurrentTime;
}`
root = exports ? this

class root.Player extends Backbone.Model

    initialize: ->
        soundManager.onready =>
            @sound = soundManager.createSound
                id: 'player'
                url: DATA.audioURL
                autoLoad: true
                autoPlay: false

        CurrentTime.on 'change', @timeChanged

    play: =>
        @sound.play(position: CurrentTime.get('time') * 1000, onfinish: @stop)
        @interval = window.setInterval(@updateTime, 1000 / Time.FPS)

    pause: =>
        @sound.pause()
        window.clearInterval(@interval)

    stop: =>
        @sound.setPosition(0)
        @updateTime()
        @trigger('stop')

    updateTime: =>
        CurrentTime.set('time', @sound.position / 1000, fromPlayer: true)

    timeChanged: (time, options) =>
        if not options.fromPlayer
            @sound.setPosition(CurrentTime.get('time') * 1000)

    isPlaying: =>
        return @sound.playState == 1 and not @sound.paused
