require 'mongo'
require 'json'


class RegexModel
    def initialize()
        connection = Mongo::Connection.new('localhost');
        @db = connection.db('regex')
	end

    def getCourses()
        coll = @db.collection('study')
        baka = coll.find_one 
		res = Array.new
        baka['courses'].each{ | co |
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




 
