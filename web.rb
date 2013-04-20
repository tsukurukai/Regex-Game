# -*- coding: utf-8 -*-
require 'sinatra'
require 'json'
require 'erb'

require 'sinatra/reloader' if development?

require './model'

# TOP
get '/' do
  @courses = Course.all
  erb :index
end

# quiz
# render quiz
get '/c/:course_id' do
  @course_id = params[:course_id]
  erb :quiz
end

# quiz
# render quiz
get '/c/:course_id/q/:quiz_id' do
  @course_id = params[:course_id]
  @quiz_id   = params[:quiz_id]
  course = Course.find_by_id(@course_id.to_i)
  quiz = course.quiz(@quiz_id.to_i)
  count = course.quiz_length
  is_finish = @quiz_id.to_i > count.to_i
  {isFinish: is_finish, quiz: quiz}.to_json
end

# quiz
# answer check
post '/c/:course_id/q/:quiz_id/answer' do
  @course_id = params[:course_id]
  @quiz_id = params[:quiz_id]
  @answer =  params[:answer]
  # answer check
  course = Course.find_by_id(@course_id.to_i)
  course.check_answer(@answer, @quiz_id).to_json
end

# result
# input answerer's name
get '/c/:course_id/result/input' do
  @course_id = params[:course_id]
  @time = params[:time]
  @time_for_view = @time.to_f/1000
  erb :result_input
end

# result
# register answerer's name
#  and redirect to result list
post '/c/:course_id/result/put' do
  @course_id = params[:course_id]
  @name      = params[:name]
  @time      = params[:time]
  # register answerer's name and record-time
  Ranking.new(@name.to_s, @time.to_i).save
  redirect "/c/#{@course_id}/result"
end

# result
get '/c/:course_id/result' do
  @course_id = params[:course_id]
  # get all ranking-list from db
  list = Ranking.getList(1, 30)
  @ranking_list = list.map {|item| {name:item.name, time:item.time.to_f/1000}}
  erb :result
end

