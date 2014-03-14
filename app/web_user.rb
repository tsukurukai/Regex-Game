# -*- coding: utf-8 -*-
require 'sinatra/base'
require 'json'
require 'erb'
require 'pp'

require 'model'

class User < Sinatra::Base
  enable :sessions

  if development?
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  # TOP
  get '/' do
    erb :index
  end

  # quiz
  # render quiz
  get '/c/:course_id' do
    @course_id = params[:course_id]
    @quiz = Quiz.find_by_random
    session['showd_quizes'] = []
    erb :quiz
  end

  # quiz
  get '/quizzes/random' do
    quiz = Quiz.find_by_random
    i = 0
    while session['showd_quizes'].include? quiz.id
      quiz = Quiz.find_by_random
      i = i + 1
      break if i > 10
    end
    session['showd_quizes'].push quiz.id
    {
      id: quiz.id,
      sentence: quiz.sentence,
      targetStartIndex: quiz.target_start_index,
      targetLength: quiz.target_length
    }.to_json
  end

  # quiz
  post '/quizzes/:quiz_id/test' do
    quiz_id  = params[:quiz_id].to_s
    answer =  params[:answer]
    quiz = Quiz.find_by_id(quiz_id)
    result = quiz.test(answer)
    {
      resolved: result
    }.to_json
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
end
