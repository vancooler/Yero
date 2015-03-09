require 'clockwork'
require 'config/boot'
require 'config/environment'
module Clockwork
	handler do |job|
		puts "Running #{job}"
	end

	# handler receives the time when job is prepared to run in the 2nd argument
  	# handler do |job, time|
  	#   puts "Running #{job}, at #{time}"
  	# end

  	every(15.minutes, 'Push.Notifications') {User.network_open}
  	

  	# "clockwork clock.rb" in terminal to run the clockwork executable.
end