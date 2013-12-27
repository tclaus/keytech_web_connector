
require 'rubygems'
require 'sinatra'
require 'data_mapper' 
require './UserAccount'

class Session
	include DataMapper::Resource

	belongs_to :userAccount


	property :id, Serial
	property :sessionID, String
	property :created_at, DateTime


end


# Get database up to date
#DataMapper.auto_upgrade!