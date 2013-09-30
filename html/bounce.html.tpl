{{define "bounce"}}
<html>
  <head>
    <script src="/js/lib/soundmanager/script/soundmanager2-jsmin.js"></script>
    <script src="/js/lib/jquery/jquery.min.js"></script>
    <script type="text/javascript">
        var DATA = {
            name: "{{.Name}}",
            data: {{.Data}},
            audioURL: "{{.AudioURL}}",
            analysis: {{.Analysis}}
        };

        var sound;
        soundManager.setup({
            url: '/js/lib/soundmanager/swf',
            debugMode: false,
        });
        soundManager.onready(function() {
            sound = soundManager.createSound({
                id: 'player',
                url: DATA.url,
                autoLoad: true,
                autoPlay: true,
            });
        });

        $(function() {
            var elements = DATA.data.elements;
            var $screen = $('#{{.Prefix}}-screen');
            var $elements = {};
            for(var i = 0; i < elements.length; i ++) {
                var el = elements[i];
                var $element = $('<img src="' + el.url + '" />');
                $screen.append($element);
                $elements[el.url] = $element;
            }
        });
    </script>
  </head>
  <body>
    <div id="{{.Prefix}}-screen"></div>
  </body>
</html>
{{end}}
