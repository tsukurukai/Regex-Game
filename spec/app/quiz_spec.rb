# -*- coding: utf-8 -*-
require 'spec_helper'

describe Quiz do

  before do
    @sut = Quiz.new
  end

  describe '#push' do

    it 'its items should have no item' do
      @sut.items.should be_empty
    end

    it 'should have 1 items after called "push" 1 times' do
      @sut.push("sentence" => "aaa123bbb", "target_start_index" => 3, "target_length" => 3)
      @sut.items.should have(1).items
    end

    it 'should have 2 items after called "push" 2 times' do
      @sut.push("sentence" => "aaa123bbb", "target_start_index" => 3, "target_length" => 3)
      @sut.push("sentence" => "ABC5555DEF", "target_start_index" => 3, "target_length" => 4)
      @sut.items.should have(2).items
    end

  end

  describe '#test' do
    context 'quiz has no items' do
      specify { @sut.test('[0-9]').should eq false }
    end
  end
end

