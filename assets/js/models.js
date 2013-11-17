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
      var self = this;
      var defer = $.ajax({
        scriptCharset: 'utf-8',
        type: "POST",
        url: location.href+'/q/'+this.id+'/answer',
        dataType: 'json',
        data: { 'answer' : input }
      }).done(function(json){
        if (json.result) self.set("resolved", true);
      }).fail(function(data) {
        self.trigger('error');
      });
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

