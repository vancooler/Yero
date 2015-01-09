class EarlyVenue < ActiveRecord::Base
	validates_presence_of :username, :venue_name, :city, :phone, :email, :job_title
	validates :phone, :numericality => true
end
