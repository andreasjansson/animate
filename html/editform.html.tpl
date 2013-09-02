{{define "content"}}

{{if .Name}}
<p class="message">Please authenticate to edit this video</p>
{{end}}

<form action="/edit" method="post">
  <label for="name">Name</label>
  <input id="name" name="name" type="text" value="{{.Name}}" />
  <br />
  <label for="password">Password</label>
  <input id="password" name="password" type="password" />
  <br />
  <input type="submit" name="submit" value="Edit!" />
</form>

{{end}}
