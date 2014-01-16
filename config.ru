#For Rackup Configuration needed. Rackup shows here and do whatever 'run' orders

require './KtApp'


#if memcache_servers = ENV["MEMCACHE_SERVERS"]
#  use Rack::Cache,
#    verbose: false,
#    metastore:   "memcached://#{memcache_servers}",
#    entitystore: "memcached://#{memcache_servers}"
#else
#use Rack::Cache,
#  :verbose     => true,
#  :metastore   => 'file:/var/cache/rack/meta',
#  :entitystore => 'file:/var/cache/rack/body'#
#
#end


run KtApp