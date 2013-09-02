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
        $play = @$('.pause')
        $play.removeClass('pause').addClass('play')
        $play.text('Play')
        
    play: =>
        $play = @$('.play')
        $play.removeClass('play').addClass('pause')
        $play.text('Pause')
        @player.play()
        
    pause: =>
        $play = @$('.pause')
        $play.removeClass('pause').addClass('play')
        $play.text('Play')
        @player.pause()

    togglePlay: =>
        console.log @player.isPlaying()
        if @player.isPlaying()
            @pause()
        else
            @play()

    keyPress: (evt) =>
        tag = evt.target.tagName.toLowerCase()
        if evt.which == 32 and tag != 'input' and tag != 'textarea'
            @togglePlay()
