module SearchHelper


#Converts the nasty JSON Date format to something useful
def convertJsonDate(jsonDate)
 Time.at((jsonDate.gsub(/\D/, "").to_i - 200) /10000000).strftime("%F")
end


#1. Generate a URL with credentials and load and forward image from API (Nasty)
#2. Load the image to a local image store and reload it from local? 
#   Images are always the same, so caching is OK for classicons (not neccesarly Thumbnails, these can change over time)

def classImage(elementKey)
 baseURL = "https://api.keytech.de"
 resouerceURl = "/smallclassimage/"
 classKey =   elementKey.split(':')[0]

#Auth ? 
# By header ? 
# Hide the API source of the image!

 "<img src='#{baseURL}#{resouerceURl}#{classKey}' width='30' heigth='30'>"
end



end
