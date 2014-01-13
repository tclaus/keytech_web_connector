#For Rackup Configuration needed. Rackup shows here and do whatever 'run' orders

require './KtApp'

if memcache_servers = ENV["MEMCACHE_SERVERS"]
  use Rack::Cache,
    verbose: true,
    metastore:   "memcached://#{memcache_servers}",
    entitystore: "memcached://#{memcache_servers}"
end


run KtApp