class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, polymorphic: true
  validates_presence_of :user
  after_save :set_since_1970
 
  private
    def set_since_1970
      if self.since_1970.blank?
        self.update(since_1970: (self.created_at - Time.new('1970')).seconds.to_i)
      end
    end
end
