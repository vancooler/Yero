class Venue < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :business_hours, dependant: :destroy
  has_many :nightlies
  has_many :rooms, dependent: :destroy
  has_many :winners
  has_many :participants, through: :rooms
  has_many :favourited_users, class_name: "FavouriteVenue"
  belongs_to :venue_network

  # Address is geocoded so it can be returned to the iOS client
  geocoded_by :address
  after_validation :geocode

  validates_presence_of :venue_network

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
end
