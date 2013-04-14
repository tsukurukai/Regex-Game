# encoding: utf-8
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
  check_answer_and_get_result(@answer, @course_id, @quiz_id).to_json
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
  Ranking.new(@name.to_s, @time.to_i).save!
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

## ====================
## methods
## ====================
# Check the answer and Create a OK list
#  return (has)
#   success    : (bool) true(the answer is correct) / false(wrong)
def check_answer_and_get_result(answer, course_id, quiz_id)
  quiz = Course.find_by_id(course_id.to_i).quiz(quiz_id.to_i)
  ok_list = exec_regular_expression(answer, quiz)
  # regard as "correct answer" under these conditions:
  # - the count of ok_match count equql to the count of matches of quiz and
  # - the count of ok_unmatch count equal to the count of unmatches of quiz
  status = false
  status = true if ok_list[:ok_matches].size == quiz["matches"].size && ok_list[:ok_unmatches].size == quiz["unmatches"].size
  # return as hash
  { success:status, ok_match:ok_list[:ok_matches], ok_unmatch:ok_list[:ok_unmatches] }
end

# execute the answer(regex) for quiz
#  return (hash)
#   ok_match   : (array) 'Match words' list matched to the answer
#   ok_unmatch : (array) 'Don't Match words' list unmatched to the answer
def exec_regular_expression(answer, quiz)
  regular_expression = string_to_regex(answer)
  # execute the answer to 'Match words'
  ok_matches = quiz["matches"].select {|str| regular_expression =~ str}
  # execute the answer to 'Don't Match words'
  ok_unmatches = quiz["unmatches"].reject {|str| regular_expression =~ str}
  # return as hash
  { ok_matches:ok_matches, ok_unmatches:ok_unmatches }
end

# convert answer from string to Regular Expression type
def string_to_regex(answer)
  regex_string = '^'
  # '¥' is required to be replaced to '\'
  # due to '¥' does differ from '\' especially in mac
  regex_string << answer.gsub('¥', '\\')
  regex_string << '$'
  Regexp.new(regex_string)
end

