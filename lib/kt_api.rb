module KtApi
  include HTTParty

  #base_uri 'https://api.keytech.de'
  #when setting this and remove that part from urls below you get this error:
  #<URI::InvalidURIError: the scheme http does not accept registry part: :80 (or bad hostname?)

  
  def self.set_session(sessionhash)
    @session=sessionhash
  end

  def self.destroy_session
    @session=nil
  end

  def self.find(searchstring)
      result = HTTParty.get("https://api.keytech.de/searchitems", :basic_auth => {:username => @session[:user], :password => @session[:passwd]}, :query => {:q => searchstring})
      @itemarray=result["ElementList"]
  end

  def self.loadElementStructure(elementKey)
    #/elements/{ElementKey}/structure
      result = HTTParty.get("https://api.keytech.de/elements/#{elementKey}/structure", :basic_auth => {:username => @session[:user], :password => @session[:passwd]})
      @itemarray=result["ElementList"]



  end


  # User authorization
  def self.access_granted?(parameters)
  	userresponse= HTTParty.get("https://api.keytech.de/user/#{parameters[:username]}", :basic_auth => {:username => parameters[:username], :password => parameters[:passwd]})
  	@userdata=userresponse["MembersList"]
  	(userresponse.code==200) && (@userdata[0]["IsActive"])? true : false
  end

  def self.get_full_username
    fullname=@userdata[0]["LongName"]
  end
end