class UserActivity < AWS::Record::HashModel
  string_attr :user_id
  integer_attr :timestamp
  string_attr :trackable_type
  string_attr :trackable_id
  string_attr :action
  integer_attr :since_1970

  # after_save :set_since_1970, :cache_activity_time_in_user_model

  scope :on_current_day, -> { where("timestamp >= :start_date AND timestamp <= :end_date", start_date: Time.now.beginning_of_day, end_date: Time.now.end_of_day) }
  scope :with_beacons, -> { where(trackable_type: "Beacon") }
  scope :for_user, ->(user_id) { where(:user_id => user_id)}

  def set_since_1970
    if self.since_1970.blank?
      self.update(since_1970: (self.timestamp - Time.new('1970')).seconds.to_i)
    end
  end
end