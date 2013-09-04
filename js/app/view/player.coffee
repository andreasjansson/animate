root = exports ? this

class root.PlayerView extends Backbone.View

    el: '#play-controls'

    events:
        'click .play': 'play'
        'click .pause': 'pause'

    initialize: ->
        @player = @options['player']
        @player.on('stop', @stop)
        $(document).on('keypress', @keyPress)
        
    stop: =>
        @$('.pause').hide()
        @$('.play').show()
        
    play: =>
        @$('.play').hide()
        @$('.pause').show()
        @player.play()
        return false
        
    pause: =>
        @$('.pause').hide()
        @$('.play').show()
        @player.pause()
        return false

    togglePlay: =>

        if @player.isPlaying()
            @pause()
        else
            @play()

    keyPress: (evt) =>
        tag = evt.target.tagName.toLowerCase()
        if evt.which == 32 and tag != 'input' and tag != 'textarea'
            @togglePlay()
