module KtApi
  include HTTParty

  #base_uri 'https://api.keytech.de'
  #when setting this and remove that part from urls below you get this error:
  #<URI::InvalidURIError: the scheme http does not accept registry part: :80 (or bad hostname?)

  attr_accessor :itemarray

  def self.find(searchstring)
  
    
      result = HTTParty.get("https://api.keytech.de/searchitems", :basic_auth => {:username => "jgrant", :password => ""}, :query => {:q => searchstring})
      @itemarray=result["ElementList"]
  end

  # def self.access_granted?(user, password)
  # 	  @username=user
  # 	  @password=password
  # 	  userresponse= HTTParty.get("https://api.keytech.de/user/#{@username}", :basic_auth => {:username => @username, :password => @password})
  #     #(params[:username]=="jgrant") && (params[:passwd]=="")? true : false
  #     userdata=userresponse["MembersList"]
  #     case userresponse
  #     when userresponse.code=="200" && userdata[0]["IsActive"]=="true"
  #       true
  #     else
  #       false
  #     end
  #  end

  def self.access_granted?(parameters)
  	userresponse= HTTParty.get("https://api.keytech.de/user/#{parameters[:username]}", :basic_auth => {:username => parameters[:username], :password => parameters[:passwd]})
  	userdata=userresponse["MembersList"]
  	(userresponse.code==200) && (userdata[0]["IsActive"])? true : false


  end
end