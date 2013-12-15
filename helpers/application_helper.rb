module ApplicationHelper

  def title
	base_title = "keytech DEMO web application"
	if @title.nil?
		 base_title
	else
		"#{base_title} | #{@title}"
	end
  end
end