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

class MainApp < Sinatra::Base
  set :public_folder, File.expand_path(File.join(root, '..', 'public'))

  get '/' do
#    puts request.object_id
    @@screen_name = 'Sign in Twitter'
    @signin_link = '/auth/twitter'
#    @profile_image_icon = './signin_icon.jpg'
    haml :index
  end

  get '/auth/twitter/callback' do
    @auth = request.env['omniauth.auth']
    session[:screen_name] = @auth['info'].nickname
    session[:profile_image_icon] = @auth['info'].image
    @signin_link = '#'
    p @profile_image_icon
    session[:uid] = @auth['uid']
    @uid = session[:uid]
    if !(OauthUser.find_by(twitter_id: @uid))
      OauthUser.create!(twitter_id: @uid, user_name: @screen_name)
    end
    redirect '/user'
  end

  get '/user' do
    @uid = session[:uid]
    @screen_name = session[:screen_name]
    @profile_image_icon = session[:profile_image_icon]
    haml :user
  end

  get '/signout' do
    session[:uid] = nil
    session[:screen_name] = nil
    session[:profile_image_icon] = nil
    redirect '/'
  end
end
