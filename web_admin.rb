# -*- coding: utf-8 -*-
class Admin < Sinatra::Base

    if development?
        require 'sinatra/reloader'
        register Sinatra::Reloader
    end

    get '/admin/' do
        admin_erb :'admin/index' 
    end

    get '/admin/sentences/list' do
        @results = Quiz.all.map do |val|
          h = {}
          h[:target_start_index] = val.target_start_index
          h[:target_length]      = val.target_length
          h[:pref]               = val.sentence.slice(0, val.target_start_index.to_i)
          h[:target]             = val.sentence.slice(val.target_start_index.to_i..(val.target_start_index.to_i + val.target_length.to_i))
          h[:suff]               = val.sentence.slice((val.target_start_index.to_i + 1 + val.target_length.to_i)..val.sentence.length.to_i)
          h
        end
        admin_erb :"admin/sentences/list"
    end

    post '/admin/sentences/save' do
        Quiz.drop;
        JSON.parse(params[:sentences]).each{|baka|
            Quiz.new(baka["sentence"], baka["targetStartIndex"], baka["targetLength"]).save;
        }
        @results = Quiz.all
        redirect "/admin/sentences/list"
    end

    def admin_erb(template, options={}) 
        erb(template, options.merge(:layout => :'admin/layout')) 
    end
end

use Admin;
