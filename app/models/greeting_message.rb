class GreetingMessage < ActiveRecord::Base


  # has_many :venue_avatars
  belongs_to :weekday
  belongs_to :venue
  has_many :greeting_posters, dependent: :destroy
  accepts_nested_attributes_for :greeting_posters, allow_destroy: true

  scope :pending, ->{where("draft_pending = ?", true)}

  def poster
  	self.greeting_posters.order(:default).first
  end

end