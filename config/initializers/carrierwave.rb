require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|

  fog_dir = Rails.env == 'production' ? ENV['S3_BUCKET_NAME'] : 'yero-development'

  if Rails.env == 'production'
	  config.fog_credentials = {
	    :provider               => 'AWS',                        # required
	    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],     # required
	    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'], # required
	    # :region                 => 'us-west-2'
	  }
  end
  config.fog_directory  = fog_dir                   # required
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}

  if Rails.env.test? || Rails.env.cucumber?
	  CarrierWave.configure do |config|
	    config.storage = :file
	    config.enable_processing = false
	  end

		AvatarUploader #autoload the uploader

		# use different dirs when testing
	  CarrierWave::Uploader::Base.descendants.each do |klass|
	    next if klass.anonymous?
	    klass.class_eval do
	      def cache_dir
	        "#{Rails.root}/spec/support/uploads/tmp"
	      end

	      def store_dir
	        "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
	      end
	    end
	  end
	end
end