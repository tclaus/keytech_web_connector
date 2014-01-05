#For Rackup Configuration needed. Rackup shows here and do whatever 'run' orders

#enable sessions, for 900 seconds (15 minutes)
use Rack::Session::Pool, 
		:expire_after => 900, 
		:key => "KtApp", 
		:secret => "06c6a115a065cfd20cc2c9fcd2c3d7a7d354de3189ee58bce0240abd586db044"




require './KtApp'
run KtApp