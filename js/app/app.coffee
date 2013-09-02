$ ->

    window.time = new Time()
    window.zoom = new Zoom()
    window.zoomView = new ZoomView(zoom: zoom)
    window.scrubber = new ScrubberView(time: window.time, zoom: window.zoom)
    window.player = new Player(time: window.time)
    window.playerView = new PlayerView(player: window.player)
