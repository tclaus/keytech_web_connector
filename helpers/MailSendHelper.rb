# Sends a mail

require 'mail'
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

	

end