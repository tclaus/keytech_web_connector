## Remember to run 'bundle install' if something in Gemfile has changed!
## To now start the app run 'rackup -p 4567' instead of 'ruby kt.rb' !

require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/base'
require "sinatra/contrib/all"




class KtApp < Sinatra::Base
  register Sinatra::Contrib

  require_relative "lib/kt_api"
  require_relative "helpers/search_helper"

  set :root, File.dirname(__FILE__)

  register Sinatra::AssetPack
  assets do

    js :application, [
      '/js/vendor/custom.modernizr.js'
      # You can also do this: 'js/*.js'
    ]

    js :body, [
      '/js/vendor/jquery.js',
      '/js/foundation.min.js'
      # You can also do this: 'js/*.js'
    ]

    css :application, [
      '/css/normalize.css',
      '/css/foundation.css',
      '/css/app.css',
      '/css/search.css'
    ]

    js_compression :jsmin
    css_compression :simple

  end

  #include SearchHelper module
  helpers SearchHelper


  #routes
  #These are your Controllers! Can be outsourced to own files but I leave them here for now.

  #main page Controller
  get '/' do
    if session[:user]
      redirect '/search'
    else
    erb :index
    end
  end

  
  #search controller

  get '/search' do
    if session[:user]
      @result=KtApi.find(params[:q])
      erb :search
    else redirect '/'
    end
  end



  #login controller
  post '/login' do
    if KtApi.access_granted?(params)
      session[:user]=params[:username]
      session[:passwd]=params[:passwd]
      KtApi.set_session(session)
      redirect '/search'
    else
      redirect '/'
    end
  end

  get "/logout" do
    session.destroy
    KtApi.destroy_session
    redirect '/'
  end

end