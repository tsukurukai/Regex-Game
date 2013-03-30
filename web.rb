require 'sinatra'
require 'erb'

require 'sinatra/reloader' if development?

# TOP
get '/' do
  erb :index
end

# quiz
get '/c/:course_id/q/:quiz_id' do
  @quiz_id = params[:quiz_id]
  erb :quiz
end

# result 
get '/c/:course_id/result/put/:name' do
  @course_id = params[:course_id]
  @name= params[:name]
  erb :result
end

