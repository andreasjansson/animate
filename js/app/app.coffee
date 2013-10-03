$ ->

    window.zoom = new Zoom()
    window.zoomView = new ZoomView(zoom: zoom)
    window.scrubber = new ScrubberView(zoom: window.zoom)
    window.player = new Player()
    window.playerView = new PlayerView(player: window.player)
    window.elements = new ElementsCollection()
    window.elementsView = new ElementsView(elements: window.elements)
    window.automationsView = new AutomationsView(elements: window.elements, zoom: window.zoom)
    window.elementAdderView = new ElementAdderView(elements: window.elements)
    window.saveView = new SaveView(elements: elements)
    window.bounceView = new BounceView(elements: elements)

    if DATA.data.elements
        window.elements.deserialize(DATA.data.elements)
