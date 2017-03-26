

 # Represents a single layout element
 class EditorLayout
 	attr_accessor :attributeAlignment, :attributeName, :controlType, :dataDictionaryID, :dataDictionaryType
 	attr_accessor :displayName, :font, :name, :position, :sequence, :showInCardView, :size


 	def htmlStatement
 	 # Labels  <label for="attributename">text</label>
 	 # Textboxen
 	 # checkboxen
 	 # Multiline fields
 	 # 
 	 # Als Div - hovering machen ? 
 	 #print "generating HTML output...(#{controlType}) "

 	 positionAttribute = "style=\"position:absolute; left:#{position['x']}px ;top:#{position['y']}px; height:#{size['height']}px; width:#{size['width']}px; font-weight: normal; font-size: 12px;\""
	 attributeDataLink = "element.#{attributeName}"

 	 if controlType.eql? "LABEL"
 	 	label = "<label class=\"text-muted\" for=\"#{attributeName}\" #{positionAttribute} >#{displayName}</label>"
 	 	return label
 	 end

 	 if controlType=="TEXT"
 	 	inputTag = "<input type=\"text\" id=\"#{attributeName}\" #{positionAttribute} ng-model=\"#{attributeDataLink}\">"
 	 	return inputTag
 	 end
 	 
 	 if controlType=="CHECK"
 	 	inputTag = "<input type=\"checkbox\" id=\"#{attributeName}\"  #{positionAttribute} ng-model=\"#{attributeDataLink}\">"
 	 	return inputTag
 	 end

 	end


 end
