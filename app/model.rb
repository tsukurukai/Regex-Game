# -*- coding: utf-8 -*-
require 'mongo'
require 'json'
require 'bson'

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
  attr_reader :id, :sentence, :target_start_index, :target_length
  def initialize(sentence, target_start_index, target_length, id=nil)
    @id = id
    @sentence = sentence
    @target_start_index = target_start_index
    @target_length = target_length
  end

  def self.all()
    res = Array.new
    db.collection('quizzes').find().each{|co|
      res.push(Quiz.new(co['sentence'], co['target_start_index'], co['target_length'], co['_id']))
    }
    return res
  end

  def self.drop()
    db.collection('quizzes').drop()
  end

  def self.find_by_random
    count = db.collection('quizzes').count()
    random = rand count
    res = db.collection('quizzes').find().limit(-1).skip(random).next
    Quiz.new(res['sentence'], res['target_start_index'], res['target_length'], res['_id'])
  end

  def self.find_by_id(id)
    row = db.collection('quizzes').find_one('_id' => BSON::ObjectId(id))
    if row.nil?
      nil
    else
      Quiz.new(row['sentence'], row['target_start_index'], row['target_length'], row['_id'])
    end
  end

  def save
    h = Hash.new
    h['sentence'] = @sentence
    h['target_start_index'] = @target_start_index
    h['target_length'] = @target_length
    Ranking.db.collection('quizzes').insert(h)
  end

  def target_end_index
    @target_start_index + @target_length - 1
  end

  def test(answer)
    regex = string_to_regex(answer)
    target = @sentence.slice(@target_start_index..target_end_index)
    matches = @sentence.scan(regex)
    first_group_matched = matches[0]
    if first_group_matched.nil? || first_group_matched.empty?
      false
    else
      target == first_group_matched[0]
    end
  end

private

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
