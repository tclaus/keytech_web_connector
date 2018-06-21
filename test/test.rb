require_relative '../App.rb'
require 'test/unit'
require 'rack/test'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  #include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def base_address_answers
    get '/'
    assert last_response.ok?
  end
end
