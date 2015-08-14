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
      venue_1 = Venue.create!(id:1, venue_network: venue_network, name: "AAA", venue_type:venue_type, city: 'Vancouver', state: 'BC', country: 'Canada', zipcode: 'V7S1B2', address_line_one: '123 Granville Street')
      venue_2 = Venue.create!(id:2, venue_network: venue_network, name: "BBB", venue_type:venue_type, city: 'Vancouver', state: 'BC', country: 'Canada', zipcode: 'V7S1B2', address_line_one: '128 Granville Street')
      venue_3 = Venue.create!(id:3, venue_network: venue_network, name: "CCC", venue_type:venue_type, city: 'Vancouver', state: 'BC', country: 'Canada', zipcode: 'V7S1B2', address_line_one: '1232 Granville Street')
      venue_4 = Venue.create!(id:4, venue_network: venue_network, name: "DDD", venue_type:venue_type, city: 'Vancouver', state: 'BC', country: 'Canada', zipcode: 'V7S1B2', address_line_one: '1213 Granville Street')

      expect(JSON.parse(Venue.venues_object([venue_1, venue_2, venue_3, venue_4])).count).to eql 4
      # expect(venue_1.venue_object).to eql {:id =>1, :first_name=>"AAA", :type=>"Camput", :address=>"123 Granville Street", :city=>"Vancouver", :state=>"BC", :country=>"Canada", :latitude=>12, :longitude=>23, :featured=>false, :featured_order=>nil, :venue_message=> "Welcome to AAA! Open this Whisper to learn more about tonight.", :images=>[], :gimbal_name=>'', :logo=>'https://s3-us-west-2.amazonaws.com/yero-development/static/avatar_venue_default.png?X-Amz-Date=20150709T223626Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=9362671e5feae095d12b06f732d8a8913da88d630c49359df3bbdbef90043d1a&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D'}
      expect(venue_1.venue_object[:type]).to eql "Campus"

      expect(Venue.near_venues(49, -123, 100000, false).length).to eql 0
      venue_1.destroy
      venue_2.destroy
      venue_3.destroy
      venue_4.destroy
      venue_type.destroy
      venue_network.destroy
    end
  end
end
