class UserLocation < AWS::Record::HashModel
  string_attr :user_id
  integer_attr :timestamp
  float_attr :latitude
  float_attr :longitude


  #create user's location log in AWS DynamoDB
  def self.create_in_aws(user, latitude, longitude)

    l = UserLocation.new
    l.user_id = user.id
    l.latitude = latitude
    l.timestamp = Time.now
    l.longitude = longitude
    l.save!

    return l
  end

  def self.find_by_dynamodb_timezone(timezones)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['UserLocation']
    table.load_schema
    # items = table.items.where(:timezone).equals(timezone.to_s)
    items = table.items.where(:timezone).in(*timezones)

    if items and items.count > 0
      return items
    else
      return nil
    end
  end

  def self.find_if_user_exist(id, latitude, longitude, timezone)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['UserLocation']
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