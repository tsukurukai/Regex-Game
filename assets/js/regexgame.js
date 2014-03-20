(function(){
  if (!this.Regexgame) this.Regexgame = {};
  var Regexgame = this.Regexgame;
  Regexgame.Event = _.extend({}, Backbone.Events);

  Regexgame.QuizView = Backbone.View.extend({
    test: function(answer){
      var that = this;
      that.model.test(
        answer
      ).then(function(){
        Regexgame.Event.trigger('answerEnd', that, that.model.get("resolved"));
      });
    },
    template: _.template(
        "<ul>"
      + "<% _.each(list, function(item){ %>"
      + "<li><%- item.pref %><strong><%- item.target %></strong><%- item.suff %></li>"
      + "<% }); %>"
      + "</ul>"
    ),
    render: function(){
      var items = this.model.get('items');
      var params = _.map(items, function(item){
        var sentence = item.sentence,
            targetStartIndex = item.target_start_index,
            targetEndIndex = targetStartIndex + item.target_length,
            pref = sentence.substring(0, targetStartIndex),
            target = sentence.substring(targetStartIndex, targetEndIndex),
            suff = sentence.substring(targetEndIndex);
        return {
          'pref': pref,
          'target': target,
          'suff': suff
        }
      });
      this.$el.html(this.template({ list: params }));
      return this;
    }
  });

  Regexgame.ChoiceItemView = Backbone.View.extend({
    tagName: 'span',
    className: 'answer_item',
    events: { 'click': 'select' },
    select: function(){
      Regexgame.Event.trigger('selectChoiceItem', this.model);
    },
    template: _.template("<%- label %>"),
    render: function(){
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    }
  });

  Regexgame.ChoiceItemsView = Backbone.View.extend({
    el: '#choice_items',
    render: function(){
      var that = this;
      this.collection.each(function(item){
        var choiceItemView = new Regexgame.ChoiceItemView({model: item}),
            elem = choiceItemView.render().$el;
        that.$el.append(elem.get(0));
      }, this);
      return this;
    }
  });

  Regexgame.AnswerView = Backbone.View.extend({
    el: '#answer_form',
    input: '#answer_in_box',
    events: {
      'click #reg_submit': 'onSubmit'
    },
    onSubmit: function(){
      Regexgame.Event.trigger('answerStart', this.$(this.input).val());
    },
    addVal: function(selectedItem) {
      var input = this.$(this.input);
      input.val(input.val() + selectedItem.get("label"));
    },
    renderAnswerResult: function(view, resolved){
      if (resolved) {
        var input = this.$(this.input);
        input.val('');
        input.focus();
      } else {
        this.$(this.input).effect('shake', '', 300);
      }
    }
  });

  Regexgame.AppView = Backbone.View.extend({
    quizCount: 0,
    stopwatch: Stopwatch.init(10).display(document.getElementById('stopwatch')),
    choiceItemsView: null,
    answerView: null,
    quizView: null,
    initialize: function(){
      var that = this,
          choiceItems = new Regexgame.ChoiceItems([
            { label: '[' }
           ,{ label: ']' }
           ,{ label: '(' }
           ,{ label: ')' }
           ,{ label: '{' }
           ,{ label: '}' }
           ,{ label: ',' }
           ,{ label: '|' }
           ,{ label: '\\' }
           ,{ label: '.' }
           ,{ label: '?' }
           ,{ label: '\\w' }
           ,{ label: '\\W' }
           ,{ label: '\\s' }
           ,{ label: '\\S' }
           ,{ label: '\\d' }
           ,{ label: '\\D' }
           ,{ label: 'a-z' }
           ,{ label: '0-9' }
           ,{ label: 'A-Z' }
           ,{ label: '*' }
           ,{ label: '+' }
          ]);
      choiceItemsView = new Regexgame.ChoiceItemsView({collection: choiceItems});
      answerView = new Regexgame.AnswerView();

      $('#dialog').dialog({
        autoOpen: false,
        modal: true,
        draggable: false,
        resizable: false,
        close: function( event, ui ) {
          that.stopwatch.start();
          that.setEnterButton(1);
          that.render();
        },
        buttons: [{
          text: "OK",
          click: function(){
            that.closeDialog();
          }
        }]
      });

      $('#reg_submit').button();

      answerView.listenTo(Regexgame.Event, 'selectChoiceItem', answerView.addVal);
      answerView.listenTo(Regexgame.Event, 'answerEnd',        answerView.renderAnswerResult);

      that.listenTo(Regexgame.Event, 'answerStart', function(){
        that.stopwatch.stop();
      });
      that.listenTo(Regexgame.Event, 'answerEnd', that.handleAnswerEnd);

      choiceItemsView.render();
      answerView.render();

      that.nextQuiz().done(function(){ that.render(); });
      that.stopwatch.start();
      that.setEnterButton(1);
    },
    closeDialog: function(){
      $('#dialog').dialog("close");
    },
    setEnterButton: function(type){
      var that = this;
      $(window).unbind('keypress');
      if (type === 1) {
        $(window).keypress(function(ev){
          if((ev.which && ev.which === 13) || (ev.keyCode && ev.keyCode === 13)) {
            $('#reg_submit').click();
            return false;
          }
        });
      } else {
        $(window).keypress(function(ev){
          if((ev.which && ev.which === 13) || (ev.keyCode && ev.keyCode === 13)) {
            that.closeDialog();
            return false;
          }
        });
      }
    },
    nextQuiz: function(){
      var that = this,
          defer = $.ajax({
            scriptCharset: 'utf-8',
            type: "GET",
            url: '/quizzes/random',
            dataType: 'json'
          });
      defer.done(function(json){
        var quiz = new Regexgame.Quiz(json);
        quizView = new Regexgame.QuizView({model: quiz});
        that.quizCount = that.quizCount + 1;
        quizView.listenTo(Regexgame.Event, 'answerStart', quizView.test);
      }).fail(function(data) {
        // TODO
        alert('ERRER');
      });
      return defer.promise();
    },
    handleAnswerEnd: function(quizView, resolved){
      if (resolved) {
        quizView.remove();
        if (this.quizCount === 5) this.renderComplete();
        else {
          this.nextQuiz();
          this.setEnterButton(2);
          $('#dialog').dialog('option', 'title', "Let's NextQuiz")
                      .dialog("open");
        }
      } else {
        this.stopwatch.start();
      }
    },
    render: function(){
      $('#qnumber').html('Q'+this.quizCount);
      $('#quiz').html(quizView.render().el);
      return this;
    },
    renderComplete: function(){
      var nextUrl = location.href + '/result/input?time='+encodeURIComponent(this.stopwatch.runningTime());
      this.setEnterButton(2);
      $('#dialog').dialog('option', 'title', 'ALL Quiz is Complete!!')
                  .dialog('option', 'close', function(){
                    location.href = nextUrl;
                  })
                  .dialog('open');
    }
  });

  Regexgame.init = function(){
    new Regexgame.AppView();
  };
}());

