# -*- coding: utf-8 -*-
require 'sinatra/base'
$:.push(File.expand_path(File.dirname(__FILE__)) + '/app')
require 'web_user'
require 'web_admin'

class App < Sinatra::Base
  use User
  use Admin
end
