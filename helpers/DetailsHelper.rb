
require 'sinatra/base'


  # This makes a sinatra extension, with access to session variable
  module DetailsHelper

  	# Is this the currentViewType? (Compare QueryString of URL, return class="active" if so. )
  	def currentViewType?(view="")
  		(request.query_string == view || (request.query_string =="" && view == "viewtype=information"))  ? 'class="active"' :nil
  	end

  end
