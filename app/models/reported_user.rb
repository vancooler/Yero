class ReportedUser < ActiveRecord::Base
	validates :key, :apn_token, :email, :user_id, presence: true
	belongs_to :user
end