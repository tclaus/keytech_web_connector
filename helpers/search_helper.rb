module SearchHelper
require "net/https"
require "rexml/document"



	#Converts the nasty JSON Date format to something useful
	def convertJsonDate(jsonDate)
	 Time.at((jsonDate.gsub(/\D/, "").to_i - 200) /10000000).strftime("%F")
	end


	#1. Generate a URL with credentials and load and forward image from API (Nasty)
	#2. Load the image to a local image store and reload it from local? 
	#   Images are always the same, so caching is OK for classicons (not neccesarly Thumbnails, these can change over time)

	def classImage(elementKey)
	     
		 resourceURL = "/smallclassimage/"
		 classKey =   elementKey.split(':')[0]

		 "<img src='/images/classimages/#{classKey}' width='20' heigth='20'>"
	end

	# Returns "DO", "FD" or "MI" to identify the type of element 
	def classType(elementKey)
		classKey =   elementKey.split(':')[0]
		print "classkey=#{classKey}"
		if classKey.end_with?('_MI')
			return "MI"
		end

		if classKey.end_with?('_FD')
			return "FD"
		end

		# easy: in all other cases: It must be an document.. 
		return "DO"
	end


	#Generate an return link to masterfile - route
	def link_to_masterfile(elementKey)
		"/files/#{elementKey}/masterfile"
	end


	#generates a download-URL for the masterfile for the given elementKey
	def loadMasterfile(elementKey)

		resource = "/elements/#{elementKey}/masterfile"
	 print "Loading: #{resource} "

		#print "Username: #{session[:user]}, pw: #{session[:passwd]}"

		http = Net::HTTP.new("api.keytech.de",443)
		http.use_ssl = true; 
		http.start do |http|
			req = Net::HTTP::Get.new(resource, {"User-Agent" =>
        										"keytech api downloader"})
			req.basic_auth(session[:user],session[:passwd])
			response = http.request(req)
	print "response: #{response}"		

			# return this as a file attachment
			attachment( response["X-Filename"])  #Use the sinatra helper to set this as filename

			response.body

 			
		end
	end



def loadClassImage(classKey)
		# see: http://juretta.com/log/2006/08/13/ruby_net_http_and_open-uri/
		#resp = href=""
		resource = "/smallclassimage/#{classKey}"
#print "loaded: #{resource}"

		http = Net::HTTP.new("api.keytech.de",443)
		http.use_ssl = true; 
		http.start do |http|
			req = Net::HTTP::Get.new(resource, {"User-Agent" =>
        										"keytech api downloader"})
			req.basic_auth(session[:user],session[:passwd])
			response = http.request(req)
	#print "response #{response}"		
			# return this!
			response.body

 			
		end

	end


end





