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
        @results = Sentences.all 
        p @results
        admin_erb :"admin/sentences/list" 
    end

    post '/admin/sentences/save' do
        Sentences.drop;
        JSON.parse(params[:sentences]).each{|baka|
            Sentences.new(baka.to_s).save;
        }
        @results = Sentences.all 
        admin_erb :"admin/sentences/list" 
    end

    def admin_erb(template, options={}) 
        erb(template, options.merge(:layout => :'admin/layout')) 
    end
end

use Admin;
