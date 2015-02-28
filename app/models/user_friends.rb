class UserFriends < AWS::Record::HashModel
	integer_attr :user_id
	integer_attr :friend_id

	integer_attr :timestamp
	string_attr :created_date

	def self.create_in_aws(user1_id, user2_id)
		n = UserFriends.new
		n.user_id = user1_id
		n.friend_id = user2_id
		n.timestamp = Time.now
		n.created_date = Date.today.to_s
		n.save!
		return n
	end

	def self.return_friends(current_user_id)
		dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
	    table = dynamo_db.tables['UserFriends'] # Choose the 'WhisperNotification' table
	    table.load_schema # Load the table
	    friends = table.items.where(:friend_id).equals(current_user_id) # Select all users who's friend_id equals current user
	    friends_array = Array.new 
	    if friends and friends.count > 0
	    	friends.each do |friend|
	    		attributes = friend.attributes.to_h # Get attributes
        		friend_id = attributes['user_id'].to_i # Get the users_id (your friend's id)
	    		h = Hash.new
	    		if friend_id > 0
		            user = User.find(friend_id)
		            h['intro'] = user.introduction_1
		            h['target_user'] = user
		            if user.main_avatar
		              h['target_user_thumb'] = user.main_avatar.avatar.thumb.url
		              h['target_user_main'] = user.main_avatar.avatar.url
		              if user.secondary_avatars
		                h['target_user_secondary1'] = user.user_avatars.count > 1 ? user.secondary_avatars.first.avatar.url : ""
		                h['target_user_secondary2'] = user.user_avatars.count > 2 ? user.secondary_avatars.last.avatar.url : ""
		              end
		            end
		        else
		            h['target_user'] = ''
		        end
		          h['timestamp'] = attributes['timestamp'].to_formatted_s(:number) 
		          h['timestamp_read'] = attributes['timestamp'].strftime("%B %e, %Y")
		          friends_array << h     
	    	end
	    	users = Array.new
	        users = friends_array
	        users = users.sort_by { |hsh| hsh[:timestamp] }
	        p "users#afd"
	        p users.inspect
	        return users
	    end
	end
end