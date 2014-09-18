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
end