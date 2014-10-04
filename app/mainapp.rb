#!/usr/bin/env ruby
# encoding: utf-8
require 'sinatra/base'
require 'haml'
require 'oauth'
require 'oauth/consumer'
require 'omniauth'
require 'omniauth-twitter'

class MainApp < Sinatra::Base
  auth_flg = 2

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

  if auth_flg == 2
    use OmniAuth::Builder do
      provider :twitter, twitter_config['consumer_key'], twitter_config['consumer_secret']
    end
  end

  before do
    if auth_flg == 1
      @consumer = OAuth::Consumer.new( 
                                      twitter_config['consumer_key'], 
                                      twitter_config['consumer_secret'],
                                      {
                                        :site               =>  'https://twitter.com',
                                        :request_token_path =>  '/oauth/request_token',
                                        :authorize_path     =>  '/oauth/authorize', 
                                        :access_token_path  =>  '/oauth/access_token'
                                      })
      @request_token = @consumer.get_request_token
    end
  end

  get '/' do
    if auth_flg == 1
      redirect @request_token.authorize_url
    elsif auth_flg == 2
      haml :index
    end
  end

  get '/auth/:name/callback' do
    @auth = request.env['omniauth.auth']
    haml :index2
  end

end
