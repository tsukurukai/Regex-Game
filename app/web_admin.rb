# -*- coding: utf-8 -*-
require 'sinatra/base'
require 'json'
require 'erb'
require 'pp'

require 'model'

class Admin < Sinatra::Base

    if development?
        require 'sinatra/reloader'
        register Sinatra::Reloader
    end

    get '/admin/' do
        admin_erb :'admin/index'
    end

    get '/admin/quizzes/list' do
        @results = Quiz.all.map do |quiz|
          res = {}
          res['id'] = quiz.id.to_s
          res['items'] = quiz.items.map do |item|
            target_start_index = item["target_start_index"]
            target_length= item["target_length"]
            target_last_index = target_start_index + target_length - 1
            {
              target_start_index: target_start_index,
              target_length: target_length,
              pref: item["sentence"].slice(0, target_start_index),
              target: item["sentence"].slice(target_start_index..target_last_index),
              suff: item["sentence"].slice((target_last_index + 1)..item["sentence"].length),
            }
          end
          res
        end
        admin_erb :"admin/quizzes/list"
    end

    get '/admin/quizzes/new' do
        admin_erb :"admin/quizzes/new"
    end

    post '/admin/quizzes/save' do
      quiz = Quiz.new
      JSON.parse(params[:quizzes]).each{|param|
        quiz.push(
          "sentence" => param["sentence"],
          "target_start_index" => param["targetStartIndex"],
          "target_length" => param["targetLength"]
        )
      }
      quiz.save
      @results = Quiz.all
      redirect "/admin/quizzes/list"
    end

    def admin_erb(template, options={}) 
        erb(template, options.merge(:layout => :'admin/layout')) 
    end
end
