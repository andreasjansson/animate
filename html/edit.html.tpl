{{define "content"}}

<script src="/js/app/app.js"></script>

<div id="left-panel">
  <a href="#" id="save" class="save icon icon-save" title="Save!"></a>
  <a href="/{{.Name}}" class="preview icon icon-rocket" title="Bounce!"></a>
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

<!--
<div id="zoom">
  <a href="#" class="icon reset" title="Reset zoom!">1:1</a>
  <a href="#" class="icon icon-zoom-out out" title="Zoom out!"></a>
  <a href="#" class="icon icon-zoom-in in" title="Zoom in!"></a>
</div>
-->

<div id="automations">
</div>

<script type="text/template" id="automation-group-template">
  <div class="automation-group">
    <div class="group-backdrop automation">
      <div class="element-title title">
        <a href="#" class="expander expand">
          <img src="<%= url %>" />
        </a>
      </div>
    </div>
  </div>
</script>

<script type="text/template" id="automation-template">
  <div class="automation automation-line <%= attribute %>-attribute">
    <div class="automation-title title">
      <h3><%= attribute %></h3>
    </div>
    <div class="timeline">
    </div>
  </div>
</script>

<script type="text/template" id="automation-point-template">
  <div class="point">
  </div>
</script>

<script type="text/template" id="element-template">
  <div class="element">
    <img src="<%= url %>" />
  </div>
</script>

<script type="text/template" id="float-option-template">
  <label for="option-<%= name %>"><%= name %></label>
  <input type="text" id="option-<%= name %>" value="<%= value %>" />
</script>

<script type="text/template" id="bool-option-template">
  <label for="option-<%= name %>"><%= name %></label>
  <input type="checkbox" id="option-<%= name %>" <% if(value) { %> checked="checked" <% } %> />
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
