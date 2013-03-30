require 'sinatra'
require 'json'
require 'erb'
require 'json'

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
  # quiz を取得
  @quiz = get_quiz(@course_id, @quiz_id)
  erb :quiz
end

# quiz
# answer check
post '/c/:course_id/q/:quiz_id/answer' do
  p params[:input]
  @course_id = params[:course_id]
  @quiz_id = params[:quiz_id]
  @answer =  params[:answer]
  # answer check
  check_answer(@answer, @course_id, @quiz_id)

  ok_match = %w[Banana Apple Book]
  ok_not_match = %w[HTML5]
  { success: true, ok_match: ok_match, ok_not_match: ok_not_match }.to_json
end

# result 
# post total time
post '/c/:course_id/result/complete' do
  @course_id = params[:course_id]
  redirect "/c/#{@course_id}/result/input"
end

# result
get '/c/:course_id/result/input' do
  @course_id = params[:course_id]
  erb :result_input
end

# result
# put answerer's name
post '/c/:course_id/result/put' do
  @course_id = params[:course_id]
  @name      = params[:name]
  redirect "/c/#{@course_id}/result"
end

# result
get '/c/:course_id/result' do
  @course_id = params[:course_id]
  erb :result
end


## methods

# quizを取得します
def get_quiz(course_id, quiz_id)
  # mongodb からクイズを取得
  # quiz = get_quiz_from_db(courser_id, quiz_id)
  quiz = { course_id:1, quiz_id:2, match:%w[apple banana], unmatch:%w[HTML5 Android]}.to_json
  p quiz
  quiz
end

# 入力された回答が正しいかチェックする
def check_answer(answer, course_id, quiz_id)
  # quiz を取得
  quiz = get_quiz(course_id, quiz_id)
  # quiz に対して正規表現を実行する
  exec_regex_expression(answer, quiz)
end

# 入力された回答が正しいかチェックする
def exec_regex_expression(answer, quiz)
  # quiz 一つ一つに対して実行
  # quiz.each.do |q|
    # 実行する
    # regex(answer,q)
    # 成功していたらハッシュに格納
    # 
  # end 
end

