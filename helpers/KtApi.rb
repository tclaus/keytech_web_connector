require 'sinatra/base'
require './classes/KeytechElement'
require './classes/EditorLayout'
require './classes/EditorLayouts'
require './classes/KeytechElementFile'
require './classes/KeytechElementNote'
require './classes/KeytechElementStatusHistoryEntry'
require './classes/KeytechBomElement'
require './classes/KeytechBomElements'
require './classes/UserAccount'

module Sinatra

  # This makes a sinatra extension, with access to session variable
  module KtApiHelper

    # Finds all elements by a search text
    def findElements(searchstring)

        user = UserAccount.get(session[:user])

        typeString='default_do,default_fd,default_mi'
        # type=bla demo
        if (searchstring.start_with?('type='))
          # dann bis zum ersten leerzeichen suchen
          teststr = searchstring.partition('type=')[2]
          print "orgstr: " + searchstring
          print "test: " +teststr.strip
          typeString = teststr.strip
          searchstring = searchstring.partition(' ')[2] # Rechten Teil übergeben'
        end

        # keytech request here. Start Search


        result = HTTParty.get(user.keytechAPIURL + "/search",
                                        :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword},
                                        :query => {:q => searchstring,:classtypes=>typeString})

        if result.code == 200
          puts "Search OK"
        end


        if result.code !=200 && result.code !=403
         # flash[:notice] = "#{result.code}: #{result.message}"
         puts "keytech API Error " + result.code.to_s
         puts "header: " , response.headers.inspect
        end

        if result.code ==403
          # 403 = Unauthorized
          flash[:error] = "Unauthorized for API access. Please check keytech username and password in your account settings."
        end

        @PageNumber = result["PageNumber"]
        @TotalRecords = result["Totalrecords"]
        @PageSize = result["PageSize"]
        @SearchString = searchstring
        return result["ElementList"]
    end


    # Loads the BOM of the given elementKey
    def loadElementBom(elementKey)
      user = currentUser
      #/elements/{ElementKey}/structure
      result = HTTParty.get(user.keytechAPIURL + "/elements/#{elementKey}/bom",
                                        :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword})

        keytechBomElements = loadElementBomData(result)
        print " Bom loaded "
        return keytechBomElements
    end

private
  def loadElementBomData(result)

    bomItems = KeytechBomElements.new

     result["BomElementList"].each do |bomItem|
      newbomItem = KeytechBomElement.new

      # Unmwandeln des Arrays in eine Hash-Liste
      if bomItem["KeyValueList"]
          hash = {}
          bomItem["KeyValueList"].each do |pairs|
            hash[pairs['Key']] = pairs['Value']
          end
          newbomItem.keyValueList = hash
      end


      newbomItem.simpleElement = bomItem["SimpleElement"]

      bomItems.bomElements << newbomItem
    end
    return bomItems
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

        keytechElement = loadElementData(result)
        return keytechElement
    end

private
def loadElementData(result)
        keytechElement = KeytechElement.new
        element = result["ElementList"][0]

        keytechElement.createdAt =  element['CreatedAt']
        keytechElement.createdBy =  element['CreatedBy']
        keytechElement.createdByLong =  element['CreatedByLong']
        keytechElement.changedAt =  element['ChangedAt']
        keytechElement.changedBy =  element['ChangedBy']
        keytechElement.changedByLong =  element['ChangedByLong']
        keytechElement.elementDescription =  element['Description']
        keytechElement.elementDisplayName =  element['DisplayName']
        keytechElement.elementKey =  element['Key']
        keytechElement.elementName =  element['Name']
        keytechElement.elementStatus =  element['Status']
        keytechElement.elementTypeDisplayName =  element['ClassDisplayName']
        keytechElement.elementVersion =  element['Version']
        keytechElement.hasVersions =  element['HasVersions']
        keytechElement.thumbnailHint =  element['ThumbnailHint']
        keytechElement.keyValueList = element['KeyValueList']

        keytechElement.elementReleasedAt = element['ReleasedAt']
        keytechElement.elementReleasedBy = element['ReleasedBy']
        keytechElement.elementReleasedByLong = element['ReleasedByLong']

        return keytechElement
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

      return layoutFromResult(result)

    end


  # Loads the bill of material layout
def loadBomLayout
    user = currentUser
    plainURI = user.keytechAPIURL.sub(/^https?\:\/\//, '').sub(/^www./,'')

    bomLayoutData = settings.cache.get(plainURI + "_BOM")
    if !bomLayoutData

      #/elements/{ElementKey}/structure
      result = HTTParty.get(user.keytechAPIURL + "/classes/bom/listerlayout",
                                              :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword})

      bomLayoutData =  layoutFromResult(result)
      settings.cache.set(plainURI + "_BOM",bomLayoutData,60*60) #1 Stunde merken'
    end
    return bomLayoutData

  end

private
   def layoutFromResult(result)
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



# Loads the filelist of given element
 def loadElementFileList(elementKey)

      user = currentUser

      result = HTTParty.get(user.keytechAPIURL + "/elements/#{elementKey}/files",
                                              :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword})

      files = [] # crates an empty array

      result["FileInfos"].each do |elementFile| # go through JSON response and make gracefully objects

            file = KeytechElementFile.new
            file.fileID = elementFile['FileID']
            file.fileName = elementFile['FileName']
            file.fileSize = elementFile['FileSize']
            file.fileSizeDisplay = elementFile['FileSizeDisplay']
            # normalized filename erstellen ?
            files << file
          end
        return files
    end

 def loadElementNoteList(elementKey)

      user = currentUser

      result = HTTParty.get(user.keytechAPIURL + "/elements/#{elementKey}/notes",
                                              :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword})

      notes = [] # crates an empty array


      result["NotesList"].each do |note| # go through JSON response and make gracefully objects

            elementNote = KeytechElementNote.new
            elementNote.changedAt = note['ChangedAt']
            elementNote.changedBy = note['ChangedBy']
            elementNote.changedByLong = note['ChangedByLong']
            elementNote.createdAt = note['CreatedAt']
            elementNote.createdBy = note['CreatedBy']
            elementNote.createdByLong = note['CreatedByLong']
            elementNote.noteID = note['ID']
            elementNote.noteSubject = note['Subject']
            elementNote.noteText = note['Text'].gsub(/\u000d\u000a/,'<br>') #Replace poor mans CRLF.. (Windows crap!)
            elementNote.noteType = note['NoteType']

            notes << elementNote
      end
      return notes
    end

# every status change is archived in a status history
# (a element with status "Finish" must have been "at work" at some time)
def loadElementStatusHistory(elementKey)

      user = currentUser

      result = HTTParty.get(user.keytechAPIURL + "/elements/#{elementKey}/statushistory",
                                              :basic_auth => {
                                              :username => user.keytechUserName,
                                              :password => user.keytechPassword})

      history = [] # crates an empty array


      result["StatusHistoryEntries"].each do |historyentry| # go through JSON response and make gracefully objects

            entry = KeytechElementStatusHistoryEntry.new
            entry.description = historyentry['Description']
            entry.signedByList = historyentry['SignedByList']
            entry.sourceStatus = historyentry['SourceStatus']
            entry.targetStatus = historyentry['TargetStatus']


            history << entry
      end
      return history
    end

  end

  # Register this class
  helpers KtApiHelper

end
