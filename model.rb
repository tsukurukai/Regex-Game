require 'mongo'
require 'json'

class BaseModel
    def initialize()
        connection = Mongo::Connection.new('localhost');
        @db = connection.db('regex')
	end
end

class RegexModel < BaseModel
    def getCourses()
        coll = @db.collection('study')
        baka = coll.find_one 
		res = Array.new
        baka['courses'].each{|co|
		    h = Hash.new
		    h['name'] = co['name']
		    h['id'] = co['id']
		    res.push(h)
		}
		return res
	end

	def getQuiz(course_id, quiz_id)
        coll = @db.collection('study')
        baka = coll.find_one 
		quizes = Array.new
        baka['courses'].each{ | co |
		    if ( co['id'] == course_id)
			    quizes = co['quizes'] 
				break;
		    end	
		}
		h = Hash.new
		h['count'] = quizes.length
		h['quiz'] = quizes[quiz_id-1]
		return h 
	end

end


class RankingModel < BaseModel
    def insert(name, time)
        coll = @db.collection('ranking')
		h = Hash.new
		h['name'] = name
		h['time'] = time.to_i
		coll.insert(h)
	end

	def getList(page=1, limit=5)
        coll = @db.collection('ranking')
        i=1;
		list = Array.new
        coll.find().sort(:time => :desc).each do |slice|
		    if i > (page -1) * limit && i <= (page) * limit 
		        list.push(slice)
			end
			i += 1
        end
		return list
	end

	def find(username)
        coll = @db.collection('ranking')
        i=1;
        coll.find().sort(:time => :desc).each do |slice|
		    if slice['name'] == username
                return i;
			end
			i +=1
        end
        return nil
	end

end

 
