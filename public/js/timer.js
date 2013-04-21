var createTimer = function(output, interval){
  var running = false,
      beginTime = null,
      runningTime = 0;
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
  output.html(a.join(''));
  var hour_1 = $('#timer_hour_1');
  var hour_2 = $('#timer_hour_2');
  var minute_1 = $('#timer_minitue_1');
  var minute_2 = $('#timer_minitue_2');
  var second_1 = $('#timer_second_1');
  var second_2 = $('#timer_second_2');
  var millisec_1 = $('#timer_millisec_1');
  var millisec_2 = $('#timer_millisec_2');
  var countup = function() {
    if (!running) return;
    runningTime = runningTime + interval;
    var h = String(Math.floor(runningTime / 3600000) + 100).substring(1);
    var m = String(Math.floor((runningTime - h * 3600000)/60000) + 100).substring(1);
    var s = String(Math.floor((runningTime - h * 3600000 - m * 60000)/1000) + 100).substring(1);
    var ms = String((runningTime - h * 3600000 - m * 60000 - s * 1000) + 1000).substring(1,3);
    hour_1.html(h.substring(0,1));
    hour_2.html(h.substring(1));
    minute_1.html(m.substring(0,1));
    minute_2.html(m.substring(1));
    second_1.html(s.substring(0,1));
    second_2.html(s.substring(1));
    millisec_1.html(ms.substring(0,1));
    millisec_2.html(ms.substring(1));
  };
  setInterval(countup, interval);
  return {
    start: function(){ running = true },
    stop: function(){ running = false },
    reset: function(){
      this.stop();
      beginTime = null;
    },
    runningTime: function(){ return runningTime; }
  };
};

