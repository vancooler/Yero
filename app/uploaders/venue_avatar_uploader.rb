# encoding: utf-8

class VenueAvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include ::CarrierWave::Backgrounder::Delay
  
  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
     "https://s3.amazonaws.com/whisprdev/uploads/default_avatar.png"
  end
  
  # process :optimize
  # Process files as they are uploaded:
  # W320xH240 for profile photo
  # process :resize_to_fill => [320, 240]
  # process :quality => 100
  # #
  # # def scale(width, height)
  # #   # do something
  # # end

  # # Create different versions of your uploaded files:
  # version :thumb do
  #    process :resize_to_fit => [100, 100]
  #    process :quality => 100
  # end
  
end
