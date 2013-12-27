module ApplicationHelper

	  def title
		base_title = "keytech DEMO web application"
		if @title.nil?
			 base_title
		else
			"#{base_title} | #{@title}"
		end
	  end


	#Common Link Helper
	def link_to(url,text=url,opts={})
	  attributes = ""
	  opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
	  "<a href=\"#{url}\" #{attributes}>#{text}</a>"
	end

	# generates a flash message
	def showFlashMessage
		messageText = ""
		flash_types.select{ |kind| flash.has?(kind) }.each do |kind| 
			messageText.concat('<div class="notice ' + kind.to_s + '">')
  			messageText.concat(flash[kind].to_s)
			messageText.concat('</div>') 
		end

		return messageText
	end

	# Creates a link to a gravatar image
	def gravatar_helper(user)
	
	  # create the md5 hash
		hash = Digest::MD5.hexdigest(user.email.downcase)
 
		# compile URL which can be used in <img src="RIGHT_HERE"...
		image_src = "http://www.gravatar.com/avatar/#{hash}" 
		imageTag = '<a href="http://gravatar.com" target="_blank" class="gravatar" data-original-title="Change your avatar at Gravatar.&lt;br&gt;We are using #{user.email}">'
		imageTag.concat('<img srv="#{image_src}" class="avatar">')
		imageTag.concat('</a>')

		return imageTag
	end



end