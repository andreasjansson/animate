{{define "base"}}
<html>
  <head>
    <script src="//use.edgefonts.net/londrina-shadow;quicksand.js"></script>
    <script src="/js/lib/jquery/jquery.min.js"></script>
    <script src="/js/lib/underscore/underscore-min.js"></script>
    <script src="/js/lib/backbone/backbone-min.js"></script>
    <script src="/js/lib/raphael/raphael-min.js"></script>
    <script src="/js/app/model/automation.js"></script>
    <script src="/js/app/model/element.js"></script>
    <script src="/js/app/model/tree.js"></script>
    <script src="/js/app/model/time.js"></script>
    <script src="/js/app/view/scrubber.js"></script>
    <script src="/js/app/app.js"></script>
    <link rel="stylesheet" href="/css/style.css" />
  </head>
  <body>
<!--    <h1>Music Video Animator</h1> -->
    <div id="content">
      {{template "content" .}}
    </div>
  </body>
</html>
{{end}}
