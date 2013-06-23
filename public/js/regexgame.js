(function(){
$(function(){
  var Quiz = Backbone.Model.extend({
    urlRoot: location.href+'/q/',
    parse: function(json){
      var self = this;
      var f = function(label){ return self.createWord(label, false) };
      return {
        isFinish: json.isFinish,
        matchWords: _.map(json.quiz.matches, f),
        notMatchWords: _.map(json.quiz.unmatches, f)
      };
    },
    createWord: function(label, solved){
      return { 'label': label, 'solved': solved };
    },
    test: function(input){
      var self = this;
      var defer = $.ajax({
        scriptCharset: 'utf-8',
        type: "POST",
        url: location.href+'/q/'+this.id+'/answer',
        dataType: 'json',
        data: { 'answer' : input }
      }).done(function(json){
        self.changeWordsState(json.ok_match, json.ok_unmatch);
      }).fail(function(data) {
        self.trigger('error');
      });
      return defer.promise();
    },
    changeWordsState: function(solvedMatchWords, solvedNotMatchWords){
      var self = this;
      var testedMatchWords = _.map(this.get('matchWords'), function(word){
        return self.createWord( word.label, _.contains(solvedMatchWords, word.label) );
      });
      var testedNotMatchWords = _.map(this.get('notMatchWords'), function(word){
        return self.createWord( word.label, (_.contains(solvedNotMatchWords, word.label)) );
      });
      this.set({matchWords: testedMatchWords, notMatchWords: testedNotMatchWords});
    },
    isAllOk: function(){
      var isMatchWordsOk = _.every(this.get('matchWords'), function(word){ return word.solved });
      var isNotMatchWordsOk = _.every(this.get('notMatchWords'), function(word){ return word.solved });
      return isMatchWordsOk && isNotMatchWordsOk;
    }
  });

  var QuizView = Backbone.View.extend({
    el: '#quiz',
    initialize: function(){
      this.listenTo(this.model, 'change', this.render);
      this.listenTo(this.model, 'remove', this.remove);
    },
    template: _.template("<% _.each(items, function(item){ %>"
                        +  "<li class='<%= item.solved ? 'ok' : 'ng' %>'><%- item.label %><li>"
                        +"<% }) %>"),
    render: function(){
      if (!this.model.get('isFinish')) {
        $('#match_list').empty();
        $('#match_list').append(this.template( {items: this.model.get('matchWords')} ));
        $('#not_match_list').empty();
        $('#not_match_list').append(this.template( {items: this.model.get('notMatchWords')} ));
      }
      return this;
    }
  });

  var AppView = Backbone.View.extend({
    el: '#quizapp',
    events: {
      'click #reg_submit': 'onSubmit'
    },
    input: $('#reg_input'),
    timer: createTimer($('#timer'), 10),
    initialize: function(){
      this.listenTo(this.model, 'sync', this.render);
      this.listenTo(this.model, 'change', this.allOkAlert);
      this.listenTo(this.model, 'error', this.serverErrorAlert);
    },
    onSubmit: function(){
      this.timer.stop();
      var self = this;
      this.model.test(
        this.input.val()
      ).then(function(){
        if(self.model.isAllOk()){
          var next = self.model.id + 1;
          self.model.id = next;
          self.model.fetch();
        } else {
          self.timer.start();
        }
      });
    },
    allOkAlert: function(){
      if(this.model.isAllOk()) alert('ALL OK!!');
    },
    serverErrorAlert: function(){
      alert("Server Error.");
    },
    render: function(){
      if (this.model.get('isFinish')) {
        alert('ALL Quiz is Complete!!');
        location.href = location.href + '/result/input?time='+encodeURIComponent(this.timer.runningTime());
      } else {
        $('#qnumber').html('Q'+this.model.id);
        this.input.val('');
        this.input.focus();
        if (this.model.id > 1) {
          alert("Let's Next Quiz");
        }
        this.timer.start();
      }
    }
  });

  $(window).keypress(function(ev){
    if((ev.which && ev.which === 13) || (ev.keyCode && ev.keyCode === 13)) {
      $('#reg_submit').click();
      return false;
    }
  });

  var quiz = new Quiz();
  var quizView = new QuizView({model: quiz});
  var app = new AppView({model: quiz});
  quiz.id = 1;
  quiz.fetch();

});
}());

