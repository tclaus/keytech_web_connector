require 'sinatra/base'
require 'httparty'
require './KeytechElement'
require './EditorLayout'
require './EditorLayouts'

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
      #user = UserAccount.get(session[:user])
      user = currentUser
      #/elements/{ElementKey}/structure
      result = HTTParty.get(user.keytechAPIURL + "/elements/#{elementKey}/structure", 
                                        :basic_auth => {
                                              :username => user.keytechUserName, 
                                              :password => user.keytechPassword})

        @itemarray=result["ElementList"]
    end

    # Loads excact one Element
    # responseAttributes one of LISTER|EDITOR|NONE|ALL  - defaults to NONE
    # If set additional attributes are added to result
    def loadElement(elementKey,responseAttributes = "")
      user = currentUser
      #/elements/{ElementKey}/structure
      result = HTTParty.get(user.keytechAPIURL + "/elements/#{elementKey}?attributes=#{responseAttributes}", 
                                        :basic_auth => {
                                              :username => user.keytechUserName, 
                                              :password => user.keytechPassword})

        keytechElement = KeytechElement.new
        element = result["ElementList"][0]

        keytechElement.createdAt =  element['CreatedAt']
        keytechElement.createdBy =  element['CreatedBy']
        keytechElement.createdByLong =  element['CreatedByLong']
        keytechElement.changedAt =  element['ChangedAt']
        keytechElement.changedBy =  element['ChangedBy']
        keytechElement.changedByLong =  element['changedByLong']
        keytechElement.elementDescription =  element['ElementDescription']
        keytechElement.elementDisplayName =  element['ElementDisplayName']
        keytechElement.elementKey =  element['ElementKey']
        keytechElement.elementName =  element['ElementName']
        keytechElement.elementStatus =  element['elementStatus']
        keytechElement.elementTypeDisplayName =  element['ElementTypeDisplayName']
        keytechElement.elementVersion =  element['ElementVersion']
        keytechElement.hasVersions =  element['HasVersions']
        keytechElement.thumbnailHint =  element['ThumbnailHint']
        keytechElement.keyValueList = elementKey['KeyValueList']

        return keytechElement
    end


# Loads the thumbnail at the given key
  def loadElementThumbnail(thumbnailKey)
    # see: http://juretta.com/log/2006/08/13/ruby_net_http_and_open-uri/
    resource = "/elements/#{thumbnailKey}/thumbnail"
  #print "loaded: #{resource}"
    
    user = currentUser

    plainURI = user.keytechAPIURL.sub(/^https?\:\/\//, '').sub(/^www./,'')
    http = Net::HTTP.new(plainURI,443)
    http.use_ssl = true; 
    http.start do |http|
      req = Net::HTTP::Get.new(resource, {"User-Agent" =>
                            "keytech api downloader"})
      req.basic_auth(user.keytechUserName,user.keytechPassword)
      response = http.request(req)
  #print "response #{response}"   
      # return this!
      response.body
    end

  end

# Loads the editorlayout for this class
 def loadEditorLayout(elementKey)
      #user = UserAccount.get(session[:user])
      classKey =   elementKey.split(':')[0]

      user = currentUser
      #/elements/{ElementKey}/structure
      result = HTTParty.get(user.keytechAPIURL + "/classes/#{classKey}/editorlayout", 
                                              :basic_auth => {
                                              :username => user.keytechUserName, 
                                              :password => user.keytechPassword})


          editorLayouts = EditorLayouts.new # [] # creates an array
          
          maxWidth = 0
          maxHeight = 0

          result["DesignerControls"].each do |layoutElement| # go through JSON response and make gracefully objects
      

          editorlayout = EditorLayout.new
          editorlayout.attributeAlignment = layoutElement['AttributeAlignment']
          editorlayout.attributeName = layoutElement['AttributeName']
          editorlayout.controlType = layoutElement['ControlType']
          editorlayout.dataDictionaryID = layoutElement['DataDictionaryID']
          editorlayout.dataDictionaryType = layoutElement['DataDictionaryType']
          editorlayout.displayName = layoutElement['Displayname']
          editorlayout.font = layoutElement['Font']
          editorlayout.name = layoutElement['Name']
          editorlayout.position = layoutElement['Position']
          editorlayout.sequence = layoutElement['Sequence']
          editorlayout.size = layoutElement['Size']
          
          height = editorlayout.size['height'] + editorlayout.position['y']
          (maxHeight< height)? maxHeight= height : maxHeight

          width = editorlayout.size['width'] + editorlayout.position['x']
          (maxWidth< width)? maxWidth= width : maxWidth

          editorLayouts.layouts << editorlayout

        end
        # maxinale grösse und breite  berechnen und dem Objekt zuweisen, für View wichtig
        editorLayouts.maxWidth =  maxWidth
        editorLayouts.maxHeight = maxHeight
        return editorLayouts
    end

  end

  # Register this class
  helpers KtApiHelper

end
