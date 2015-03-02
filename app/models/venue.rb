class Venue < ActiveRecord::Base

  has_many :business_hours, dependent: :destroy
  has_many :nightlies
  has_many :rooms, dependent: :destroy
  has_many :winners
  has_many :participants, through: :rooms
  has_many :favourited_users, class_name: "FavouriteVenue"
  belongs_to :web_user
  belongs_to :venue_network
  belongs_to :venue_type

  # Address is geocoded so it can be returned to the iOS client
  geocoded_by :address
  after_validation :geocode

  validates_presence_of :venue_network, :name

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

  def timezone_city
    distinct_cities = Venue.select(:city, :state).distinct
    puts "DC"
    puts distinct_cities.inspect
  end

  def address
    [self.address_line_one, self.city, self.state, self.country].compact.join(', ')
  end
end
