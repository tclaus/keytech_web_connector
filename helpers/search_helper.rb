module SearchHelper


#Converts the nasty JSON Date format to something useful
def convertJsonDate(jsonDate)

 Time.at((jsonDate.gsub(/\D/, "").to_i - 200) /10000000).strftime("%F")

end


end
