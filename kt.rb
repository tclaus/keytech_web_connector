## Remember to run 'bundle install' if something in Gemfile has changed!
## To now start the app run 'rackup -p 4567' instead of 'ruby kt.rb' !

require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/base'
require "sinatra/reloader" if development?


require_relative "helpers/search_helper"

class KtApp < Sinatra::Base
  register Sinatra::Contrib
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


  helpers do
  
    def access_granted?
      (params[:username]=="jgrant") && (params[:passwd]=="")? true : false
    end

    def find(searchstring)
  
    
      @result = HTTParty.get("https://api.keytech.de/searchitems", :basic_auth => {:username => "jgrant", :password => ""}, :query => {:q => searchstring})
      @itemarray=@result["ElementList"]
    
    end
  end


  #routes
  #These are your Controllers! Can be outsourced to own files but I leave them here for now.

  #main page Controller
  get '/' do
    erb :index
  end

  #search controller
  before '/search' do
    unless access_granted?
    redirect '/'
    end
  end

  get '/search' do

    erb :search
  end

  post '/search' do
    erb :search
  end

end