require 'spec_helper'

describe Venue do
  it {should respond_to :email }
  it {should respond_to :name }
  it {should respond_to :address_line_one }
  it {should respond_to :address_line_two }
  it {should respond_to :city }
  it {should respond_to :state }
  it {should respond_to :country }
  it {should respond_to :zipcode }
  it {should respond_to :phone }
  it {should respond_to :dress_code }
  it {should respond_to :age_requirement }
  it {should respond_to :venue_type_id }
  it {should respond_to :longitude }
  it {should respond_to :latitude }
  it {should respond_to :venue_network_id }
  it {should respond_to :web_user_id }

  # let(:venue) { VenueType.new }
  # subject { venue }

  context "venue list" do
    it "test venues" do
      venue_network = VenueNetwork.create!(id:1, name: "V")
      venue_type = VenueType.create!(id:1, name:"Campus")
      venue_1 = Venue.create!(id:1, venue_network: venue_network, name: "AAA", venue_type:venue_type, country: "CA")
      venue_2 = Venue.create!(id:2, venue_network: venue_network, name: "BBB", venue_type:venue_type, country: "Canada")
      venue_3 = Venue.create!(id:3, venue_network: venue_network, name: "CCC", venue_type:venue_type, country: "CA")
      venue_4 = Venue.create!(id:4, venue_network: venue_network, name: "DDD", venue_type:venue_type, country: "CA")
      va = VenueAvatar.create!(id: 2, venue_id: Venue.first.id, default: true)
      birthday = (Time.now - 21.years)
      user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
      ua = UserAvatar.create!(id: 2, user: user_2, is_active: true, order: 0)

      expect(Venue.venues_object(User.first, [venue_1, venue_2, venue_3, venue_4]).count).to eql 4
      # expect(venue_1.venue_object).to eql {:id =>1, :first_name=>"AAA", :type=>"Camput", :address=>"123 Granville Street", :city=>"Vancouver", :state=>"BC", :country=>"Canada", :latitude=>12, :longitude=>23, :featured=>false, :featured_order=>nil, :venue_message=> "Welcome to AAA! Open this Whisper to learn more about tonight.", :images=>[], :gimbal_name=>'', :logo=>'https://s3-us-west-2.amazonaws.com/yero-development/static/avatar_venue_default.png?X-Amz-Date=20150709T223626Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=9362671e5feae095d12b06f732d8a8913da88d630c49359df3bbdbef90043d1a&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D'}
      expect(venue_1.venue_object[:type]).to eql "Campus"
      expect(venue_1.default_avatar.id).to eql 2
      expect(venue_1.secondary_avatars.count).to eql 0

      # expect(Venue.near_venues(49, -123, 100000, false).length).to eql 1
      expect(venue_1.country_name).to eql "Canada"
      expect(venue_2.country_name).to eql "Canada"
      expect(venue_2.to_json['name']).to eql "BBB"

      UserAvatar.delete_all
      User.delete_all
      va.delete
      venue_1.delete
      venue_2.delete
      venue_3.delete
      venue_4.delete
      venue_type.delete
      venue_network.delete
    end

    it "import csv venues" do
      venue_network = VenueNetwork.create!(id:1, name: "Vancouver")
      venue_type = VenueType.create!(id:1, name:"Campus")
      venue_obj = Hash.new
      venue_obj['Network Name'] = "Vancouver_UBC_Test"
      venue_obj['List Name'] = "UBC"
      venue_obj['Type'] = "Campus"
      venue_obj['Address'] = "730 E 20th ave"
      venue_obj['City'] = "Vancouver"
      venue_obj['State'] = "BC"
      venue_obj['Country'] = "CA"
      venue_obj['Zipcode'] = "V5V 1N3"
      Venue.import_single_record(venue_obj)

      expect(Venue.count).to eql 1
      expect(VenueType.first.id.to_s).to eql Venue.first.pending_venue_type_id.to_s
      # expect(Venue.near_venues(49, -123, 100000, false).length).to eql 1
      
      Venue.import_single_record(venue_obj)

      expect(Venue.first.logo).to eql nil
      expect(Venue.first.live_logo).to eql nil


      Venue.delete_all
      Beacon.delete_all
      venue_type.delete
      venue_network.delete
    end
  end
end
