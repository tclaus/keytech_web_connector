source "https://rubygems.org"

gem 'sinatra', '~>1.4.0', :require => 'sinatra/base'


# other dependencies
gem 'haml'
gem 'httparty'
gem 'rake'
gem 'sass'
gem 'compass'
gem 'sprockets'
gem 'json'
gem 'sinatra-contrib'
gem 'pkg-config'
gem 'rack-flash-session'
gem 'rack-flash3'
gem 'mail'
gem 'filesize'
gem 'memcachier'
gem 'dalli'
gem 'rack-cache'
gem 'puma'

group :production do
	gem 'pg'
	gem 'dm-postgres-adapter'
end

group :development do
	gem 'rerun'
	gem 'dm-sqlite-adapter', '~> 1.2'
end

gem 'data_mapper', '~> 1.2.0'



# setup our test group and require rspec
group :test do
  gem 'rspec'
  gem 'capybara'
end