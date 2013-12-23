## Remember to run 'bundle install' if something in Gemfile has changed!
## To now start the app run 'rackup -p 4567' instead of 'ruby kt.rb' !

require 'rubygems'
require 'bundler'

require 'sinatra/base'
require "sinatra/contrib/all"
require 'sinatra/assetpack'
require 'rack-flash'


Bundler.require(:default)


class KtApp < Sinatra::Base
  
  register Sinatra::Contrib
  register Sinatra::AssetPack

  require_relative "lib/kt_api"
  require_relative "helpers/search_helper"
  require_relative "helpers/application_helper"

  set :root, File.dirname(__FILE__)

# Enable flash messages
use Rack::Flash, :sweep => true

helpers do
  def flash_types
    [:success, :notice, :warning, :error]
  end
end


#Some configurations (dont know where to put it )
configure :development do
  # at Development SQLlite will do fine
  
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

#Some configurations (dont know where to put it )
configure :production do
  # A Postgres connection:
  username="production_username" # Dont know what to do here
  password="production_password"
  DataMapper.setup(:default, 'postgres://#{username}:#{password}@localhost/production')
end


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
      #'/css/foundation.css',
      '/css/application.css',
      '/css/search.css'
    ]

    js_compression :jsmin
    css_compression :simple

  end

  #include Helpers module
  helpers ApplicationHelper
  helpers SearchHelper
  

  # Routes
  # These are your Controllers! Can be outsourced to own files but I leave them here for now.


  #main page Controller
  get '/' do
    if session[:user]
      redirect '/search'
    else

      #Never logged in, show the normal index / login page
      erb :index
    end
  end


  #search controller

  get '/search' do
    if session[:user]
      @result=KtApi.find(params[:q])
      erb :search
    else 
        flash[:notice] = "(TBD: loged out or session invalid)"
       redirect '/'
    end
  end

  #Loads a element structure, if present
  get '/search/:elementKey' do
    if session[:user]
      @result=KtApi.loadElementStructure(params[:elementKey])
      erb :search
    else
      flash[:notice] = "(TBD: loged out or session invalid)"
      redirect '/'
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
      flash[:warning] = "Invalid username or password)"
      redirect '/'
    end
  end

  get "/logout" do
    session.destroy
    KtApi.destroy_session

    flash[:notice] = "You have logged out."
    redirect '/'
  end

#Image forwarding. Redirect classimages provided by API to another image directly fetched by API
get "/images/classimages/:classKey" do
   if session[:user]
      content_type "image/png"
      loadClassImage(params[:classKey])
    else
      flash[:notice] = "(TBD: loged out or session invalid)"
      redirect '/'
    end
end


get "/files/:elementKey/masterfile" do
   if session[:user]
      content_type "application/octet-stream"
      
      loadMasterfile(params[:elementKey])
    else
      flash[:notice] = "(TBD: loged out or session invalid)"
      redirect '/'
    end
end


end
