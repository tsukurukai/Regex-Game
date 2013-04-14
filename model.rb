require 'mongo'
require 'json'

class BaseModel
  def initialize()
    if 'production' != ENV['RACK_ENV']
      connection = Mongo::Connection.new('localhost')
    else
      connection = Mongo::Connection.new('alex.mongohq.com', 10015)
    end
    @db = connection.db('app14201811')
    if 'production' == ENV['RACK_ENV']
      @db.authenticate('regex', 'regex')
    end
  end

private

  def self.db()
    if 'production' != ENV['RACK_ENV']
      connection = Mongo::Connection.new('localhost')
    else
      connection = Mongo::Connection.new('alex.mongohq.com', 10015)
    end
    @db = connection.db('app14201811')
    if 'production' == ENV['RACK_ENV']
      @db.authenticate('regex', 'regex')
    end
    @db
  end
end

class Cource < BaseModel

  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def self.all
    res = Array.new
    db.collection('study').find_one['courses'].each{|co|
      res.push(Cource.new(co['id'], co['name']))
    }
    return res
  end

  def self.find_by_id(cource_id)
    res = nil
    db.collection('study').find_one['courses'].each{|co|
      if ( co['id'] == cource_id)
        res = Cource.new(co['id'], co['name'])
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

private

  def get_quiz
    quizes = Array.new
    Cource.db.collection('study').find_one['courses'].each{ | co |
      if ( co['id'] == @id)
        return co['quizes']
      end
    }
  end

end


class RankingModel < BaseModel
  def initialize()
    super()
    @coll = @db.collection('ranking')
  end

  def insert(name, time)
    h = Hash.new
    h['name'] = name
    h['time'] = time.to_i
    @coll.insert(h)
  end

  def getList(page=1, limit=5)
    i=1;
    list = Array.new
    @coll.find().sort(:time).each do |slice|
      if i > (page -1) * limit && i <= (page) * limit
        list.push(slice)
      end
      i += 1
    end
    return list
  end

  def find(username)
    i=1;
    @coll.find().sort(:time).each do |slice|
      if slice['name'] == username
        return i;
      end
      i +=1
    end
    return nil
  end
end

