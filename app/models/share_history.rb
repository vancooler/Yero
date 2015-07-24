class ShareHistory < ActiveRecord::Base
  # A beacon has a unique ID

  belongs_to :share_reference

  # before_save :default_room


  # def default_room
  #   if self.room.nil?
  #     self.room = Room.create!
  #   end
  # end
end