class Participant < ActiveRecord::Base
  belongs_to :room
  belongs_to :user

  before_save :update_activity

  # keeps track of the latest activity of a user
  def update_activity
    self.last_activity = Time.now
  end

  def self.enter_room(room, user)
    p = Participant.new
    p.room = room
    p.user = user
    p.save!
    return p
  end
end