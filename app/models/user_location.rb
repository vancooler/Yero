class UserLocation < AWS::Record::HashModel
  string_attr :user_id
  integer_attr :timestamp
  float_attr :latitude
  float_attr :longitude
  string_attr :timezone

  def self.table_prefix
    dynamo_db_table_prefix = ''
    if !ENV['DYNAMODB_PREFIX'].blank?
      dynamo_db_table_prefix = ENV['DYNAMODB_PREFIX']
    end
    return dynamo_db_table_prefix
  end

  #create user's location log in AWS DynamoDB
  def self.create_in_aws(user, latitude, longitude, timezone)
    table_name = UserLocation.table_prefix + 'UserLocation'
    l = UserLocation.shard(table_name).new
    l.user_id = user.id
    l.latitude = latitude
    l.timestamp = Time.now
    l.longitude = longitude
    if timezone.blank?
      l.timezone = "NG"
    else
      l.timezone = timezone
    end
    l.save!

    return l
  end

  def self.find_by_dynamodb_timezone(timezones)
    dynamo_db = AWS::DynamoDB.new
    table_name = UserLocation.table_prefix + 'UserLocation'
    table = dynamo_db.tables[table_name]
    table.load_schema
    # items = table.items.where(:timezone).equals(timezone.to_s)
    items = table.items.where(:timezone).in(*timezones).select(:user_id)
    null_items = table.items.where(:timezone).is_null.select(:user_id)

    user_ids = Array.new
    if items and items.count > 0
      items.each do |user|
        attributes = user.attributes # Turn the people into usable attributes
        if !attributes["user_id"].nil? 
          user_ids << attributes["user_id"].to_i
        end   
      end
    end
    if null_items and null_items.count > 0
      null_items.each do |user|
        attributes = user.attributes # Turn the people into usable attributes
        if !attributes["user_id"].nil? 
          user_ids << attributes["user_id"].to_i
        end   
      end
    end
    return user_ids
  end

  def self.find_if_user_exist(id, latitude, longitude, timezone)
    dynamo_db = AWS::DynamoDB.new
    table_name = UserLocation.table_prefix + 'UserLocation'
    table = dynamo_db.tables[table_name]
    table.load_schema
    items = table.items.where(:user_id).equals(id.to_s)
    if items.count > 0
      items.each do |i|
        i.attributes.update do |u|
          u.set 'latitude' => latitude
          u.set 'longitude' => longitude
          u.set 'timezone' => timezone
        end
      end
      return items
    else
      return false
    end
  end
end