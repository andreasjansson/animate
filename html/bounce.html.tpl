{{define "bounce"}}
<html>
  <head>
    <style>
    body {
        background-color: #888;
    }

    #{{.Prefix}}-wrapper {
        overflow: hidden;
        border: 5px solid black;
        width: 700px;
        height: 393px;
    }

    #{{.Prefix}}-screen {
        width: 700px;
        height: 393px;
        background-color: white;
        position: relative;
    }

    #{{.Prefix}}-screen img {
        display: block;
        position: absolute;
    }
    </style>
    <script src="/js/lib/soundmanager/script/soundmanager2-jsmin.js"></script>
    <script src="/js/lib/jquery/jquery.min.js"></script>
    <!-- TODO: no jquery dependency -->
    <script type="text/javascript">

        var FPS = 20;

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
//                url: DATA.audioURL,
                url: '/static/mhajfoqc.mp3',                
                autoLoad: true,
                autoPlay: true,
            });

            window.setInterval(update, 1000 / FPS);
        });

        var elements, $screen, $elements, positions;
        $(function() {
            elements = DATA.data.elements;
            $screen = $('#{{.Prefix}}-screen');
            $elements = [];
            positions = [];
            for(var i = 0; i < elements.length; i ++) {
                var element = elements[i];
                var $element = $('<img class="c' + i + '" src="' + element.url + '" />');
                $screen.append($element);
                $elements[i] = $element;
                positions[i] = {};
                for(var p in element.automations) {
                    positions[i][p] = 0;
                }
            }
        });

        function update() {
            if(!$elements)
                return;

            var time = sound.position / 1000;

            for(var i = 0; i < elements.length; i ++) {
                var element = elements[i];
                var automations = element.automations;

                for(var property in automations) {
                    var position = positions[i][property];
                    var point = automations[property].points[position];
                    var nextPoint = automations[property].points[positions[i][property] + 1];
                    var value;
                    if(!nextPoint || !point.interpolate) {
                        value = point.value;
                    }
                    else {
                        value = interpolate(point.time, point.value, nextPoint.time, nextPoint.value, time);
                    }

                    if(nextPoint && time >= nextPoint.time) {
                        positions[i][property] ++;
                    }

                    render($elements[i], property, value);
                }
            }
        }

        function interpolate(beforeTime, beforeValue, afterTime, afterValue, time) {
            var factor = (time - beforeTime) / (afterTime - beforeTime);
            var value = (afterValue - beforeValue) * factor + beforeValue;
            return value;
        };

        function render($el, property, value) {
            if(property == 'x') {
                $el.css('margin-left', value);
            }
            if(property == 'y') {
                $el.css('margin-top', value);
            }
            if(property == 'width') {
                $el.css('width', value);
                $el.css('left', -value / 2);
            }
            if(property == 'height') {
                $el.css('height', value);
                $el.css('top', -value / 2);
            }
            if(property == 'opacity') {
                $el.css('opacity', value);
            }
            if(property == 'rotation') {
                var rotation = value;
                var rotateString = 'rotate(#{rotation}deg)';
                $el.css('-webkit-transform', rotateString);
                $el.css('-moz-transform', rotateString);
                $el.css('-ms-transform', rotateString);
                $el.css('-o-transform', rotateString);
            }
            if(property == 'zIndex') {
                $el.css('z-index', value);
            }
            if(property == 'url') {
                $el.attr('src', url);
	    }
        }
    </script>
  </head>
  <body>
    <div id="{{.Prefix}}-wrapper">
      <div id="{{.Prefix}}-screen"></div>
    </div>
  </body>
</html>
{{end}}
