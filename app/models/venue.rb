class Venue < ActiveRecord::Base

  has_many :business_hours, dependent: :destroy
  has_many :greeting_messages, dependent: :destroy
  has_many :nightlies
  has_many :beacons, dependent: :destroy
  has_many :winners
  has_many :participants, through: :rooms
  has_many :favourited_users, class_name: "FavouriteVenue"
  has_many :venue_avatars
  belongs_to :web_user
  belongs_to :venue_network
  belongs_to :venue_type
  accepts_nested_attributes_for :beacons, allow_destroy: true
  accepts_nested_attributes_for :venue_avatars, allow_destroy: true

  # Address is geocoded so it can be returned to the iOS client
  geocoded_by :address
  after_validation :geocode

  scope :pending, ->{where("pending_name is not ? or pending_email is not ? or pending_venue_type_id is not ? or pending_phone is not ? or pending_address is not ? or pending_city is not ? or pending_state is not ? or pending_country is not ? or pending_zipcode is not ? or pending_manager_first_name is not ? or pending_manager_last_name is not ? or pending_latitude is not ? or pending_longitude is not ?", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)}

  validates_presence_of :venue_network, :name

  def country_name
    if !country.nil?
      country_code = ISO3166::Country[country]
      if !country_code.nil?
        country_code.translations[I18n.locale.to_s] || country_code.name
      end
    end
  end

  def self.near_venues(user, distance)
    if user.latitude.nil? or user.longitude.nil?
      return Venue.geocoded.near([49, -123], distance, units: :km)
    else
      return Venue.geocoded.near([user.latitude, user.longitude], distance, units: :km)
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
end
