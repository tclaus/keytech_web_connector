
require 'rubygems'
require 'sinatra'
require 'data_mapper'

# Password recovery
class PasswordRecoveryList
	include DataMapper::Resource

property :id, Serial
property :email, String, :required => true, :length => (5..40), :unique => true, :format => :email_address
property :recoveryID, String, :writer =>:protected
property :salt, String, :required=>true, :writer =>:protected

property :created_at, DateTime, :writer=>:protected

before :valid?, :set_hashvalue

 
def isValid?
	# TODO
	# Check, if recovery is not too old
	
	difference = (Time.now - self.created_at.to_time) / 60

	# Only valid if younger than 15 minutes
	return difference <15
end



protected
def self.encrypt(value, salt)
	Digest::SHA1.hexdigest(value + salt)
end

     # our callback needs to accept the context used in the validation,
     # even if it ignores it, as #save calls #valid? with a context.
     def set_hashvalue(context = :default)
       	self.salt = (1..12).map{(rand(26)+65).chr}.join if !self.salt
    	self.recoveryID = UserAccount.encrypt(self.email, self.salt)
     end


end
