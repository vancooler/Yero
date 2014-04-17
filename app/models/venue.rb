class Venue < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :business_hours
  has_many :nightlies

  def tonightly
    Nightly.today_or_create(self)
  end
end
