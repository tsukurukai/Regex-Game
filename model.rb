# -*- coding: utf-8 -*-
require 'mongo'
require 'json'

class BaseModel
private
  def self.db()
    if 'production' != ENV['RACK_ENV']
      connection = Mongo::Connection.new('localhost')
    else
      connection = Mongo::Connection.new('alex.mongohq.com', 10015)
    end
    db = connection.db('app14201811')
    if 'production' == ENV['RACK_ENV']
      db.authenticate('regex', 'regex')
    end
    db
  end
end


class Course < BaseModel
  attr_reader :id, :name, :quizes

  def initialize(id, name, quizes=nil)
    @id = id
    @name = name
    @quizes = get_quiz 
  end

  def self.all
    res = Array.new
    db.collection('study').find_one['courses'].each{|co|
      res.push(Course.new(co['id'], co['name']))
    }
    return res
  end

  def self.find_by_id(course_id)
    res = nil
    db.collection('study').find_one['courses'].each{|co|
      if ( co['id'] == course_id)
        res = Course.new(co['id'], co['name'])
        break;
      end
    }
    return res
  end

  def quiz_length
    @quizes ||= get_quiz
    @quizes.length
  end

  def quiz(quiz_id)
    @quizes ||= get_quiz
    @quizes[quiz_id.to_i == 0 || quiz_id.to_i > @quizes.length ? 0 : quiz_id.to_i - 1]
  end

  # Check the answer and Create a OK list
  #  return (has)
  #   success    : (bool) true(the answer is correct) / false(wrong)
  def check_answer(answer, quiz_id)
    quiz = quiz(quiz_id.to_i)
    ok_list = exec_regular_expression(answer, quiz)
    # regard as "correct answer" under these conditions:
    # - the count of ok_match count equql to the count of matches of quiz and
    # - the count of ok_unmatch count equal to the count of unmatches of quiz
    status = false
    status = true if ok_list[:ok_matches].size == quiz["matches"].size && ok_list[:ok_unmatches].size == quiz["unmatches"].size
    # return as hash
    { success:status, ok_match:ok_list[:ok_matches], ok_unmatch:ok_list[:ok_unmatches] }
  end

private

  def get_quiz
    quizes = Array.new
    Course.db.collection('study').find_one['courses'].each{ | co |
      if ( co['id'] == @id)
        return co['quizes']
      end
    }
  end

  # execute the answer(regex) for quiz
  #  return (hash)
  #   ok_match   : (array) 'Match words' list matched to the answer
  #   ok_unmatch : (array) 'Don't Match words' list unmatched to the answer
  def exec_regular_expression(answer, quiz)
    regular_expression = string_to_regex(answer)
    # execute the answer to 'Match words'
    ok_matches = quiz["matches"].select {|str| regular_expression =~ str}
    # execute the answer to 'Don't Match words'
    ok_unmatches = quiz["unmatches"].reject {|str| regular_expression =~ str}
    # return as hash
    { ok_matches:ok_matches, ok_unmatches:ok_unmatches }
  end

  # convert answer from string to Regular Expression type
  def string_to_regex(answer)
    regex_string = '^'
    # '¥' is required to be replaced to '\'
    # due to '¥' does differ from '\' especially in mac
    regex_string << answer.gsub('¥', '\\')
    regex_string << '$'
    Regexp.new(regex_string)
  end
end


class Ranking < BaseModel
  attr_reader :name, :time
  def initialize(name, time)
    @name = name
    @time = time
  end

  def self.getList(page=1, limit=5)
    i=1;
    list = Array.new
    db.collection('ranking').find().sort(:time).each do |slice|
      if i > (page -1) * limit && i <= (page) * limit
        list.push(Ranking.new(slice['name'], slice['time']))
      end
      i += 1
    end
    return list
  end

  def save
    h = Hash.new
    h['name'] = @name
    h['time'] = @time
    Ranking.db.collection('ranking').insert(h)
  end
end

class Quiz < BaseModel
  attr_reader :sentence, :target_start_index, :target_length
  def initialize(sentence, target_start_index, target_length)
    @sentence = sentence
    @target_start_index = target_start_index
    @target_length = target_length
  end

  def self.all()
    res = Array.new
    db.collection('quizzes').find().each{|co|
      res.push(Quiz.new(co['sentence'], co['target_start_index'], co['target_length']))
    }
    return res
  end

  def self.drop()
    db.collection('quizzes').drop()
  end

  def save
    h = Hash.new
    h['sentence'] = @sentence
    h['target_start_index'] = @target_start_index
    h['target_length'] = @target_length
    Ranking.db.collection('quizzes').insert(h)
  end
end
