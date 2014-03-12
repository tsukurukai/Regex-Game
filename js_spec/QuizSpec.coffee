define ["models"], (models) ->
  describe "Quiz", () ->
    it "should has urlRoot", () ->
      sut = new models.Quiz
      expect(sut.urlRoot).to.match /\/quizzes$/
