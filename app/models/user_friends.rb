class UserFriends < AWS::Record::HashModel
	def self.create_in_aws(user1_id, user2_id)
		n = UserFriends.new
		n.user = user1_id
		n.friend = user2_id
		n.timestamp = Time.now
		n.created_date = Date.today.to_s
		n.save!
		return n
	end
end