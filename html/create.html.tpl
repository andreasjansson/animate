{{define "content"}}
<script src="/js/app/pages/create.js"></script>

<form id="form">
  <h2>Create new music video</h2>
  <label for="audio-url">Audio URL</label>
  <input name="audio-url" id="audio-url" type="text" />
  <label for="password">Password</label>
  <input name="password" id="password" type="text" />
  <input type="submit" value="Start!" />
</form>

<form id="hidden-form" style="display: none" action="/edit" method="POST">
  <input type="text" name="name" class="name" />
  <input type="text" name="password" class="password" />
  <input type="submit" />
</form>

{{end}}
