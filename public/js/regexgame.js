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
        load = function(quizId){
          var defer = $.Deferred();
          $.ajax({
            scriptCharset: 'utf-8',
            type: "GET",
            url: location.href+'/q/'+quizId,
            dataType: 'json',
            data: {}
          }).done(function(json) {
            if (!json.isFinish) {
              $('#match_list').empty();
              $('#not_match_list').empty();
              $('#reg_input').val('');
              $.each(json.quiz.matches, function(){ $('#match_list').append('<li>'+this+'</li>') });
              $.each(json.quiz.unmatches, function(){ $('#not_match_list').append('<li>'+this+'</li>') });
              match_list = $('#match_list li');
              not_match_list = $('#not_match_list li');
              qid = quizId;
              $('#qnumber').html('Q'+quizId);
            }
            defer.resolve(json.isFinish);
          }).fail(function(data){
            alert("Internal Serve Error.")
          });
          return defer.promise();
        };
    load(1);
    return {
      next: function(loadFunc, finishFunc) {
        this.clear();
        return load(qid+1);
      },
      clear: function(){
        match_list.each(function(){ ng(this) });
        not_match_list.each(function(){ ng(this) });
      },
      test: function(input){
        var ok_match_words = [],
            ok_not_match_words = [],
            defer = $.Deferred();
        this.clear();
        $.ajax({
          scriptCharset: 'utf-8',
          type: "POST",
          url: location.href+'/q/'+qid+'/answer',
          dataType: 'json',
          data: { 'answer' : input }
        }).done(function(json){
          match_list.each(function(){
            if( $.inArray($(this).html(), json.ok_match) !== -1 ) ok(this)
          });
          not_match_list.each(function(){
            if( $.inArray($(this).html(), json.ok_unmatch) !== -1 ) ok(this)
          });
          if(isAllOk()) defer.resolve();
          else          defer.reject();
        }).fail(function(data) {
          alert("Internal Serve Error.");
        });
        return defer.promise();
      }
    };
  };
  var question = createQuestion();

  var timer = createTimer($('#timer'), 10);

  $(window).keypress(function(ev){
    if((ev.which && ev.which === 13) || (ev.keyCode && ev.keyCode === 13)) {
      $('#reg_submit').click();
      return false;
    }
  });

  $('#reg_submit').click(function(){
    timer.stop();
    question.test(
      $('#reg_input').val()
    ).then(
      function(){
        alert('ALL OK!!');
        return question.next();
      },
      function(){
        timer.start();
      }
    ).then(
      function(isFinish) {
        if (isFinish) {
          alert('ALL Quiz is Complete!!');
          location.href = location.href + '/result/input?time='+encodeURIComponent(timer.runningTime());
        } else {
          alert("Let's Next Quiz");
          timer.start();
        }
      }
    );
  });

  question.clear();
  $('#reg_input').focus();
  timer.start();
});
}());

