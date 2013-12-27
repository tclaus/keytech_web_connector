


# Helps getting session information
module SessionHelper
require_relative '../UserAccount'

def loggedIn?
	return !session[:user].nil?
end


 def keytechUsername(userID)
 
 	user = UserAccount.get(userID)

 	return user.keytechUserName
 end

def keytechPassword(userID)
 
 	user = UserAccount.get(userID)

 	return user.keytechPassword
 end

def currentUser
	user = UserAccount.get(session[:user])
	return user
end


end
