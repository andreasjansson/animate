{{define "content"}}

<script src="/js/app/app.js"></script>

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
  <div id="zoom" class="panel">
    <h2>Zoom</h2>
    <a href="#" class="reset">reset</a>
    <a href="#" class="out">out</a>
    <a href="#" class="in">in</a>
  </div>
</div>

<div id="play-controls">
  <a class="play" href="#">Play</a>
</div>
<div id="scrubber">
</div>

<script>
    var DATA = {
        name: "{{.Name}}",
        data: "{{.Data}}",
        audioURL: "{{.AudioURL}}",
        analysis: {{.Analysis}}
    };

    soundManager.setup({
        url: '/js/lib/soundmanager/swf'
    })
    
</script>

{{end}}
