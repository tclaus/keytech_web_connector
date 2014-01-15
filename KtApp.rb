  ## Remember to run 'bundle install' if something in Gemfile has changed!
## To now start the app run 'rackup -p 4567' instead of 'ruby kt.rb' !

require 'rubygems'
require 'bundler'

require 'sinatra/base'
require "sinatra/contrib/all"
require 'sinatra/assetpack'
require 'rack-flash'
require 'rack/flash/test'
require 'filesize'
require 'dalli'
require 'memcachier'
require 'rack/session/dalli'
require 'rack-cache'


require './UserAccount'
#require './helpers/KtApi'
#require './helpers/DetailsHelper'
require './PasswordRecoveryList'


Bundler.require(:default)


class KtApp < Sinatra::Base
  
  set :root, File.dirname(__FILE__)
  
  register Sinatra::Contrib
  register Sinatra::AssetPack

  require_relative "helpers/KtApi"
  require_relative "helpers/DetailsHelper"
  require_relative "helpers/SearchHelper"
  require_relative "helpers/ApplicationHelper"
  require_relative "helpers/SessionHelper"
  require_relative "helpers/MailSendHelper"
  

# Enable flash messages
use Rack::Flash, :sweep => true



helpers do
  def flash_types
    [:success, :notice, :warning, :error]
  end
end

#Some configurations

configure do
  
  # Set up Memcache
  dalliOptions={:expires_in =>1800} #30 minuten
  set :cache, Dalli::Client.new(nil,dalliOptions)

end



configure :development do
  

  
  #enable sessions, for 900 seconds (15 minutes)
  use Rack::Session::Pool, 
    :expire_after => 900, 
    :key => "KtApp", 
    :secret => "06c6a115a065cfd20cc2c9fcd2c3d7a7d354de3189ee58bce0240abd586db044"

  # at Development SQLlite will do fine
  
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  DataMapper.auto_upgrade!

  # Payments
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = "6d3bxmf7cd8g9m7s"
  Braintree::Configuration.public_key = "2tdfpxc79jtk4437"
  Braintree::Configuration.private_key = "ca0de6ffc93d667297cf6b533981316a"

  # Mail Send
  Mail.defaults do
      delivery_method :smtp, { :address              => "smtp.gmail.com",
                               :port                 => 587,
                               :user_name            => "vvanchesa@gmail.com",
                               :password             => "bla123_yuhuu",
                               :authentication       => :plain,   
                               :enable_starttls_auto => true  }

  end
  DataMapper.auto_upgrade!
end

#Some configurations 
configure :production do

  use Rack::Session::Dalli, 
    :cache => Dalli::Client.new,
    :expire_after => 900, # 15 minutes
    :key => 'keytech_web', # cookie name (probably change this)
    :secret => '06c6a115a065cfd20cc2c9fcd2c3d7a7d354de3189ee58bce0240abd586db044',
    :httponly => true, # bad js! No cookies for you!
    :compress => true,
    :secure => false, # NOTE: if you're storing user authentication information in session set this to true and provide pages via SSL instead of standard HTTP or, to quote nkp, "risk the firesheep!" Seriously, don't fuck around with this one.
    :path => '/'

  # A Postgres connection:
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
  # TODO: Payments als Production Code einbauen

  # Mail Send
  Mail.defaults do
      delivery_method :smtp, { :address              => "smtp.sendgrid.net",
                               :port               => 587,
                               :user_name            => ENV['SENDGRID_USERNAME'],
                               :password             => ENV['SENDGRID_PASSWORD'],
                               :authentication       => :plain,
                               :enable_starttls_auto => true  }

  end

  DataMapper.auto_upgrade!
end


  assets do

    serve '/js',     from: 'app/js'        # Default
    serve '/css',    from: 'app/css'       # Default
    serve '/images', from: 'app/images'    # Default

    js :application, [
      #'/js/vendor/custom.modernizr.js',
      '/js/popup.js'
      # You can also do this: 'js/*.js'
    ]

    js :body, [
      #'/js/vendor/jquery.js',
      #'/js/foundation.min.js'
      # You can also do this: 'js/*.js'
    ]

    css :application, [
      #'/css/normalize.css',
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
  helpers DetailsHelper
  helpers MailSendHelper

  # Routes
  # These are your Controllers! Can be outsourced to own files but I leave them here for now.


  #main page controller
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

    if params[:action].eql? "cancelPlan"
      print "Cancel Plan"
        # Cancel current subscription
        Braintree::Subscription.cancel(@user.subscriptionID)
        
        @user.subscriptionID = ""  # Remove subscriptionID
        @user.save
        redirect '/account'
        return
    end

    if params[:action].eql? "startPlan"
      print "Start Plan"
        # Start a new subscription. (Now without any trials)
        customer = Braintree::Customer.find(@user.billingID)
        if customer
            payment_method_token = customer.credit_cards[0].token

            result = Braintree::Subscription.create(
                      :payment_method_token => payment_method_token,
                      :plan_id => "silver_plan",
                      :options => {
                        :start_immediately => true # A recreated plan does not have a trial period
                      }
                    )

            @user.subscriptionID = result.subscription.id  # Add subscriptionID
            @user.save
            redirect '/account'

        else
          # Customer with this ID not found - remove from Customer
          @user.billingID = 0
          @user.save

          flash[:error] = "No customer record found. Please try again."
          redirect '/account'
        end
       
    end

  erb :account
    
  else
    redirect '/'
  end
end



put '/account' do
  user = currentUser

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

# Sets a credit card for current logged in user
get '/account/subscription' do

  @user = currentUser
  
  if @user
      if !@user.subscriptionID.empty?
        # A billing customer is already given
        # TODO: Eine Subscription kann gesetzt sein, auf 'Aktiv' - Status prüfen
        erb :showBillingPlan
      else
        erb :customerAccount
      end

    else
      redirect'/'
    end
 
end

# For Payment Data
post '/account/subscription' do
  result = Braintree::Customer.create(
    :first_name => params[:first_name],
    :last_name => params[:last_name],
    :credit_card => {
      :billing_address => {
        :postal_code => params[:postal_code]

      },
      :number => params[:number],
      :expiration_month => params[:month],
      :expiration_year => params[:year],
      :cvv => params[:cvv]
    }
  )
  if result.success?
    "<h1>Customer created with name: #{result.customer.first_name} #{result.customer.last_name}</h1>"
  
    currentUser.billingID = result.customer.id

    # Start the plan
    customer = result.customer
    payment_method_token = customer.credit_cards[0].token

    result = Braintree::Subscription.create(
      :payment_method_token => payment_method_token,
      :plan_id => "silver_plan" # This is teh default monthly plan
    )

    if result.success?
      "<h1>Subscription Status #{result.subscription.status}"
    else
      flash[:error] = result.message
      redirect '/create_customer'  
    end


  else

    # Something goes wrong
    flash[:error] = result.message 
    redirect '/create_customer'
  end
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

  get '/account/forgotpassword' do
    erb :"passwordManagement/forgotpassword"
  end

  # Send a password recovery link
  post '/account/forgotpassword' do
    # existiert diese Mail- Adrese ? 

    if params[:email].empty?
      flash[:warning] = "Enter a valid mail address"
      redirect '/account/forgotpassword'
      return
    end

    # Get user account by its mail
    user = UserAccount.first(:email => params[:email].to_s)

    if !user
      flash[:warning] = "This email address is unknown. Please enter a valid useraccount identified by it's email"
      redirect '/account/forgotpassword'
      return
    end

    # Delete all old password recoveries based in this email
    PasswordRecoveryList.all(:email => params[:email]).destroy
    
    # Generate a new password recovery pending entry
    newRecovery = PasswordRecoveryList.create(:email=> params[:email] )
    # Now send a mail
    if newRecovery
      sendPasswordRecoveryMail(newRecovery)
      flash[:notice] = "A recovery mail was send to #{params[:email]} please check your inbox."
      erb :"passwordManagement/recoveryMailSent"
    end

  end

  # Recovers lost password,if recoveryID is still valid in database
  get '/account/password/reset/:recoveryID' do
    if params[:recoveryID] 
      recovery = PasswordRecoveryList.first(:recoveryID => params[:recoveryID])
      print "Recovery: #{recovery}"

      if recovery
        if !recovery.isValid?
          recovery.destroy
          flash[:warning] = "Recovery token has expired"
          return erb :"passwordManagement/invalidPasswordRecovery"  

        end

        @user = UserAccount.first(:email => recovery.email.to_s)
        if @user
          print " User account found!"

          # Start a new password, if useraccount matches
          erb :"passwordManagement/newPassword"
        else
        flash[:warning] = "Can not recover a password from a deleted or disabled useraccount."
        erb :"passwordManagement/invalidPasswordRecovery"   
        end
        
      else
        flash[:warning] = "Recovery token not found or invalid"
        erb :"passwordManagement/invalidPasswordRecovery"   
      end

    else
      flash[:warning] = "Invalid page - a recovery token is missing."
      erb :"passwordManagement/invalidPasswordRecovery"
    end
  end
  
  # accepts a new password and assigns it to current user
  post '/account/password/reset/' do
    recovery = PasswordRecoveryList.first(:recoveryID => params[:recoveryID])
    print " Recovery: #{recovery}"
    if recovery
        user = UserAccount.first(:email => recovery.email.to_s)
        if user
          # Password check and store it
            print " User: #{user}"
            password = params[:password]
            password_confirmation = params[:password_confirmation]

            if password.empty? && password_confirmation.empty?
                flash[:warning] = "New password can not be empty"
                redirect '/account/password/reset/#{params[:recoveryID]}'   
            end

            if password.eql? password_confirmation
              user.password = password
              user.password_confirmation = password_confirmation
              if !user.save
                flash[:error] = user.errors.full_messages
              else
                # Everything is OK now
                print " Password reset: OK!"
                recovery.destroy
                flash[:notice] = "Your new password was accepted. Login now with you new password."
                redirect '/'
              end

            else
              flash[:error] = "Password and password confirmation did not match."
              redirect '/account/password/reset/#{params[:recoveryID]}'   
            end

        end
    end

  end


  #Loads a element detail, if present
  get '/elementdetails/:elementKey' do
    if currentUser
      @elementKey = params[:elementKey]

      if params[:format]=='json'
        elementData = loadElement(@elementKey,'ALL')
        return elementData.to_json
      end

      # OK, viewtype is relevant
      @element = loadElement(@elementKey)

      @detailsLink = "/elementdetails/#{params[:elementKey]}"
      @viewType = params[:viewType]
      

      erb :elementdetails
    else
      flash[:notice] = sessionInvalidText
      redirect '/'
    end
  end

  # redirects to a search page and fill search Data, parameter q is needed
  get '/search' do
    if currentUser
      if currentUser.usesDemoAPI? || currentUser.hasValidSubscription?
        

        @result= findElements(params[:q])
        erb :search
      else
        flash[:warning] = "You need a valid subscription to use a API other than the demo API. Go to the account page and check your current subscription under the 'Billing' area."
        erb :search
      end

    else 
        flash[:notice] = sessionInvalidText
       redirect '/'
    end
  end

get '/admin' do
  if loggedIn? && currentUser.isAdmin?
    @users=UserAccount.all
    erb :admin
  else
    flash[:notice] = "You are not logged in."
    redirect '/'
  end
end

get '/support' do
   "<h3> To Be Done </h3>"
end


get '/about' do
   "<h3> To Be Done </h3>"
end

get '/features' do
   "<h3> To Be Done </h3>"
end

get '/pricing' do
   "<h3> To Be Done </h3>"
end

# Redirection for file download

# Image forwarding. Redirect classimages provided by API to another image directly fetched by API
get "/images/classimages/:classKey" do
   if currentUser
      cache_control :public, mag_age:1800
      content_type "image/png"
      loadClassImage(params[:classKey])
    else
      flash[:notice] = sessionInvalidText
      redirect '/'
    end
end


get "/files/:elementKey/masterfile" do
   if currentUser
      content_type "application/octet-stream"
      
      loadMasterfile(params[:elementKey])
    else
      flash[:notice] = sessionInvalidText
      redirect '/'
    end
end

get "/files/:elementKey/files/:fileID" do
   if currentUser
      content_type "application/octet-stream"
      
      loadFile(params[:elementKey],params[:fileID])
    else
      flash[:notice] = sessionInvalidText
      redirect '/'
    end
end

get "/element/:thumbnailHint/thumbnail" do
   if currentUser
      content_type "image/png"
      loadElementThumbnail(params[:thumbnailHint])
    else
      flash[:notice] = sessionInvalidText
      redirect '/'
    end


end


end


# Get database up to date
DataMapper.auto_upgrade!





