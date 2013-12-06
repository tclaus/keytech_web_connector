require 'rubygems'
require 'bundler'
Bundler.require
require 'httparty'
require 'sinatra/assetpack'
require 'sass'

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
    '/css/app.css'
   ]

  js_compression :jsmin
  css_compression :simple

end





#routes
get '/' do
  erb :index
end

get '/search' do
  erb :search
end

