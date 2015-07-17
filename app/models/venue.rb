class Venue < ActiveRecord::Base

  has_many :business_hours, dependent: :destroy
  has_many :greeting_messages, dependent: :destroy
  has_many :nightlies
  has_many :beacons, dependent: :destroy
  has_many :winners
  has_many :participants, through: :rooms
  has_many :favourited_users, class_name: "FavouriteVenue"
  has_many :venue_avatars, dependent: :destroy
  belongs_to :web_user
  belongs_to :venue_network
  belongs_to :venue_type
  accepts_nested_attributes_for :beacons, allow_destroy: true
  accepts_nested_attributes_for :venue_avatars, allow_destroy: true

  # Address is geocoded so it can be returned to the iOS client
  geocoded_by :address
  after_validation :geocode

  has_many :venue_logos, dependent: :destroy
  accepts_nested_attributes_for :venue_logos, allow_destroy: true

  def logo
    self.venue_logos.order(:pending).first
  end

  def live_logo
    self.venue_logos.where(pending: false).first
  end

  scope :pending, ->{where("pending_name is not ? or pending_email is not ? or pending_venue_type_id is not ? or pending_phone is not ? or pending_address is not ? or pending_city is not ? or pending_state is not ? or pending_country is not ? or pending_zipcode is not ? or pending_manager_first_name is not ? or pending_manager_last_name is not ? or pending_latitude is not ? or pending_longitude is not ?", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)}
  scope :featured, ->{where("featured = ?", true)}
  # scope :all, ->{all}
  validates_presence_of :venue_network, :name

  def country_name
    if !country.nil?
      country_code = ISO3166::Country[country]
      if !country_code.nil?
        country_code.translations[I18n.locale.to_s] || country_code.name
      end
    end
  end

  def self.near_venues(latitude, longitude, distance)
    if latitude.nil? or longitude.nil?
      return Venue.geocoded.near([49, -123], distance, units: :km)
    else
      return Venue.geocoded.near([latitude, longitude], distance, units: :km)
    end
  end

  def default_avatar
    self.venue_avatars.where(default: true).first
  end

  def secondary_avatars
    self.venue_avatars.where.not(default: true)
  end

  def tonightly
    Nightly.today_or_create(self)
  end

  def to_json
    data = Jbuilder.encode do |json|
      json.name name
      json.address address_line_one
      json.longitude longitude
      json.latitude latitude
    end

    JSON.parse(data)
  end

  def address
    if !self.address_line_one.nil? and !self.address_line_one.empty?
      [self.address_line_one, self.city, self.state, self.country].compact.join(', ')
    else
      "375 Water St,Vancouver,BC,CA"
    end
  end


  def self.venues_object(venues)
    default_logo = ENV['DYNAMODB_PREFIX'] == 'Dev' ? 'https://s3-us-west-2.amazonaws.com/yero-development/static/avatar_venue_default.png?X-Amz-Date=20150709T223626Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=9362671e5feae095d12b06f732d8a8913da88d630c49359df3bbdbef90043d1a&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D' : 'https://s3-us-west-2.amazonaws.com/yero/static/avatar_venue_default.png?X-Amz-Date=20150709T223305Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=60bf8424d7242c66faee48bc0f4e2641a6fa2515cf65b7c9b81591bc0f074857&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D'
    
    data = Jbuilder.encode do |json|
      json.array! venues do |v|
        logo = VenueLogo.where(venue_id: v.id).where(pending: false)
        images = VenueAvatar.where(venue_id: v.id).order(default: :desc)
        json.id v.id
        json.name (v.name.blank? ? '' : v.name.upcase)
        json.type  (!v.venue_type.nil? and !v.venue_type.name.nil?) ? v.venue_type.name : ''
        json.address v.address_line_one
        json.city v.city
        json.state v.state
        json.longitude v.longitude
        json.latitude v.latitude
        json.featured v.featured
        json.featured_order v.featured_order
        if !images.empty?
          avatars = Array.new
          images.each do |i|
            avatars << i.avatar.url
          end
          json.images do
            json.array! avatars
          end
        end
        json.logo         logo.empty? ? default_logo : logo.first.avatar.url

        # json.nightly do
        #   nightly = Nightly.today_or_create(v)
        #   json.boy_count nightly.boy_count
        #   json.girl_count nightly.girl_count
        #   json.guest_wait_time nightly.guest_wait_time
        #   json.regular_wait_time nightly.regular_wait_time
        # end
      end
    end

    return data
  end

  def venue_object
    images = VenueAvatar.where(venue_id: self.id).order(default: :desc)
    logo = VenueLogo.where(venue_id: self.id).where(pending: false)
    default_logo = ENV['DYNAMODB_PREFIX'] == 'Dev' ? 'https://s3-us-west-2.amazonaws.com/yero-development/static/avatar_venue_default.png?X-Amz-Date=20150709T223626Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=9362671e5feae095d12b06f732d8a8913da88d630c49359df3bbdbef90043d1a&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D' : 'https://s3-us-west-2.amazonaws.com/yero/static/avatar_venue_default.png?X-Amz-Date=20150709T223305Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=60bf8424d7242c66faee48bc0f4e2641a6fa2515cf65b7c9b81591bc0f074857&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D'
    venue_object = {
      id:             self.id,
      first_name:     (self.name.blank? ? '' : self.name.upcase),
      type:            self.type,
      address:    self.address_line_one,
      city:  self.city,
      state:         self.state,
      country:         self.country,
      latitude:     self.latitude,
      longitude:     self.longitude,
      featured:     self.featured,
      featured_order:     self.featured_order,
      venue_message: "Welcome to "+(self.name.blank? ? '' : self.name.upcase)+"! Open this Whisper to learn more about tonight.",
      images:         images,
      logo:         logo.empty? ? default_logo : logo.first.avatar.url
    }

    return venue_object
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      venue_obj = row.to_hash
      puts venue_obj
      name = venue_obj['Name'].nil? ? '' : venue_obj['Name']
      venue_name = venue_obj['Venue Name'].nil? ? '' : venue_obj['Venue Name']
      venue_type = venue_obj['Type'].nil? ? '' : venue_obj['Type'].titleize
      venue_address = venue_obj['Address']
      venue_city = venue_obj['City']
      venue_state = venue_obj['State']
      venue_country = venue_obj['Country']
      venue_zipcode = venue_obj['Zipcode']
      venue_network = name.blank? ? '' : (name.split '_').first.titleize
      if type = VenueType.find_by_name(venue_type) and city_network = VenueNetwork.find_by_name(venue_network)
        if !name.blank? and !venue_name.blank?
          b = Beacon.find_by_key(name)
          if b 
            b.update(:key => name)
            if !b.venue.nil?
              # update
              b.venue.update(:name => venue_name, :address_line_one => venue_address, :city => venue_city, :state => venue_state, :country => venue_country, :zipcode => venue_zipcode, :venue_type_id => type.id, :venue_network_id => city_network.id)
            else
              # create
              venue = Venue.create!(:name => venue_name, :address_line_one => venue_address, :city => venue_city, :state => venue_state, :country => venue_country, :zipcode => venue_zipcode, :venue_type_id => type.id, :venue_network_id => city_network.id)
              b.update(:venue_id => venue.id)
            end
          else
            # create both
            venue = Venue.create!(:name => venue_name, :address_line_one => venue_address, :city => venue_city, :state => venue_state, :country => venue_country, :zipcode => venue_zipcode, :venue_type_id => type.id, :venue_network_id => city_network.id)
            Beacon.create!(:key => name, :venue_id => venue.id)
          end
        else
        end
      else

      end
    end
    return true
  end
end
