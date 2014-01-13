


# Helps getting session information
module SessionHelper
	require_relative '../UserAccount'

def loggedIn?
	return session[:user] !=nil
end


def currentUser
	user = UserAccount.get(session[:user])
	return user
end

def sessionInvalidText
	return "You are logged out due to inactivity."
end


end
