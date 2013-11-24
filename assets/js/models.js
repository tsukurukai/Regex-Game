define(["backbone"], function(Backbone){
  var Quiz = Backbone.Model.extend({
    defaults: {
      sentence: '',
      targetStartIndex: 0,
      targetLength: 0,
      resolved: false
    },
    urlRoot: '/quizzes',
    test: function(input){
      var that = this;
      var defer = $.ajax({
        scriptCharset: 'utf-8',
        type: "POST",
        url: '/quizzes/'+this.id.$oid+'/test',
        dataType: 'json',
        data: { 'answer' : input }
      }).then(
        function(json){
          var nextQuiz;
          if (json.resolved) {
            that.set("resolved", true);
            nextQuiz = json.nextQuiz;
          } else {
            that.set("resolved", false);
            nextQuiz = null;
          }
          return nextQuiz;
        },
        function(data) {
          this.model.trigger('error');
        }
      );
      return defer.promise();
    }
  });


  var Item = Backbone.Model.extend({
    defaults: { label: "nothing" }
  });

  var ChoiceItems = Backbone.Collection.extend({
    model: Item
  });

  var module = {
    Quiz: Quiz,
    Item: Item,
    ChoiceItems: ChoiceItems
  };
  return module;
});

