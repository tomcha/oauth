#!/usr/bin/env ruby
# encoding: utf-8
require 'sinatra/base'
require 'haml'
require 'omniauth'
require 'omniauth-twitter'
require 'active_record'
require 'sqlite3'
require_relative 'models/oauth_user'

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

    db_path = File.expand_path(File.join(root, '..', 'DB', 'oauth.db'))
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: db_path
    )
  end

  get '/' do
    puts request.object_id
    haml :index
  end

  get '/auth/twitter/callback' do
    @auth = request.env['omniauth.auth']
    @screen_name = @auth['info'].nickname
    session[:uid] = @auth['uid']
    p @screen_name
    puts "OK_OK"
    @uid = session[:uid]
#    if !(OauthUser.find_by(twitter_id: @uid))
#      OauthUser.create!(twitter_id: @uid, user_name: @screen_name)
#    end

    haml :user
  end
end
