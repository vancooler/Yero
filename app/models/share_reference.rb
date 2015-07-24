class ShareReference < ActiveRecord::Base
  # A beacon has a unique ID

  has_many :share_history

  # before_save :default_room


  # def default_room
  #   if self.room.nil?
  #     self.room = Room.create!
  #   end
  # end
end