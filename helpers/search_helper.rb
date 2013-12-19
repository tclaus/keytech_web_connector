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
	     
	     #TODO: Hide the origin of the file !
		 
		 baseURL = "https://#{session[:user]}:#{session[:password]}@api.keytech.de"
		 resourceURL = "/smallclassimage/"
		 classKey =   elementKey.split(':')[0]

		#Auth ? 
		# By header ? 
		# Hide the API source of the image!
		downloadPath = "#{resourceURL}#{classKey}"
		#newLink = loadFileFromCache(downloadPath)

		 "<img src='#{baseURL}#{resourceURL}#{classKey}' width='20' heigth='20'>"
	end

	#generates a download-URL for the masterfile for the given elementKey
	def mainFileDownload(elementKey)

		#TODO: Hide the origin of the file !
		# Respource: /elements/{ElementKey}/files
		 baseURL = "https://#{session[:user]}:#{session[:password]}@api.keytech.de"
		 resourceURL = "/elements/#{elementKey}/masterfile"


		#Auth ? 
		# By header ? 
		# Hide the API source of the image!

		 "#{baseURL}#{resourceURL}"
	end

	#loads a file from given URL, adds a RESTFul basic authorization, stores it locally and maps a local link
	# def loadFileFromCache(fileLink)
	# 	# see: http://juretta.com/log/2006/08/13/ruby_net_http_and_open-uri/
	# 	#resp = href=""

	# 	http = Net::HTTP.new("api.keytech.de",443)
	# 	http.use_ssl = true; 
	# 	http.start do |http|
	# 		req = Net::HTTP::Get.new(fileLink, {"User-Agent" =>
 #        "keytech api downloader"})
	# 		req.basic_auth(session[:user],session[:password])
	# 		response = http.request(req)
	# 		#resp = response.body

	# 		open(Dir.tmpdir,"wb"){|file|
	# 			file.write(response.body)
	# 		}

	# 	end

	# end


end





