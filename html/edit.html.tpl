{{define "content"}}

<div id="screen">
</div>

<div id="side-panel">
  <h1>Music Video Animator Pro</h1>
  <div id="add-element" class="panel">
    <h2>Add an object</h2>
    <input type="text" id="element-url" />
    <a class="button" href="#">Add it!</a>
  </div>
  <div id="options" class="panel">
    <h2>Options</h2>
  </div>
</div>

<div id="srubber-panel">
  <div id="zoom">
    <a class="button" href="#" id="play">Play</a>
    <a class="button" title="Zoom out" href="#">-</a>
    <a class="button" title="Zoom in" href="#">+</a>
  </div>
  <div id="scrubber">
  </div>
</div>

<script>
    var DATA = {
        name: "{{.Name}}",
        data: "{{.Data}}",
        audioURL: "{{.AudioURL}}",
        analysis: {{.Analysis}}
    };
</script>

{{end}}
