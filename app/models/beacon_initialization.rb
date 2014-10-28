class BeaconInitialization 
  def initialize(beacon_name)
    # The beacon name identifies the City_venue_room_#_code
    # Examples:
    # Vancouver_Aubar_Dance_01_123123
    # Vancouver_Republic_bar-upstairs_01_001CFG

    beacon_relations_array = beacon_name.split("_")
    @venue_network_name = beacon_relations_array[0]
    @venue_name = beacon_relations_array[1]
    @room_name = beacon_relations_array[2]
    @beacon_key = beacon_name
  end
  def create
      network = create_network(@venue_network_name)
      venue = create_venue(@venue_name, network)
      room = create_room(@room_name, venue.id)
      beacon = create_beacon(@beacon_key, room.id)
      return beacon
  end

#TODO : Sanitize the parameters for the active record calls below
  private
    def create_network(network_name)
      vn = VenueNetwork.find_or_create_by(name: network_name)
      Rails.logger.info "VN: " + vn.name
      return vn
    end
    def create_venue(venue_name, network)
      venue = Venue.find_by(name: venue_name, venue_network_id: network.id) || Venue.new
      if venue.new_record?
        venue.name = venue_name
        venue.venue_network_id = network.id
        venue.email = "hello+#{venue_name}@yero.co"

        # ##TODO: double check the fields required in venue
        # venue.city = "Vancouver"
        # venue.state = "BC"
        # venue.country = "Canada"
        # venue.address_line_one = "970 Burrard St"
        # venue.zipcode = "whatever"
        # venue.venue_type_id = 1

        venue.save!
      end
      Rails.logger.info "V: " + venue.name
      return venue
    end
    def create_room(room_name, venue_id)
      r = Room.find_or_create_by(name: room_name, venue_id: venue_id)
      Rails.logger.info "R: " + r.name
      return r
    end
    def create_beacon(beacon_name, room_id)
      beacon = Beacon.find_or_create_by(key: beacon_name, room_id: room_id)
      Rails.logger.info "B: " + beacon.key
      return beacon
    end
end