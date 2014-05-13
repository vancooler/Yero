class Venue < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :business_hours
  has_many :nightlies
  has_many :rooms
  has_many :winners
  has_many :participants, through: :rooms

  geocoded_by :address
  after_validation :geocode

  # before_create :get_loc

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
    [self.address_line_one, self.city, self.state, self.country].compact.join(', ')
  end

  def get_loc
    require 'geocoder'

    loc = Geocoder.coordinates(address)
    if loc
      self.latitude = loc[0]
      self.longitude = loc[1]
    end
  end
end
