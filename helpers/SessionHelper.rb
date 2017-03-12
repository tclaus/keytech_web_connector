

# Helps getting session information
module SessionHelper
	require_relative '../UserAccount'

	def loggedIn?
		return session[:user] !=nil
	end


	def currentUser
		user = UserAccount.get(session[:user])
		if user
			user.lastSeenAt = Time.now # Update the last action the user did
			user.save
		end	
		return user
	end

	def sessionInvalidText
		return "You are logged out due to inactivity."
	end

	def invalidUserNameOrPasswordText
		return "Invalid username or password"
	end 

end
