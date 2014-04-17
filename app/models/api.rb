class Api < ActiveRecord::Base

  before_create :create_key

  def create_key
    self.key = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Api.exists?(key: random_token)
    end
  end
end