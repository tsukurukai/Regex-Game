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
get '/c/:course_id/q/:quiz_id' do
  @course_id = params[:course_id]
  @quiz_id   = params[:quiz_id]
  # quiz を取得
  h = RegexModel.new.getQuiz(@course_id.to_i, @quiz_id.to_i)
  count = h["count"]
  @matches = h["quiz"]["matches"]
  @unmatches = h["quiz"]["unmatches"]
  erb :quiz
end

# quiz
# answer check
post '/c/:course_id/q/:quiz_id/answer' do
  @course_id = params[:course_id]
  @quiz_id = params[:quiz_id]
  @answer =  params[:answer]
  p '***************************'
  p @answer 
  p '***************************'
  # answer check
  check_answer_and_get_result(@answer, @course_id, @quiz_id).to_json
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
  quiz = { course_id:1, quiz_id:2, match:%w[apple banana], unmatch:%w[HTML5 Android]}
  quiz
end

# 入力された回答が正しいかチェックする
def check_answer_and_get_result(answer, course_id, quiz_id)
  # quiz を取得
  quiz = get_quiz(course_id, quiz_id)
  # quiz に対して正規表現を実行する
  result = exec_regular_expression(answer, quiz)
end

# 入力された回答が正しいかチェックする
def exec_regular_expression(answer, quiz)
  # 入力された値を正規表現に変換
  regex_expression = convert_regex(answer)
  # match させたいリスト
  ok_match = quiz[:match].select {|item| regex_expression =~ item}
  p '********* match result **************'
  p regex_expression
  p quiz[:match] 
  p ok_match
  p '********* /match result **************'

  # unmatch させたいリスト
  ok_unmatch = quiz[:unmatch].select {|item| regex_expression =~ item}
  p '********* unmatch result **************'
  p regex_expression
  p quiz[:unmatch] 
  p ok_unmatch
  p '********* /unmatch result **************'

  # 以下の条件を満たす時、「正解」扱い
  # matchでヒットした数と問題の数がイコール かつ
  # unmatchでヒットした数が0
  if ok_match.size == quiz[:match] && ok_unmatch.size == 0
    status = true
  else 
    status = false 
  end

  # ハッシュに格納
  { success:status, ok_match:ok_match, ok_unmatch:ok_unmatch }
end

# 文字列を正規表現の形式に変換します
def convert_regex(answer)
    regex_string = '^'
    regex_string << answer
    regex_string << '$'
    Regexp.new(regex_string)
end 

