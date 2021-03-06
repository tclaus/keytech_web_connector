
#
# Created by Thorsten Claus, December 2013
#

require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'data_mapper'
require 'httparty'

require './classes/Cipher'



# Privides access to user account and user to keytech mappings
class UserAccount
	include DataMapper::Resource


  attr_accessor :password, :password_confirmation


property :id, 							Serial
property :email, 						String, :required => true, :length => (5..40), :unique => true, :format => :email_address
property :fullname, 				String, :default =>""
property :password_hashed, 	String, :writer =>:protected
property :salt, 						String, :required=>true, :writer =>:protected

property :keytechUserName_crypted, String, :writer =>:protected
property :keytechPassword_crypted, String,  :writer =>:protected
property :keytechAPI_crypted, String, :length => 100, :writer =>:protected

property :is_admin, 				Boolean, :default => false, :accessor => :private

property :created_at, 			DateTime, :default => Time.now

# Links to the customerID of payment service
property :billingID, 				Integer, :default =>0

# Subscription ID for the Plan
property :subscriptionID, 	String, :default =>""

# last seen at. Provides the latest action the user has done
property :lastSeenAt, 			DateTime ,:default => Time.now

property :is_locked,				Boolean, :default => false

#validates_presence_of :password_confirmation
validates_confirmation_of :password


def isAdmin?
	# TODO: Admin - User in den Settings festlegen
	return true
end

def isAdmin=(isAdmin)
	is_admin = isAdmin
end

def keytechUserName=(username)

	if username.nil? || username.empty?
		self.keytechUserName_crypted = ""
		return
	end

	self.keytechUserName_crypted = Cipher.encrypt(username)
end

def keytechUserName
	if self.keytechUserName_crypted.nil? || self.keytechUserName_crypted.empty?

		# Should not be empty, if keytch default API is used
		#

		if self.keytechAPIURL.eql? keytechDefaultAPI
			return keytechDefaultUsername
		end


		return ""
	end

	Cipher.decrypt(self.keytechUserName_crypted)
end

def keytechPassword=(pass)

	if pass.nil? || pass.empty?
		self.keytechPassword_crypted = ""
		return
	end

	self.keytechPassword_crypted = Cipher.encrypt(pass)
end

def keytechPassword
	if keytechPassword_crypted.nil? || keytechPassword_crypted.empty?
		return ""
	end

	Cipher.decrypt(self.keytechPassword_crypted)
end

def keytechAPIURL=(apiURL)
	if apiURL.nil? || apiURL.empty?
		self.keytechAPI_crypted = ""
		return
	end

	if !apiURL.downcase.start_with?("http://", "https://")
		apiURL = "https://" + apiURL
	end

	self.keytechAPI_crypted = Cipher.encrypt(apiURL)
end

def keytechAPIURL
	if keytechAPI_crypted.nil? || keytechAPI_crypted.empty?
		return self.keytechDefaultAPI  # default API URL
	end

	Cipher.decrypt(self.keytechAPI_crypted)
end


# Authenticate a user based upon a (username or e-mail) and password
# Return the user record if successful, otherwise nil
def self.authenticate(email, pass)
	current_user = first(:email => email.downcase)
	return nil if current_user.nil? || UserAccount.encrypt(pass, current_user.salt) != current_user.password_hashed
	current_user
end

 # Set the user's password, producing a salt if necessary
 def password=(pass)
	@password = pass
    self.salt = (1..12).map{(rand(26)+65).chr}.join if !self.salt
    self.password_hashed = UserAccount.encrypt(@password, self.salt)
 end

 # This is the default keytech API URL for demo purposes
 #
def keytechDefaultAPI
	return ENV['KEYTECHDEMOURL'] || "https://demo.keytech.de"
end
# This is a valid demo user
def keytechDefaultUsername
	return ENV['KEYTECHDEMOUSER'] || "jgrant"
end


# The demo API has a special handling.
#
def usesDemoAPI?
 # in Development - Mode, access to all kinds of API is granted
	(self.keytechAPIURL.eql? self.keytechDefaultAPI) || ENV['RACK_ENV'].eql?("development")

end


# Checks if user has a valid subscription
#
def hasValidSubscription?
	return true
end

protected
def self.encrypt(pass, salt)
	Digest::SHA1.hexdigest(pass + salt)
end


# Returns true if this user has keytech access
def self.hasKeytechAccess(userAccount)
	# Check if usercredentioals have access to keytech API
    # User authorization

    if !userAccount.nil?

    	# Load User from API and check its 'Active' Property

    	userresponse = HTTParty.get(userAccount.keytechAPIURL + "/user/#{userAccount.keytechUserName}",
                                        :basic_auth => {
                                              :username => userAccount.keytechUserName,
                                              :password => userAccount.keytechPassword})

    	@userdata=userresponse["MembersList"]
    	(userresponse.code==200) && (@userdata[0]["IsActive"])? true : false

    else
    	# userAccount was nil
    	return false
    end
end

end
