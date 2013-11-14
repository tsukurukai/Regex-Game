# -*- coding: utf-8 -*-
class Admin < Sinatra::Base

    if development?
        require 'sinatra/reloader'
        register Sinatra::Reloader
    end

    get '/admin/' do
        admin_erb :'admin/index' 
    end

    get '/admin/course/list' do
        @results = Course.all 
        admin_erb :"admin/course/list" 
    end

    get '/admin/course/detail/:course_id' do
        @course_id = params[:course_id]
        @course = Course.find_by_id(@course_id.to_i)
        pp @course
        quiz = @course.quiz(1)
        admin_erb :"admin/course/detail" 
    end

    def admin_erb(template, options={}) 
        erb(template, options.merge(:layout => :'admin/layout')) 
    end
end

use Admin;
