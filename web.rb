require 'sinatra'
require 'erb'

require 'sinatra/reloader' if development?

get '/q/:id' do
  @id = params[:id]
  erb :index
end

