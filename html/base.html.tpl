{{define "base"}}
<html>
  <head>
    <link rel="stylesheet" href="/css/style.css" />
    <script src="//use.edgefonts.net/londrina-shadow;quicksand.js"></script>
<!--    <link rel="stylesheet" href="/css/elusive-iconfont/css/elusive-webfont.css" /> -->
    <link rel="stylesheet" href="/css/font-awesome/css/font-awesome.min.css" />

    <script src="/js/lib/jquery/jquery.min.js"></script>
    <script src="/js/lib/underscore/underscore-min.js"></script>
    <script src="/js/lib/backbone/backbone-min.js"></script>
    <script src="/js/lib/raphael/raphael-min.js"></script>
    <script src="/js/lib/soundmanager/script/soundmanager2-jsmin.js"></script>
  </head>
  <body>
<!--    <h1>Music Video Animator</h1> -->
    <div id="content">
      {{template "content" .}}
    </div>

    <script src="/js/app/model/elementscollection.js"></script>
    <script src="/js/app/model/automation.js"></script>
    <script src="/js/app/model/element.js"></script>
    <script src="/js/app/model/tree.js"></script>
    <script src="/js/app/model/time.js"></script>
    <script src="/js/app/model/player.js"></script>
    <script src="/js/app/model/zoom.js"></script>
    <script src="/js/app/view/scrubber.js"></script>
    <script src="/js/app/view/player.js"></script>
    <script src="/js/app/view/zoom.js"></script>
    <script src="/js/app/view/elements.js"></script>
    <script src="/js/app/view/element.js"></script>
    <script src="/js/app/view/elementadder.js"></script>
  </body>
</html>
{{end}}
