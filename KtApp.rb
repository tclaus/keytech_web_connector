## Remember to run 'bundle install' if something in Gemfile has changed!
## To now start the app run 'rackup -p 4567' instead of 'ruby kt.rb' !

require 'rubygems'
require 'bundler'

require 'sinatra/base'
require "sinatra/contrib/all"
require 'sinatra/assetpack'
require 'rack-flash'

require './UserAccount'
require './helpers/KtApi'

Bundler.require(:default)


class KtApp < Sinatra::Base
  
  register Sinatra::Contrib
  register Sinatra::AssetPack

  require_relative "helpers/ktApi"
  require_relative "helpers/SearchHelper"
  require_relative "helpers/ApplicationHelper"
  require_relative "helpers/SessionHelper"

  set :root, File.dirname(__FILE__)

# Enable flash messages
use Rack::Flash, :sweep => true


helpers do
  def flash_types
    [:success, :notice, :warning, :error]
  end
end

#Some database configurations

configure :development do
  # at Development SQLlite will do fine
  
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

#Some configurations 
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

enable :method_override

  #include Helpers module
  helpers ApplicationHelper
  helpers SearchHelper
  helpers SessionHelper
  helpers Sinatra::KtApiHelper

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

  #new User signup page
  get '/signup' do
    erb :signup
  end

  # Signup a new user, take POST arguments and try to create a new useraccount
  # flash message if something goes wrong
  post '/signup' do

     @user = UserAccount.new(:email => params[:email], 
                :password => params[:password], :password_confirmation => params[:password_confirmation],
                :keytechUserName =>params[:keytech_username],
                :keytechPassword => params[:keytech_password],
                :keytechAPIURL => params[:keytech_APIURL])
        if @user.save

          if UserAccount.hasKeytechAccess(@user)
            # OK, Access granted by API
            session[:user] = @user.id
            redirect '/'
          else
            flash[:warning] = "User access denied by keytech API."
          end
        else

          flash[:error] = @user.errors.full_messages
          redirect '/signup'
        end


  end

get '/account' do
  # Shows an edit page for current account
  @user = currentUser
  if @user
    erb  :account
  else
    redirect '/'
  end
end

put '/account' do
  user = currentUser
  puts params

  if user
    if params[:commitKeytechCredentials] == "Save"
      user.keytechAPIURL = params[:keytechAPIURL]
      user.keytechPassword = params[:keytechPassword]
      user.keytechUserName = params[:keytechUserName]
      
      if !user.save
        flash[:warning] = user.errors.full_messages
      end    
    end

    if params[:commitProfile] == "Save"
      # Do nothing! 
      # Currently not allowed to change email address!
    end

    if params[:commitPassword] == "Save"
      # Check for current Password
      if !params[:current_password]
        flash[:error] = "Password was empty"
        redirect '/account'
      end

      authUser =  UserAccount.authenticate(user.email, params[:current_password]) 
      if authUser
        password = params[:password]
        password_confirmation = params[:password_confirmation]

        if password.empty? && password_confirmation.empty?
            flash[:warning] = "New password can not be empty"
            redirect '/account'   
        end

        if password.eql? password_confirmation
          user.password = password
          user.password_confirmation = password_confirmation
          if !user.save
            flash[:error] = user.errors.full_messages
          end

        else
          flash[:error] = "Password and password confirmation did not match."
        end


      else
        flash[:error] = "Current password is invalid"
      end 



      puts params
    end

  else
    puts "No user found!"
  end

  # Return to account site
  redirect '/account'

end


  #login controller
  post '/login' do

    user = UserAccount.authenticate(params[:username],params[:passwd])

    if user
      session[:user] = user.id
      redirect '/search'
    else
      flash[:error] = "Invalid username or password"
      redirect '/'
    end
  end



  get "/logout" do
    session.destroy
    #KtApi.destroy_session

    flash[:notice] = "You have logged out."
    redirect '/'
  end

  get '/forgotpassword' do
    erb :forgotpassword
  end


  # redirects to a search page and fill search Data

  get '/search' do
    if session[:user]
      @result=findElements(params[:q])
      erb :search
    else 
        flash[:notice] = "(TBD: loged out or session invalid)"
       redirect '/'
    end
  end

  #Loads a element structure, if present
  get '/search/:elementKey' do
    if session[:user]
      @result=loadElementStructure(params[:elementKey])
      erb :search
    else
      flash[:notice] = "(TBD: logged out or session invalid)"
      redirect '/'
    end
  end




# Redirection for file download

# Image forwarding. Redirect classimages provided by API to another image directly fetched by API
get "/images/classimages/:classKey" do
   if session[:user]
      content_type "image/png"
      loadClassImage(params[:classKey])
    else
      flash[:notice] = "(TBD: logged out or session invalid)"
      redirect '/'
    end
end


get "/files/:elementKey/masterfile" do
   if session[:user]
      content_type "application/octet-stream"
      
      loadMasterfile(params[:elementKey])
    else
      flash[:notice] = "(TBD: logged out or session invalid)"
      redirect '/'
    end
end


end


# Get database up to date
DataMapper.auto_upgrade!





