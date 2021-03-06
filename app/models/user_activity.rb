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

  def self.table_prefix
    dynamo_db_table_prefix = ''
    if !ENV['DYNAMODB_PREFIX'].blank?
      dynamo_db_table_prefix = ENV['DYNAMODB_PREFIX']
    end
    return dynamo_db_table_prefix
  end

  #create enter/leave beacon log in AWS DynamoDB
  def self.create_in_aws(user, action, trackable_type, trackable_id)
    table_name = UserActivity.table_prefix + 'UserActivity'
    v = UserActivity.shard(table_name).new
    v.user_id = user.id
    v.action = action
    v.timestamp = Time.now
    v.since_1970 = (Time.now - Time.new('1970')).seconds.to_i
    v.trackable_type = trackable_type
    v.trackable_id = trackable_id
    v.save!

    return v
  end
end