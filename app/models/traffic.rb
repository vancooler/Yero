class Traffic < ActiveRecord::Base
  belongs_to :room
  belongs_to :beacon
  belongs_to :user
end