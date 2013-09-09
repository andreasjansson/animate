{{define "content"}}

<script src="/js/app/app.js"></script>

<div id="left-panel">
  <a href="#" id="save" class="save icon icon-save" title="Save!"></a>
  <a href="#" class="preview icon icon-rocket" title="Bounce!"></a>
</div>

<div id="screen">
</div>

<div id="right-panel">
  <h1>Music Video Animator Pro</h1>
  <div id="add-element" class="panel">
    <h2>Add an image</h2>
    <form>
      <input type="text" class="url text" value="http://localhost:8888/static/frognotes.gif" />
    </form>
  </div>
  <div id="options" class="panel">
    <h2>Options</h2>
    <form class="background-color">
      <label for="bg-color-input">Background</label>
      <input id="bg-color-input" type="text" class="text" value="#FFFFFF" />
    </form>
  </div>
</div>

<div id="play-controls">
  <a class="icon icon-play play" href="#" title="Play!"></a>
  <a class="icon icon-pause pause" href="#" title="Pause!" style="display: none"></a>
</div>
<div id="scrubber">
</div>

<div id="zoom">
  <a href="#" class="icon reset" title="Reset zoom!">1:1</a>
  <a href="#" class="icon icon-zoom-out out" title="Zoom out!"></a>
  <a href="#" class="icon icon-zoom-in in" title="Zoom in!"></a>
</div>

<div id="automations">
</div>

<script type="text/template" id="automation-group-template">
  <div class="automation-group">
    <div class="group-backdrop automation">
      <div class="element-title title">
        <img src="<%= url %>" />
      </div>
      <div class="timeline">
      </div>
    </div>
  </div>
</script>

<script type="text/template" id="automation-template">
  <div class="automation">
    <div class="automation-title title">
      <h3><%= name %></h3>
    </div>
    <div class="timeline">
    </div>
  </div>
</script>

<script type="text/template" id="automation-point-template">
  <div class="automation-point">
  </div>
</script>

<script type="text/template" id="element-template">
  <div class="element">
    <img src="<%= url %>" />
  </div>
</script>

<script>
    var DATA = {
        name: "{{.Name}}",
        data: {{.Data}},
        audioURL: "{{.AudioURL}}",
        analysis: {{.Analysis}}
    };

    soundManager.setup({
        url: '/js/lib/soundmanager/swf',
        debugMode: false,
    })

</script>

{{end}}
