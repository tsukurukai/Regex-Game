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

  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
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

private

  def get_quiz
    quizes = Array.new
    Course.db.collection('study').find_one['courses'].each{ | co |
      if ( co['id'] == @id)
        return co['quizes']
      end
    }
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

# 使われてない？
#  def find(username)
#    i=1;
#    @coll.find().sort(:time).each do |slice|
#      if slice['name'] == username
#        return i;
#      end
#      i +=1
#    end
#    return nil
#  end

  def save!
    h = Hash.new
    h['name'] = @name
    h['time'] = @time
    Ranking.db.collection('ranking').insert(h)
  end
end

