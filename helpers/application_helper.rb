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

end