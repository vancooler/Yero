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
      venue = create_venue(@venue_name, network.id)
      room = create_room(@room_name, venue.id)
      beacon = create_beacon(@beacon_key, room.id)
      beacon
  end

#TODO : Sanitize the parameters for the active record calls below
  private
    def create_network(network_name)
      VenueNetwork.find_or_create_by(name: network_name)
    end
    def create_venue(venue_name, network_id)
      venue = Venue.find_by(name: venue_name, venue_network_id: network_id) || Venue.new
      if venue.new_record?
        venue.name = venue_name
        venue.venue_network_id = network_id
        venue.email = "hello+#{venue_name}@yero.co"
        venue.password = "whispr111"
        venue.password_confirmation = "whispr111"
        venue.save!
      end
      venue
    end
    def create_room(room_name, venue_id)
      Room.find_or_create_by(name: room_name, venue_id: venue_id)
    end
    def create_beacon(beacon_name, room_id)
      beacon = Beacon.find_or_create_by(key: beacon_name, room_id: room_id)
    end
end