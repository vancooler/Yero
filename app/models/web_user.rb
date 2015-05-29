class WebUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :venues

  validates_presence_of :first_name, :last_name, :business_phone

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




  def self.mixpanel_event(web_user_id, event)
    if !ENV['MIXPANEL_TOKEN'].blank?
      require 'mixpanel-ruby'
      tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
      u = WebUser.find_by_id(web_user_id)
      tracker.people.set(web_user_id.to_s, {
          '$first_name'       => u.first_name,
          '$last_name'        => u.last_name,
          '$email'            => u.email,
          '$phone'            => u.business_phone,
          'Business Name'     => u.business_name
      });
      tracker.track(web_user_id.to_s, event)
    end
  end
end
