require "net/https"
require "rexml/document"
#require_relative "./SessionHelper"


module SearchHelper



	# TODO: Load images locally
	#1. Generate a URL with credentials and load and forward image from API (Nasty)
	#2. Load the image to a local image store and reload it from local?
	#   Images are always the same, so caching is OK for classicons (not neccesarly Thumbnails, these can change over time)

	def classImageTemplate(elementKey)
	     if elementKey
		 	classKey =   elementKey.split(':')[0]
		 	#TODO: Load high-res images on retina devices
		 	"<img class='smallclassimage' src='/classes/#{classKey}/smallimage' width='20' heigth='20'>"
		end
	end

	# Returns "DO", "FD" or "MI" to identify the type of element
	def classType(elementKey)
		if elementKey
			classKey =   elementKey.split(':')[0]
			if classKey.end_with?('_MI')
				return "MI"
			end

			if classKey.end_with?('_FD')
				return "FD"
			end
		end
		# easy: in all other cases: It must be an document..
		return "DO"
	end


	#Generate an return link to masterfile - route
	def link_to_masterfile(elementKey)
		"/files/#{elementKey}/masterfile"
	end

	# Loads a file from the keytech API and returns it
	def loadFile(elementKey,fileID)
	 #files/:elementKey/files/:fileID"
	 	resource = "/elements/#{elementKey}/files/#{fileID}"
	 	print "Loading file: #{resource} "

		#print "Username: #{session[:user]}, pw: #{session[:passwd]}"
		user = currentUser

		plainURI = user.keytechAPIURL.sub(/^https?\:\/\//, '').sub(/^www./,'')
		response = HTTParty.get(user.keytechAPIURL + resource,
																		:basic_auth => {
																					:username => user.keytechUserName,
																					:password => user.keytechPassword})

			# return this as a file attachment
			attachment( response["X-Filename"])  #Use the sinatra helper to set this as filename
			response.body
	end

	# Starts the download for the masterfile of the given element
	def loadMasterfile(elementKey)

		resource = "/elements/#{elementKey}/files/masterfile"
	 	print "Loading: #{resource} "

		#print "Username: #{session[:user]}, pw: #{session[:passwd]}"
		user = currentUser

		response = HTTParty.get(user.keytechAPIURL + resource,
																		:basic_auth => {
																					:username => user.keytechUserName,
																					:password => user.keytechPassword})


			# return this as a file attachment
			attachment( response["X-Filename"])  #Use the sinatra helper to set this as filename
			response.body

	end

	def loadClassImage(classKey)
		# see: http://juretta.com/log/2006/08/13/ruby_net_http_and_open-uri/
		resource = "/classes/#{classKey}/smallimage"
		#print "loaded: #{resource}"

		user = currentUser

		plainURI = user.keytechAPIURL.sub(/^https?\:\/\//, '').sub(/^www./,'')

		# Image already loaded in memcache?

		tnData = settings.cache.get(plainURI + resource)
    	if !tnData
    		# if not, reload from keytech API

 			result = HTTParty.get(user.keytechAPIURL + resource,
                                        :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword})
			settings.cache.set(plainURI + resource,response.body)

			return result.body

		else
			return tnData
		end
	end

	# Loads the thumbnail at the given key
  def loadElementThumbnail(thumbnailKey)


    # Using Dalli and memcached
    resource = "/elements/#{thumbnailKey}/thumbnail"
    # print "loaded: #{resource}"

    user = currentUser

    plainURI = user.keytechAPIURL.sub(/^https?\:\/\//, '').sub(/^www./,'')

    tnData = settings.cache.get(plainURI + resource)
    if !tnData
      # Thumbnail für 1 std cachen
      puts "Thumbnail cache MISS "

      result = HTTParty.get(user.keytechAPIURL + resource,
                                        :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword})

      if result.code == 200
        settings.cache.set(plainURI + resource,response.body)
        # return this!
        return result.body  # Body contain image Data!
      else
        return nil
      end

    else
      puts "Thumbnail cache HIT! "
      return tnData
    end

  end

end
