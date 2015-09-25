class FriendByWhisper < ActiveRecord::Base


	def self.check_friends(origin_id, target_id)
		return !(FriendByWhisper.find_by_target_user_id_and_origin_user_id(target_id, origin_id) or FriendByWhisper.find_by_target_user_id_and_origin_user_id(origin_id, target_id)).nil?
          
	end

	def self.friends(user_id)
		first_friends_id_array = FriendByWhisper.where(:target_user_id => user_id).map(&:origin_user_id)
		second_friends_id_array = FriendByWhisper.where(:origin_user_id => user_id).map(&:target_user_id)
		users = first_friends_id_array | second_friends_id_array
	    return_users = Array.new
	    return_users = User.where(:id => users)
	    return return_users
	end

	def self.find_time(origin_id, target_id)
		if FriendByWhisper.find_by_target_user_id_and_origin_user_id(target_id, origin_id) 
			return FriendByWhisper.find_by_target_user_id_and_origin_user_id(target_id, origin_id).friend_time
		elsif FriendByWhisper.find_by_target_user_id_and_origin_user_id(origin_id, target_id)
			return FriendByWhisper.find_by_target_user_id_and_origin_user_id(origin_id, target_id).friend_time
		end
		return 0
    end

    def self.find_friendship(origin_id, target_id)
		if FriendByWhisper.find_by_target_user_id_and_origin_user_id(target_id, origin_id) 
			return FriendByWhisper.find_by_target_user_id_and_origin_user_id(target_id, origin_id)
		elsif FriendByWhisper.find_by_target_user_id_and_origin_user_id(origin_id, target_id)
			return FriendByWhisper.find_by_target_user_id_and_origin_user_id(origin_id, target_id)
		end
		return nil
    end


    def to_json(friend, current_user)
    	if !friend.nil?
          	user_object = friend.user_object(current_user)
          	response = {
          		notification_type: 3,
          		id: friend.id,
          		timestamp: self.friend_time.to_i,
          		timestamp_read: Time.at(self.friend_time.to_i),
          		viewed: self.viewed,
          		actions: ['chat', 'delete'],
          		object_type: "user",
	        	object: user_object
          	}
	        return response
	    else
	    	return nil
        end
    end


    def self.friends_json(return_users, current_user)
	    users = Jbuilder.encode do |json|
	      json.array! return_users.each do |user|
	        target_user = User.find_by_id(user["target_user"]["id"].to_i)
	        if !target_user.nil?
	          user_object = target_user.user_object(current_user)
	        end


	        json.notification_type 3
	        json.id user_object[:id] 

	        json.actions ['chat', 'delete']
	        json.timestamp  user["timestamp"]
	        json.timestamp_read  Time.at(user["timestamp"])
	        json.viewed user["viewed"].blank? ? 0 : user["viewed"]
	        json.object_type "user"
	        json.object user_object

	      end         
	    end
	    return users 
	end
end
