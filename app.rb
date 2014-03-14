# -*- coding: utf-8 -*-
require 'sinatra'
$:.push(File.expand_path(File.dirname(__FILE__)) + '/app')
require 'web_user'
require 'web_admin'

use User
use Admin
