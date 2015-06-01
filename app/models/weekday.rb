class Weekday < ActiveRecord::Base
  
  has_many :greeting_messages, dependent: :destroy
  validates_uniqueness_of :weekday_title


  def name
    self.weekday_title.downcase if !self.weekday_title.blank?
  end
end