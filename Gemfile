source 'https://rubygems.org'
gem 'sinatra', :github => "sinatra/sinatra"

# other dependencies
gem 'haml'
gem 'httparty'
gem 'rake'
gem 'sass'
gem 'compass'
gem 'sinatra-assetpack'
gem 'json'
gem 'sinatra-contrib'
gem 'rack-flash3'

gem 'unicorn'  # Recommended web server for heroku installation

gem 'rerun'

#Datamapper stuff, in production use postgres, in development SQLite
gem 'data_mapper'
gem 'pg', :group => :production
gem 'dm-postgres-adapter', :group =>:production
gem 'dm-sqlite-adapter', :group =>:development


# Payments
require "braintree"


# setup our test group and require rspec
group :test do
  gem "rspec"
  gem "capybara"
end