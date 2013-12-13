module SearchHelper

def title
	base_title = "keytech DEMO web application"
	if @title.nil?
		 base_title
	else
		"#{base_title} | #{@title}"
	end
end



#Converts the nasty JSON Date format to something useful
def convertJsonDate(jsonDate)

 Time.at((jsonDate.gsub(/\D/, "").to_i - 200) /10000000).strftime("%F")

end


end
