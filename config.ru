#\ --host 0.0.0.0
# ^ This is the rackup parameter to get access vom other domains than localhost


require 'bundler'
Bundler.require(:default)

require './App'

if memcache_servers = ENV["MEMCACHE_SERVERS"]
  	use Rack::Cache,
    	verbose: false,
    	metastore:   "memcached://#{memcache_servers}",
    	entitystore: "memcached://#{memcache_servers}"
else
	use Rack::Cache,
  		:verbose     => true,
  		:metastore   => 'file:/var/cache/rack/meta',
  		:entitystore => 'file:/var/cache/rack/body'#
end

# Finally run the app
run App
