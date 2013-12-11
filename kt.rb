require 'rubygems'
require 'bundler'
Bundler.require
require 'httparty'
require 'sinatra/assetpack'
require 'sass'
require 'json'
require "sinatra/reloader" if development?
require 'sinatra/contrib'

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
get '/' do
  erb :index
end


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
