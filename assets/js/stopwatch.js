var Stopwatch= {
  init: function(interval){
    var running = false,
        beginTime = null,
        runningTime = 0,
        isDisplay = false;
        textContent = function(element, value){
          var content = element.textContent;
          if (content !== undefined) element.textContent = value;
          else element.innerHTML = value;
        },
        display = function(element){
          var a = [];
          a.push('<span class="stopwatch_double">');
          a.push('<span id="stopwatch_hour_1" class="stopwatch_single">0</span>');
          a.push('<span id="stopwatch_hour_2" class="stopwatch_single">0</span>');
          a.push('</span>');
          a.push('<span class="separate">:</span>');
          a.push('<span class="stopwatch_double">');
          a.push('<span id="stopwatch_minitue_1" class="stopwatch_single">0</span>');
          a.push('<span id="stopwatch_minitue_2" class="stopwatch_single">0</span>');
          a.push('</span>');
          a.push('<span class="separate">:</span>');
          a.push('<span class="stopwatch_double">');
          a.push('<span id="stopwatch_second_1" class="stopwatch_single">0</span>');
          a.push('<span id="stopwatch_second_2" class="stopwatch_single">0</span>');
          a.push('</span>');
          a.push('<span class="separate">:</span>');
          a.push('<span class="stopwatch_double">');
          a.push('<span id="stopwatch_millisec_1" class="stopwatch_single">0</span>');
          a.push('<span id="stopwatch_millisec_2" class="stopwatch_single">0</span>');
          a.push('</span>');
          element.innerHTML = a.join('');
          isDisplay = true;
          return this;
        },
        updateDisplay = function(h, m, s, ms){
          textContent(document.getElementById('stopwatch_hour_1'), h.substring(0,1));
          textContent(document.getElementById('stopwatch_hour_2'), h.substring(1));
          textContent(document.getElementById('stopwatch_minitue_1'), m.substring(0,1));
          textContent(document.getElementById('stopwatch_minitue_2'), m.substring(1));
          textContent(document.getElementById('stopwatch_second_1'), s.substring(0,1));
          textContent(document.getElementById('stopwatch_second_2'), s.substring(1));
          textContent(document.getElementById('stopwatch_millisec_1'), ms.substring(0,1));
          textContent(document.getElementById('stopwatch_millisec_2'), ms.substring(1));
        }
        countup = function() {
          if (!running) return;
          runningTime = runningTime + interval;
          var h = String(Math.floor(runningTime / 3600000) + 100).substring(1);
          var m = String(Math.floor((runningTime - h * 3600000)/60000) + 100).substring(1);
          var s = String(Math.floor((runningTime - h * 3600000 - m * 60000)/1000) + 100).substring(1);
          var ms = String((runningTime - h * 3600000 - m * 60000 - s * 1000) + 1000).substring(1,3);
          if (isDisplay) updateDisplay(h, m, s, ms);
        };
    setInterval(countup, interval);
    return {
      start: function(){ running = true },
      stop: function(){ running = false },
      reset: function(){
        this.stop();
        beginTime = null;
      },
      runningTime: function(){ return runningTime; },
      display: display
    };
  }
};

