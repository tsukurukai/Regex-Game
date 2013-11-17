require(["backbone", "models", "stopwatch"], function(Backbone, models, Stopwatch){
  var QuizView = Backbone.View.extend({
    el: '#quiz',
    initialize: function(options){
      this.listenTo(this.model, 'sync', this.render);
      this.listenTo(this.model, 'change', this.render);
    },
    template: _.template("<%- pref %><strong><%- target %></strong><%- suff %>"),
    render: function(){
      var sentence = this.model.get("sentence");
      var targetStartIndex = this.model.get("targetStartIndex");
      var targetEndIndex = this.model.get("targetStartIndex") + this.model.get("targetLength");
      var pref = sentence.substring(0, targetStartIndex);
      var target = sentence.substring(targetStartIndex, targetEndIndex);
      var suff = sentence.substring(targetEndIndex);
      this.$el.html(this.template({
        'pref': pref,
        'target': target,
        'suff': suff
      }));
      return this;
    }
  });

  var ChoiceItemView = Backbone.View.extend({
    tagName: 'span',
    className: 'answer_item',
    events: { 'click': 'select' },
    select: function(){
      this.model.trigger('select', this.model);
    },
    template: _.template("<%- label %>"),
    render: function(){
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    }
  });

  var ChoiceItemsView = Backbone.View.extend({
    el: '#choice_items',
    render: function(){
      this.collection.each(function(item){
        var choiceItemView =
          new ChoiceItemView({ model: item });
        var elem = choiceItemView.render().$el;
        this.$el.append(elem.get(0));
      }, this);
      return this;
    }
  });


  var AppView = Backbone.View.extend({
    el: '#quizapp',
    events: {
      'click #reg_submit': 'onSubmit'
    },
    input: $('#answer_in_box'),
    stopwatch: Stopwatch.init(10).display(document.getElementById('stopwatch')),
    initialize: function(){
      this.listenTo(this.model, 'sync', this.render);
      this.listenTo(this.model, 'error', this.serverErrorAlert);
    },
    addInputVal: function(selectedItem) {
      var s = this.input.val();
      this.input.val(s + selectedItem.get("label"));
    },
    onSubmit: function(){
      this.stopwatch.stop();
      var self = this;
      this.model.test(
        this.input.val()
      ).then(function(){
        if(self.model.get('resolved')){
          var next = self.model.id + 1;
          self.model.id = next;
          self.model.fetch();
        } else {
          self.stopwatch.start();
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
      if (this.model.get('resolved')) {
        alert('ALL Quiz is Complete!!');
        location.href = location.href + '/result/input?time='+encodeURIComponent(this.stopwatch.runningTime());
      } else {
        //$('#qnumber').html('Q'+this.model.id);
        //this.input.val('');
        //this.input.focus();
        //if (this.model.id > 1) {
        //  alert("Let's Next Quiz");
        //}
        this.stopwatch.start();
      }
      return this;
    }
  });

  $(window).keypress(function(ev){
    if((ev.which && ev.which === 13) || (ev.keyCode && ev.keyCode === 13)) {
      $('#reg_submit').click();
      return false;
    }
  });

  var choiceItems = new models.ChoiceItems([
    { label: '[' }
   ,{ label: ']' }
   ,{ label: '(' }
   ,{ label: ')' }
   ,{ label: '|' }
   ,{ label: '.' }
   ,{ label: '\\w' }
   ,{ label: '\\d' }
   ,{ label: 'a-z' }
   ,{ label: '0-9' }
   ,{ label: 'A-Z' }
   ,{ label: '*' }
   ,{ label: '+' }
   ,{ label: 'Banana' }
   ,{ label: 'Apple' }
   ,{ label: 'Tiger' }
   ,{ label: 'Cat' }
  ]);

  var choiceItemsView = new ChoiceItemsView({collection: choiceItems});

  var quiz = new models.Quiz();
  quiz.id = $('#firstQuizId').val();
  var quizView = new QuizView({model: quiz});
  var appView = new AppView({model: quiz});

  var mediator = _.extend({}, Backbone.Events);
  choiceItems.each(function(choiceItem){
    mediator.listenTo(choiceItem, 'select', _.bind(appView.addInputVal, appView));
  });

  quiz.fetch();
  choiceItemsView.render();
});

