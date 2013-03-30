require 'sinatra'
require 'erb'

require 'sinatra/reloader' if development?

# TOP
get '/' do
  erb :index
end

# quiz
# render quiz 
get '/c/:course_id/q/:quiz_id' do
  @course_id = params[:course_id]
  @quiz_id   = params[:quiz_id]
  erb :quiz
end

# quiz
# answer check
post '/c/:course_id/q/:quiz_id/answer' do
  @course_id = params[:course_id]
  @quiz_id = params[:quiz_id]
  erb :quiz
end

# result 
post '/c/:course_id/result' do
  @course_id = params[:course_id]
  erb :result
end

# result 
# put answerer's name
post '/c/:course_id/result/put/:name' do
  @course_id = params[:course_id]
  @name      = params[:name]
  erb :result
end

