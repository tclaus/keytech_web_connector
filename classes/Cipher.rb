# For symmetric crypting the keytech credentials
require 'openssl'
require 'digest/sha1'
require "base64"

# Encrypts and decypts a text symmetricaly
class Cipher

# Thanks to 
# http://stackoverflow.com/questions/4128939/simple-encryption-in-ruby-without-external-gems


  @@key = ""
  @@iv = ""

  @@cipher = nil 

  #   eine Art Singelton basteln

  def self.init
	# create the cipher for encrypting
 	if @@cipher == nil
		@@cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		@@key = Digest::SHA1.hexdigest("This is the keytech password - keep it secret!-")  # Hash the clear Text password!
  		
  		@@iv = "TC:01.06.1974000"  # Initialisierungsvektor, 16 Characters long


 	end

  end


#def keyphrase#
#	self.init
#	@@key
#end

#def iv
#	self.init
#	@@cipher.random_iv.length
#
#end

def self.encrypt(text)
	# encrypt the message
	self.init

	@@cipher.encrypt
	@@cipher.key = @@key
	@@cipher.iv = @@iv

	encrypted = @@cipher.update(text)
	encrypted << @@cipher.final
	
	#decode Binary string to charcterset
	charcters = Base64.encode64(encrypted)
	return charcters

end

def self.decrypt(encrypted)
	# now we create a sipher for decrypting
	self.init

	@@cipher.decrypt
	@@cipher.key = @@key
	@@cipher.iv = @@iv

	binaryCode = Base64.decode64(encrypted)

	# and decrypt it
	decrypted = @@cipher.update(binaryCode)
	decrypted << @@cipher.final
	# puts "decrypted: #{decrypted}\n"
	return decrypted
end



end