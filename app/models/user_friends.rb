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
	    table.load_schema 
	    friends = table.items.where(:user_id).equals(current_user_id)
	    friends_array = Array.new
	    friends_intro_whisper = WhisperNotification.collect_whispers(current_user)
	    if friends and friends.count > 0
	    	friends.each do |friend|
	    		attributes = friend.attributes.to_h
        		friend_id = attributes['friend_id'].to_i
	    		h = Hash.new
	    		if friends_array.include? friend_id
		          p 'in the array'
		        else
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
		          h['timestamp'] = attributes['timestamp'].to_i
		          
		          friends_array << h  
		          users = Array.new
		          users = friends_array
		          users = users.sort_by { |hsh| hsh[:timestamp] }
		          p "users#afd"
		          p users.inspect
		          return users.reverse
		        end 
	    	end
	    end
	end
end