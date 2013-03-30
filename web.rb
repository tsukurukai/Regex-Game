require 'sinatra'
require 'erb'

require 'sinatra/reloader' if development?

get '/' do
  erb :index
end

get '/c/1/q/:id' do
  @id = params[:id]
  erb :quiz
end

