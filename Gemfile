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

gem 'rerun'

#Datamapper stuff, in production use postgres, in development SQLite
gem 'dm-core'
gem 'dm-migrations'
gem 'pg', :group => :production
gem 'dm-postgres-adapter', :group =>:production
gem 'dm-sqlite-adapter', :group =>:development



# setup our test group and require rspec
group :test do
  gem "rspec"
  gem "capybara"
end