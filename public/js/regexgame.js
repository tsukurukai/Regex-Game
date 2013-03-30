(function(){
$(function(){
  var createQuestion = function(){
    var match_list = $([]),
        not_match_list = $([]),
        qid = 1,
        ok = function(elm){
          $(elm).addClass('ok');
          $(elm).removeClass('ng');
        },
        ng = function(elm){
          $(elm).removeClass('ok');
          $(elm).addClass('ng');
        },
        isAllOk = function(){
          var result = true;
          match_list.each(function(){
            if($(this).attr('class').split(' ').indexOf('ok') === -1) {
              result = false;
            }
          });
          return result;
        },
        load = function(quizId, loadFunc, finishFunc){
          $.ajax({
            scriptCharset: 'utf-8',
            type: "GET",
            url: location.href+'/q/'+quizId,
            data: {},
            success: function(json) {
              console.log(json);
              if (json.isFinish) {
                finishFunc();
              } else {
                $('#match_list').empty();
                $('#not_match_list').empty();
                $('#reg_input').val('');
                $.each(json.quiz.matches, function(){ $('#match_list').append('<li>'+this+'</li>') });
                $.each(json.quiz.unmatches, function(){ $('#not_match_list').append('<li>'+this+'</li>') });
                match_list = $('#match_list li');
                not_match_list = $('#not_match_list li');
                qid = quizId;
                $('#qnumber').html('Q'+quizId);
                if (loadFunc) loadFunc();
              }
            },
            error: function(request, status, e){ alert("Internal Serve Error.") },
            dataType: 'json'
          });
        };
    load(1);
    return {
      next: function(loadFunc, finishFunc) {
        this.clear();
        load(qid+1, loadFunc, finishFunc);
      },
      clear: function(){
          match_list.each(function(){ ng(this) });
          not_match_list.each(function(){ ng(this) });
      },
      test: function(input, allOkFunc, notAllOkFunc){
        var ok_match_words = [],
            ok_not_match_words = [];
        this.clear();
        $.ajax({
          scriptCharset: 'utf-8',
          type: "POST",
          url: location.href+'/q/'+qid+'/answer',
          data: { 'answer' : input },
          success: function(json) {
            console.log(json);
            match_list.each(function(){
              if($.inArray($(this).html(), json.ok_match) !== -1) ok(this);
            });
            not_match_list.each(function(){
              if($.inArray($(this).html(), json.ok_unmatch) !== -1) ok(this);
            });
            if(isAllOk()) allOkFunc();
            else          notAllOkFunc();
          },
          error: function(request, status, e) { alert("Internal Serve Error.") },
          dataType: 'json'
        });
      }
    };
  };
  var question = createQuestion();

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
      },
      runningTime: function(){ return runningTime; }
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
    question.test($('#reg_input').val(), function(){
      alert('ALL OK!!');
      question.next(function(){
        alert("Let's Next Quiz");
        timer.start();
      },function(){
        alert('ALL Quiz is Complete!!');
        $('#answer_form').append('<input type="hidden" name="time" value="'+timer.runningTime()+'" />');
        $('#answer_form').submit();
      });
    },
    function(){
      timer.start();
    });
  });

  question.clear();
  $('#reg_input').focus();
  timer.start();
});
}());

