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
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? and !address_default? }

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
      else
        country
      end
    end
  end

  # collect nearby venus
  def self.nearby_networks(latitude, longitude, distance)
    types_array = VenueType.all.where("lower(name) not like ?", "%test%").map(&:id)
    types_array_string = [nil]
    types_array.each do |a|
      types_array_string << a.to_s
    end
    if latitude.nil? or longitude.nil?
      # :nocov:
      venues = Venue.geocoded.near([49, -123], distance, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
      # :nocov:
    else
      venues = Venue.geocoded.near([latitude, longitude], distance, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
    end

    if !types_array_string.blank?
      venues = venues.where(venue_type_id: types_array_string)
    end

    return venues
  end

  # collect colleges
  def self.colleges(latitude, longitude)
    types_array = VenueType.all.where("lower(name) like ?", "%campus%").map(&:id)
    types_array_string = [nil]
    types_array.each do |a|
      types_array_string << a.to_s
    end
    if latitude.nil? or longitude.nil?
      # :nocov:
      venues = Venue.geocoded.near([49, -123], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
      # :nocov:
    else
      venues = Venue.geocoded.near([latitude, longitude], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
    end

    if !types_array_string.blank?
      venues = venues.where(venue_type_id: types_array_string)
    end

    return venues
  end

  # collect nighlifes
  def self.nightlifes(latitude, longitude)
    types_array = VenueType.all.where("lower(name) not like ? AND lower(name) not like ? AND lower(name) not like ? AND lower(name) not like ?", "%test%", "%campus%", "%festival%", "%stadium%").map(&:id)
    types_array_string = [nil]
    types_array.each do |a|
      types_array_string << a.to_s
    end
    if latitude.nil? or longitude.nil?
      # :nocov:
      venues = Venue.geocoded.near([49, -123], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
      # :nocov:
    else
      venues = Venue.geocoded.near([latitude, longitude], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
    end

    if !types_array_string.blank?
      venues = venues.where(venue_type_id: types_array_string)
    end

    return venues
  end

  # collect stadiums
  def self.stadiums(latitude, longitude)
    types_array = VenueType.all.where("lower(name) like ?", "%stadium%").map(&:id)
    types_array_string = [nil]
    types_array.each do |a|
      types_array_string << a.to_s
    end
    if latitude.nil? or longitude.nil?
      # :nocov:
      venues = Venue.geocoded.near([49, -123], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
      # :nocov:
    else
      venues = Venue.geocoded.near([latitude, longitude], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
    end

    if !types_array_string.blank?
      venues = venues.where(venue_type_id: types_array_string)
    end

    return venues
  end

  # collect festivals
  def self.festivals(latitude, longitude)
    types_array = VenueType.all.where("lower(name) like ?", "%festival%").map(&:id)
    types_array_string = [nil]
    types_array.each do |a|
      types_array_string << a.to_s
    end
    if latitude.nil? or longitude.nil?
      # :nocov:
      venues = Venue.geocoded.near([49, -123], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
      # :nocov:
    else
      venues = Venue.geocoded.near([latitude, longitude], 10000000, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
    end

    if !types_array_string.blank?
      venues = venues.where(venue_type_id: types_array_string)
    end

    finished_festivals = venues.select{|x|  x.finished == true }
    
    if !finished_festivals.empty?
      venues = venues - finished_festivals
    end
    venues = venues.sort_by{|e| e.start_time.to_i}

    return venues
  end

  def self.near_venues(latitude, longitude, distance, without_featured_venues)
    types_array = VenueType.all.where("lower(name) not like ?", "%test%").map(&:id)
    types_array_string = Array.new
    types_array.each do |a|
      types_array_string << a.to_s
    end
    if latitude.nil? or longitude.nil?
      # :nocov:
      venues = Venue.geocoded.near([49, -123], distance, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
      # :nocov:
    else
      venues = Venue.geocoded.near([latitude, longitude], distance, units: :km).includes(:venue_avatars).where.not(venue_avatars: { id: nil })
    end
    if !types_array_string.blank?
      venues = venues.where(venue_type_id: types_array_string)
    end
    if !without_featured_venues

      # reorder it based on featured and featured order
      festival_ids = VenueType.all.where("lower(name) like ?", "%festival%").map(&:id)
      festivals_string = Array.new
      festival_ids.each do |a|
        festivals_string << a.to_s
      end
      festivals = Venue.where(venue_type_id: festivals_string)
      puts festivals.count
      featured_festivals = festivals.select{|x|  x.happen_now == true }
      finished_festivals = festivals.select{|x|  x.finished == true }
      if !featured_festivals.empty?
        other_venues = venues - featured_festivals
        featured_festivals = featured_festivals.sort_by{|e| e.end_time.to_i}
        puts 'FEST'
        featured_festivals.each do |f|
          puts f.id.to_s + ' -> ' + f.end_time.to_i.to_s
        end
        venues = featured_festivals + other_venues
      end
      if !finished_festivals.empty?
        venues = venues - finished_festivals
      end
      # featured_venues = venues.select{|x| !x.featured.nil? and x.featured }
      # if !featured_venues.empty?
      #   other_venues = venues - featured_venues
      #   featured_venues = featured_venues.sort_by{|e| e[:featured_order]}
      #   venues = featured_venues + other_venues
      # end
    else
      featured_venues = venues.select{|x| !x.featured.nil? and x.featured }
      if !featured_venues.empty?
        venues = venues - featured_venues
      end
    end
    return venues
  end

  def finished
    if !self.start_time.nil? and !self.end_time.nil? and !self.timezone.nil?
      now = Time.now
      if now.to_i >=  Venue.to_utc_timestamp(self.end_time, self.timezone)
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.to_utc_timestamp(time, timezone)
    Time.zone = timezone
    timestamp = (time.to_i - Time.zone.now.utc_offset)
    Time.zone = "UTC"
    return timestamp
  end


  def happen_now
    if !self.start_time.nil? and !self.end_time.nil? and !self.timezone.nil?
      now = Time.now
      if now.to_i >= Venue.to_utc_timestamp(self.start_time, self.timezone) and now.to_i < Venue.to_utc_timestamp(self.end_time, self.timezone)
        return true
      else
        return false
      end
    else
      return false
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

  def address_changed?
    address_line_one_changed? || city_changed? || state_changed? || country_changed?
  end

  def address_default?
    self.address == "375 Water St,Vancouver,BC,CA"
  end


  def self.venues_object(venues)
    # default_logo = ENV['DYNAMODB_PREFIX'] == 'Dev' ? 'https://s3-us-west-2.amazonaws.com/yero-development/static/avatar_venue_default.png?X-Amz-Date=20150709T223626Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=9362671e5feae095d12b06f732d8a8913da88d630c49359df3bbdbef90043d1a&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D' : 'https://s3-us-west-2.amazonaws.com/yero/static/avatar_venue_default.png?X-Amz-Date=20150709T223305Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=60bf8424d7242c66faee48bc0f4e2641a6fa2515cf65b7c9b81591bc0f074857&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D'
    
    data = Jbuilder.encode do |json|
      json.array! venues do |v|
        # logo = VenueLogo.where(venue_id: v.id).where(pending: false)
        images = VenueAvatar.where(venue_id: v.id).order(default: :desc)
        json.id v.id
        json.name (v.name.blank? ? '' : v.name.upcase)
        json.type  (!v.venue_type.nil? and !v.venue_type.name.nil?) ? v.venue_type.name : ''
        # json.address v.address_line_one
        # json.city v.city
        # json.state v.state
        json.longitude v.longitude
        json.latitude v.latitude
        # json.featured v.featured
        # json.featured_order v.featured_order
        if !images.empty?
          avatars = Array.new
          images.each do |i|
            avatars << i.avatar.url
          end
          json.images do
            json.array! avatars
          end
        end
        json.gimbal_name  (v.beacons.blank? ? '' : (v.beacons.first.key.blank? ? '' : v.beacons.first.key))
        # json.logo         logo.empty? ? default_logo : logo.first.avatar.url

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
    # logo = VenueLogo.where(venue_id: self.id).where(pending: false)
    # default_logo = ENV['DYNAMODB_PREFIX'] == 'Dev' ? 'https://s3-us-west-2.amazonaws.com/yero-development/static/avatar_venue_default.png?X-Amz-Date=20150709T223626Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=9362671e5feae095d12b06f732d8a8913da88d630c49359df3bbdbef90043d1a&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D' : 'https://s3-us-west-2.amazonaws.com/yero/static/avatar_venue_default.png?X-Amz-Date=20150709T223305Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=60bf8424d7242c66faee48bc0f4e2641a6fa2515cf65b7c9b81591bc0f074857&X-Amz-Credential=ASIAJ7GYIAH2JUPHPCIA/20150709/us-west-2/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=AQoDYXdzEGYakAL0EvQYrk9q5y0ZB2V%2BcdgPB88okptP4HYESiaazyMebzHkt1DChrrNXW/Hc/J3dg3lVHco5isUf5F6ecCAfulM8oG2ExUGTOVEOSxLlzWlyHF9jL8RyYYGTpMsZbG%2B6jMAI1oTXxNDwP790Za3HuFqC12OWsIghkUuQJ9cHuHg1wHCFl/isxQn8ZOQiI64fan4dKKKMvv12w6y1IOit1pKEKOl3N5mf/WYyD15eWLk3jR%2BdATS9Uan1wRDB5gBA6OG9r65ouRietn2sUO7FMvHsagF2RvL1HXM%2BKW9hXmy9fL1NXN9KireHlWXoAJXd9jSEcTNMX1Xd4oGj9eTa%2BS5f6s2Q23IcTbIzvU7/5psASC1yPusBQ%3D%3D'
    venue_object = {
      id:             self.id,
      first_name:     (self.name.blank? ? '' : self.name.upcase),
      type:            (!self.venue_type.nil? and !self.venue_type.name.nil?) ? self.venue_type.name : '',
      # address:    self.address_line_one,
      # city:  self.city,
      # state:         self.state,
      # country:         self.country,
      latitude:     self.latitude,
      longitude:     self.longitude,
      # featured:     self.featured,
      # featured_order:     self.featured_order,
      # venue_message: "Welcome to "+(self.name.blank? ? '' : self.name.upcase)+"! Open this Whisper to learn more about tonight.",
      images:         images,
      gimbal_name:  (self.beacons.blank? ? '' : (self.beacons.first.key.blank? ? '' : self.beacons.first.key)),
      # logo:         logo.empty? ? default_logo : logo.first.avatar.url
    }

    return venue_object
  end


  def upload_img(name)

    origin_img_url = 'http://s3-us-west-2.amazonaws.com/yero/Venues/'+name+'.jpg'
    downcase_img_url = 'http://s3-us-west-2.amazonaws.com/yero/Venues/'+name.downcase+'.jpg'
    res = Net::HTTP.get_response(URI.parse(origin_img_url))
    downcase_res = Net::HTTP.get_response(URI.parse(downcase_img_url))
    if res.code == '200'
      # current_order = UserAvatar.where(:user_id => user.id).where(:is_active => true).maximum(:order)
      
      avatar = VenueAvatar.new(venue: self, default: true)

      avatar.remote_avatar_url = origin_img_url
      avatar.save
    elsif downcase_res.code == '200'
      avatar = VenueAvatar.new(venue: self, default: true)

      avatar.remote_avatar_url = downcase_img_url
      avatar.save
    end
  end



  def self.import_single_record(venue_obj)
    name = venue_obj['Network Name'].nil? ? '' : venue_obj['Network Name']
    venue_name = venue_obj['List Name'].nil? ? '' : venue_obj['List Name']
    venue_type = venue_obj['Type'].nil? ? '' : venue_obj['Type'].titleize
    venue_address = venue_obj['Address'].nil? ? nil : venue_obj['Address']
    venue_city = venue_obj['City'].nil? ? nil : venue_obj['City']
    venue_state = venue_obj['State'].nil? ? nil : venue_obj['State']
    venue_country = venue_obj['Country'].nil? ? nil : venue_obj['Country']
    venue_zipcode = venue_obj['Zipcode'].nil? ? nil : venue_obj['Zipcode']
    latitude = venue_obj['Latitude'].nil? ? nil : venue_obj['Latitude'].to_f
    longitude = venue_obj['Longitude'].nil? ? nil : venue_obj['Longitude'].to_f
    timezone = venue_obj['Timezone'].nil? ? nil : venue_obj['Timezone']
    # Format: YYYY-MM-DDThh:mm
    start_time = venue_obj['Start Time'].nil? ? nil : venue_obj['Start Time']
    end_time = venue_obj['End Time'].nil? ? nil : venue_obj['End Time']
    venue_network = name.blank? ? '' : (name.split '_').first.titleize
    if type = VenueType.find_by_name(venue_type) and city_network = VenueNetwork.find_by_name(venue_network)
      if !name.blank? and !venue_name.blank?
        b = Beacon.find_by_key(name)
        if b 
          b.update(:key => name)
          if !b.venue.nil?
            # update
            # if b.venue.draft_pending.nil? or !b.venue.draft_pending
            #   b.venue.update(:pending_name => venue_name, :pending_address => venue_address, :pending_city => venue_city, :pending_state => venue_state, :pending_country => venue_country, :pending_zipcode => venue_zipcode, :pending_venue_type_id => type.id, :venue_network_id => city_network.id, :draft_pending => true)
            # end
            if b.venue.venue_avatars.blank?
              b.venue.upload_img(name)
            end
          else
            # create
            venue = Venue.create!(:name => venue_name, :timezone => timezone, :start_time => start_time, :end_time => end_time, :pending_name => venue_name, :pending_address => venue_address, :pending_city => venue_city, :pending_state => venue_state, :pending_country => venue_country, :pending_zipcode => venue_zipcode, :pending_venue_type_id => type.id, :venue_network_id => city_network.id, :draft_pending => true, :pending_latitude => latitude, :pending_longitude => longitude)
            venue.upload_img(name)
            b.update(:venue_id => venue.id)
          end
        else
          # create both
          venue = Venue.create!(:name => venue_name, :timezone => timezone, :start_time => start_time, :end_time => end_time, :pending_name => venue_name, :pending_address => venue_address, :pending_city => venue_city, :pending_state => venue_state, :pending_country => venue_country, :pending_zipcode => venue_zipcode, :pending_venue_type_id => type.id, :venue_network_id => city_network.id, :draft_pending => true, :pending_latitude => latitude, :pending_longitude => longitude)
          venue.upload_img(name)
          Beacon.create!(:key => name, :venue_id => venue.id)
        end
      else
      end
      puts "FFF"
      puts type.inspect
      puts city_network.inspect
    else

    end
    return true
  end

  # :nocov:
  def self.import(file)

    CSV.foreach(file.path, headers: true) do |row|
      venue_obj = row.to_hash
      Venue.import_single_record(venue_obj)
      
    end
    return true
  end
  # :nocov:

end
