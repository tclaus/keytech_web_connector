# Sends a mail

require 'mail'

require_relative '../UserAccount'
require_relative '../PasswordRecoveryList'


# prepaires and send a mail
#
module MailSendHelper
	
	# 
	def sendPasswordRecoveryMail(passwordRecovery)
		
		# Makes the link and adds the recoveryID
		# TODO: Distinguish between Development and Productive!
		localURL = ENV['localURL']
		recoveryLink = "http://#{localURL}/account/password/reset/#{passwordRecovery.recoveryID}"


		mailContent = File.read('./media/password_recoveryMail_EN.txt')
		mailContent.sub! ':senderService', 'claus-software'  # The name of the Service
		mailContent.sub! ':recoveryLink', recoveryLink  # The name of the Service
		# Switch placeholder with a link

		mail = Mail.new do
		  from    'noreply@claus-software.de'
		  to      passwordRecovery.email
		  subject 'Reset your password'
		  body    mailContent
		end

		if mail.deliver!
			print "Recovery Mail send"
		else
			print "Error sending mail"
		end


	end

	# Send a mail to the admin if a new user signsup (to remove later)
	def sendNewSignUpMail(theUser)
		
		mailContent = "New Usermail: " + theUser.email

		mail = Mail.new do
		  from    'noreply@claus-software.de'
		  to      'info@claus-software.de'
		  subject 'A new User has logged in to keytech Web App'
		  body    mailContent
		end 
		mail.deliver!
		
	
	end
end



