var createTimer = function(interval){
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
        a.push('<span class="timer_double">');
        a.push('<span id="timer_hour_1" class="timer_single">0</span>');
        a.push('<span id="timer_hour_2" class="timer_single">0</span>');
        a.push('</span>');
        a.push('<span class="separate">:</span>');
        a.push('<span class="timer_double">');
        a.push('<span id="timer_minitue_1" class="timer_single">0</span>');
        a.push('<span id="timer_minitue_2" class="timer_single">0</span>');
        a.push('</span>');
        a.push('<span class="separate">:</span>');
        a.push('<span class="timer_double">');
        a.push('<span id="timer_second_1" class="timer_single">0</span>');
        a.push('<span id="timer_second_2" class="timer_single">0</span>');
        a.push('</span>');
        a.push('<span class="separate">:</span>');
        a.push('<span class="timer_double">');
        a.push('<span id="timer_millisec_1" class="timer_single">0</span>');
        a.push('<span id="timer_millisec_2" class="timer_single">0</span>');
        a.push('</span>');
        element.innerHTML = a.join('');
        isDisplay = true;
        return this;
      },
      updateDisplay = function(h, m, s, ms){
        var hour_1 = document.getElementById('timer_hour_1');
        var hour_2 = document.getElementById('timer_hour_2');
        var minute_1 = document.getElementById('timer_minitue_1');
        var minute_2 = document.getElementById('timer_minitue_2');
        var second_1 = document.getElementById('timer_second_1');
        var second_2 = document.getElementById('timer_second_2');
        var millisec_1 = document.getElementById('timer_millisec_1');
        var millisec_2 = document.getElementById('timer_millisec_2');
        textContent(hour_1, h.substring(0,1));
        textContent(hour_2, h.substring(1));
        textContent(hour_2, h.substring(1));
        textContent(minute_1, m.substring(0,1));
        textContent(minute_2, m.substring(1));
        textContent(second_1, s.substring(0,1));
        textContent(second_2, s.substring(1));
        textContent(millisec_1, ms.substring(0,1));
        textContent(millisec_2, ms.substring(1));
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
};

