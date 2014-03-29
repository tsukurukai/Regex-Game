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
    it 'should false when quiz has no items' do
      @sut.test('[0-9]').should eq false
    end

    context 'quiz has a item that is "aa01bb01" and capture target is first "01"' do
      before do
        @sut.push("sentence" => "aa01bb01", "target_start_index" => 2, "target_length" => 2)
      end

      specify { @sut.test('').should eq false }
      specify { @sut.test('aa01bb').should eq false }
      specify { @sut.test('aa(01)bb').should eq true }
      specify { @sut.test('aa(\w+)bb').should eq true }

      it "should false when capture multiple" do
        @sut.test('(01)').should eq false
      end

      it "should false when invalid regular expression" do
        @sut.test('aa(01').should eq false
      end

    end
  end
end

