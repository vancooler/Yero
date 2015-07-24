class HomeController < ApplicationController



	def welcome_reference
		if mobile_device?
			if !params[:ref].blank?
				share_reference = ShareReference.find_by_name(params[:ref])
				if share_reference.nil?
					share_reference = ShareReference.create!(:name => params[:ref], :count => 1) 
				end
				ShareHistory.create!(:share_reference_id => share_reference.id)
			end
			@mobile = true
	    else
	    	@mobile = false
	    end

	end
end
