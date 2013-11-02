define(["backbone"], function(Backbone){
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


  var Item = Backbone.Model.extend({
    defaults: { label: "nothing" }
  });

  var ChoiceItems = Backbone.Collection.extend({
    model: Item
  });

  var AnsweredItems = Backbone.Collection.extend({
    model: Item,
  });

  var module = {
    Quiz: Quiz,
    Item: Item,
    ChoiceItems: ChoiceItems,
    AnsweredItems: AnsweredItems
  };
  return module;
});

