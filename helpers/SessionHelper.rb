

require_relative '../UserAccount'

# Helps getting session information
module SessionHelper
	
	# Returns true if a valid user is logged in
	def loggedIn?
		return session[:user] !=nil
	end

	# Retuns the actiual loged in user
	def currentUser
		
		user = UserAccount.get(session[:user])
		if user
			user.lastSeenAt = Time.now # Update the last action the user did
			user.save
		end	
		return user
	end

	def userHasAdminRole?
		user = UserAccount.get(session[:user])
		if user
			return user.isAdmin
		end	
		return false

	end

	def sessionInvalidText
		return "You are logged out due to inactivity."
	end

	def invalidUserNameOrPasswordText
		return "Invalid username or password"
	end 

end
