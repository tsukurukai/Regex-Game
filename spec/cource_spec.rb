# -*- coding: utf-8 -*-
require './model'

describe Course do
  context "check_answerのテスト" do
    before do
      @target = Course.new(
        1,
        'test course',
        [{"matches"=> ["Banana", "Apple"], "unmatches"=> ["HTML5", "hash_tag"]}]
      )
    end
    it {
      @target.check_answer("Banana|Apple", 1).should include(
        success: true,
        ok_match: ["Banana", "Apple"],
        ok_unmatch: ["HTML5", "hash_tag"])
    }
  end
end

