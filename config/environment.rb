# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

if !Rails.env.development
	Rails.logger = Le.new('6ba6068a-3f23-4223-a7e9-bbf0310deac0')
end
