module KtApi
  include HTTParty


  attr_accessor :itemarray

  def self.find(searchstring)
  
    
      result = HTTParty.get("https://api.keytech.de/searchitems", :basic_auth => {:username => "jgrant", :password => ""}, :query => {:q => searchstring})
      @itemarray=result["ElementList"]
    

    end
end