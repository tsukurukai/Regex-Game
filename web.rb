# encoding: utf-8
require 'sinatra'
require 'json'
require 'erb'

require 'sinatra/reloader' if development?

require './model'

# TOP
get '/' do
  @courses = RegexModel.new.getCourses()
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
  # quiz を取得
  h = RegexModel.new.getQuiz(@course_id.to_i, @quiz_id.to_i)
  count = h["count"]
  is_finish = @quiz_id.to_i > count.to_i
  {isFinish: is_finish, quiz: h["quiz"]}.to_json
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
  RankingModel.new.insert(@name.to_s, @time.to_i)
  redirect "/c/#{@course_id}/result"
end

# result
get '/c/:course_id/result' do
  @course_id = params[:course_id]
  # get all ranking-list from db
  tmp_ranking_list = RankingModel.new.getList(1, 30)
  @ranking_list = tmp_ranking_list.map {|item| {name:item["name"], time:item["time"].to_f/1000}}
  erb :result
end

## ====================
## methods
## ====================
# 入力された回答が正しいかチェックする
def check_answer_and_get_result(answer, course_id, quiz_id)
  # quiz を取得
  quiz = RegexModel.new.getQuiz(course_id.to_i, quiz_id.to_i)
  # quiz に対して正規表現を実行する
  result = exec_regular_expression(answer, quiz["quiz"])
end

# 入力された回答が正しいかチェックする
def exec_regular_expression(answer, quiz)
  # 入力された値を正規表現に変換
  regex_expression = convert_regex(answer)
  # match させたいリスト
  ok_match = quiz["matches"].select {|item| regex_expression =~ item}
  # unmatch させたいリスト
  ok_unmatch = quiz["unmatches"].reject {|item| regex_expression =~ item}

  # regard as "correct answer" under these conditions: 
  # - equal the count of ok_match count to the count of matches of quiz and
  # - equal the count of ok_unmatch count to the count of unmatches of quiz
  if ok_match.size == quiz["matches"].size && ok_unmatch.size == quiz["unmatches"].size
    status = true
  else 
    status = false 
  end
  # contain in hash
  { success:status, ok_match:ok_match, ok_unmatch:ok_unmatch }
end

# convert answer from string to Regular Expression type
def convert_regex(answer)
    regex_string = '^'
    regex_string << answer.gsub('¥', '\\')
    regex_string << '$'
    Regexp.new(regex_string)
end 

