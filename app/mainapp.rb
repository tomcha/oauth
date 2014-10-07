#!/usr/bin/env ruby
# encoding: utf-8
require 'sinatra/base'
require 'haml'
require 'omniauth'
require 'omniauth-twitter'

class MainApp < Sinatra::Base

  configure do
    set :public_folder, File.expand_path(File.join(root, '..', 'public'))
    enable :sessions, :logging

    twitter_config = Hash.new
    File.open(File.expand_path(File.join(root, '..', 'config', 'config.txt'))) do |file|
      file.each_line do |text|
        (key, value) = text.chomp.split(':')
        twitter_config[key] = value
      end
      twitter_config['access_token'] = ''
      twitter_config['access_token_secret'] = ''
    end

    use OmniAuth::Builder do
      provider :twitter, twitter_config['consumer_key'], twitter_config['consumer_secret']
    end
  end

  get '/' do
    haml :index
  end

  get '/auth/twitter/callback' do
    @auth = request.env['omniauth.auth']
    session[:uid] = @auth['uid']
    @uid = session[:uid]
    haml :user
  end
end
