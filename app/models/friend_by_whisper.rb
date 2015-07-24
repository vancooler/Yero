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
end
