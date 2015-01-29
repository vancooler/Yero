class ReportedUser < ActiveRecord::Base
	validates :key, :apn_token, :email, presence: true
	belongs_to :user
end