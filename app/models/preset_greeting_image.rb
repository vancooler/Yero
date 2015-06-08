class PresetGreetingImage < ActiveRecord::Base

  	mount_uploader :avatar, PresetGreetingImageUploader

  	after_initialize :init

	def init
	  self.is_active  ||= false          #will set the default value only if it's nil
	end
end