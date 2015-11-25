class ShoutBannerImage < ActiveRecord::Base
	has_many :shouts
  	mount_uploader :avatar, ShoutBannerImageUploader

  	after_initialize :init

	def init
	  self.is_active  ||= true          #will set the default value only if it's nil
	end
end