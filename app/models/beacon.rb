class Beacon < ActiveRecord::Base
  # A beacon has a unique ID

  belongs_to :room
end