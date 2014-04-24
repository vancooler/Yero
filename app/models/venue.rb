class Venue < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :business_hours
  has_many :nightlies
  has_many :rooms

  def tonightly
    Nightly.today_or_create(self)
  end

  def to_json
    data = Jbuilder.encode do |json|
      json.name name
      json.address address_line_one
    end

    JSON.parse(data)
  end
end
