class WebUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :venues

  validates_presence_of :first_name, :last_name, :business_name,
    :address_line_1, :city, :state, :country, :zipcode, 
    :business_phone
end
