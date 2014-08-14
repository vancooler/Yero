class Temperature < ActiveRecord::Base
  belongs_to :beacon
  validates_presence_of :beacon, :celsius
end
