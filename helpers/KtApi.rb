require 'sinatra/base'
require 'HTTParty'

module Sinatra

  # This makes a sinatra extension, with access to session variable
  module KtApiHelper
    include HTTParty

    require_relative '../UserAccount'

    # Finds all elements by a search text
    def findElements(searchstring)
        
        user = UserAccount.get(session[:user])

      
        result = HTTParty.get(user.keytechAPIURL + "/searchitems", 
                                        :basic_auth => {
                                              :username => user.keytechUserName, 
                                              :password => user.keytechPassword}, 
                                        :query => {:q => searchstring})

        if result.code !=200 || result.code !=403
         # flash[:notice] = "#{result.code}: #{result.message}"
        end

        if result.code ==403
          # 403 = Unauthorized
          flash[:error] = "Unauthorized for API access. Please check keytech username and password in your account settings."
        end


        @itemarray=result["ElementList"]
    end

    # Loads the underlying structure base an a given Element Key
    def loadElementStructure(elementKey)
      user = UserAccount.get(session[:user])
      #/elements/{ElementKey}/structure
      result = HTTParty.get(user.keytechAPIURL + "/elements/#{elementKey}/structure", 
                                        :basic_auth => {
                                              :username => user.keytechUserName, 
                                              :password => user.keytechPassword})

        @itemarray=result["ElementList"]
    end


    # # User authorization
    # def self.access_granted?(parameters)
    # 	userresponse= HTTParty.get("https://api.keytech.de/user/#{parameters[:username]}", :basic_auth => {:username => parameters[:username], :password => parameters[:passwd]})
    # 	@userdata=userresponse["MembersList"]
    # 	(userresponse.code==200) && (@userdata[0]["IsActive"])? true : false
    # end

    # def self.get_full_username
    #   fullname=@userdata[0]["LongName"]
    # end
  end

  # Register this class
  helpers KtApiHelper

end
