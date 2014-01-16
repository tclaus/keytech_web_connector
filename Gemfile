source "https://rubygems.org"
ruby '2.0.0'
gem 'sinatra' #, :github => "sinatra/sinatra"

# other dependencies
gem 'haml'
gem 'httparty'
gem 'rake'
gem 'sass'
gem 'compass'
gem 'sinatra-assetpack'
gem 'json'
gem 'sinatra-contrib'
gem 'rack-flash-session'
gem 'rack-flash3'
gem 'mail'
gem 'filesize'
gem 'memcachier'
gem 'dalli'
gem 'rack-cache'


group :production do
	gem 'pg'
	gem 'dm-postgres-adapter'
	gem 'unicorn'
end

group :development do
	gem 'rerun'
	gem 'dm-sqlite-adapter'
end


gem 'data_mapper'

# Payments

gem 'braintree'


# setup our test group and require rspec
group :test do
  gem 'rspec'
  gem 'capybara'
end