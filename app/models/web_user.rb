class WebUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :venues

  validates_presence_of :first_name, :last_name, :city, :business_phone

  def country_name
    if !country.nil?
      country_code = ISO3166::Country[country]
      if !country_code.nil?
        country_code.translations[I18n.locale.to_s] || country_code.name
      end
    end
  end

  def name
  	(self.first_name.nil? ? '' : self.first_name + ' ') + (self.last_name.nil? ? '' : self.last_name)
  end
end
