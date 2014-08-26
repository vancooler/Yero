CarrierWave.configure do |config|

  fog_dir = Rails.env == 'production' ? ENV['S3_BUCKET_NAME'] : 'yero-development'

  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],     # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'], # required
    # :region                 => 'us-west-2'
  }
  config.fog_directory  = fog_dir                   # required
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end