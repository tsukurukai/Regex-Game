(function(){
$(function(){
  var question = function(){
    var match_list = $('#match_list li'),
        not_match_list = $('#not_match_list li'),
        ok = function(elm){
          $(elm).addClass('ok');
          $(elm).removeClass('ng');
        },
        ng = function(elm){
          $(elm).removeClass('ok');
          $(elm).addClass('ng');
        };
    return {
      clear: function(){
          match_list.each(function(){ ng(this) });
          not_match_list.each(function(){ ng(this) });
      },
      test: function(input){
        this.clear();
        if (input && input !== '') {
          var re = new RegExp(input);
          match_list.each(function(){
            if(this.innerText && re.test(this.innerText)) ok(this);
          });
          not_match_list.each(function(){
            if(this.innerText && !(re.test(this.innerText))) ok(this);
          });
        }
      },
      isAllOk: function(){
        var result = true;
        match_list.each(function(){
          if($(this).attr('class').split(' ').indexOf('ok') === -1){
            result = false;
          }
        });
        return result;
      }
    };
  }();

  var timer = function(output, interval){
    var running = false,
        beginTime = null,
        runningTime = 0,
        countup = function() {
          if (!running) return;
          runningTime = runningTime + interval;
          var h = String(Math.floor(runningTime / 3600000) + 100).substring(1);
          var m = String(Math.floor((runningTime - h * 3600000)/60000) + 100).substring(1);
          var s = String(Math.floor((runningTime - h * 3600000 - m * 60000)/1000) + 100).substring(1);
          var ms = String((runningTime - h * 3600000 - m * 60000 - s * 1000) + 1000).substring(1,3);
          output.html(h+':'+m+':'+s+':'+ms);
        };
    setInterval(countup, interval);
    return {
      start: function(){ running = true },
      stop: function(){ running = false },
      reset: function(){
        this.stop();
        beginTime = null;
      }
    };
  }($('#timer'), 10);

  $(window).keypress(function(ev){
    if((ev.which && ev.which === 13) || (ev.keyCode && ev.keyCode === 13)) {
      $('#reg_submit').click();
      return false;
    }
  });

  $('#reg_submit').click(function(){
    timer.stop();
    question.test($('#reg_input').val());
    if (question.isAllOk()) {
      alert('ALL OK!!');
    } else {
      timer.start();
    }
  });

  question.clear();
  $('#reg_input').focus();
  timer.start();
});
}());

