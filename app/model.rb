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
  attr_reader :id, :items
  def initialize(id=nil)
    @id = id
    @items = []
  end

  def self.all()
    res = Array.new
    db.collection('quizzes').find().each{|co|
      quiz = Quiz.new(co['_id'])
      co['items'].each do |s|
        quiz.push(s)
      end
      res.push(quiz)
    }
    return res
  end

  def self.drop()
    db.collection('quizzes').drop()
  end

  def self.find_by_random(excludes = [])
    docs = db.collection('quizzes').find().to_a
    xs = docs.reject do |doc|
      excludes.include? doc['_id']
    end
    res =
      if xs.empty?
        docs.to_a.sample
      else
        xs.sample
      end

    quiz = Quiz.new(res['_id'])
    res['items'].each do |s| quiz.push(s) end
    quiz
  end

  def self.find_by_id(id)
    row = db.collection('quizzes').find_one('_id' => BSON::ObjectId(id))
    if row.nil?
      nil
    else
      quiz = Quiz.new(row['_id'])
      row['items'].each do |s| quiz.push(s) end
      quiz
    end
  end

  def push(args={})
    args = {
      "sentence" => nil,
      "target_start_index" => nil,
      "target_length" => nil,
    }.merge(args)
    @items.push(args)
  end

  def save
    h = Hash.new
    h['items'] = @items
    Ranking.db.collection('quizzes').insert(h)
  end

  def target_end_index
    @target_start_index + @target_length - 1
  end

  def test(answer)
    return false if @items.empty?
    begin
      regex = string_to_regex(answer)
      misses = @items.reject do |item|
        target = item["sentence"].slice((item["target_start_index"])..(item["target_start_index"] + item["target_length"] - 1))
        matches = item["sentence"].scan(regex)
        first_group_matched = matches[0]
        if first_group_matched.nil? || first_group_matched.empty?
          false
        else
          target == first_group_matched[0]
        end
      end
      misses.size == 0
    rescue
      false
    end
  end

private

  # convert answer from string to Regular Expression type
  def string_to_regex(answer)
    # '¥' is required to be replaced to '\'
    # due to '¥' does differ from '\' especially in mac
    regex_string = answer.gsub('¥', '\\')
    Regexp.new(regex_string)
  end
end
