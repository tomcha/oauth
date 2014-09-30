#!/usr/bin/env ruby
# encoding: utf-8
require 'sinatra/base'
require 'haml'

class MainApp < Sinatra::Base
  set :public_folder, File.expand_path(File.join(root, '..', 'public'))

  get '/' do
    haml :index
  end
end
