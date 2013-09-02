{{define "content"}}

<script src="/js/app/app.js"></script>

<div id="left-panel">
  <a href="#" class="save icon icon-save" title="Save!"></a>
  <a href="#" class="preview icon icon-rocket" title="Bounce!"></a>
</div>

<div id="screen">
</div>

<div id="right-panel">
  <h1>Music Video Animator Pro</h1>
  <div id="add-element" class="panel">
    <h2>Add an image</h2>
    <form>
      <input type="text" class="url text" />
      <button class="icon icon-plus" href="#" title="Add it!" />
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
