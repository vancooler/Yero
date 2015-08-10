class BlockUser < ActiveRecord::Base


	def self.check_block(origin_id, target_id)
		return !(BlockUser.find_by_target_user_id_and_origin_user_id(target_id, origin_id) or BlockUser.find_by_target_user_id_and_origin_user_id(origin_id, target_id)).nil?
          
	end

	def self.blocked_users(user_id)
		first_friends_id_array = BlockUser.where(:target_user_id => user_id).map(&:origin_user_id)
		second_friends_id_array = BlockUser.where(:origin_user_id => user_id).map(&:target_user_id)
		users = first_friends_id_array | second_friends_id_array
	    return_users = Array.new
	    return_users = User.where(:id => users)
	    return return_users
	end

	def self.blocked_user_ids(user_id)
		first_friends_id_array = BlockUser.where(:target_user_id => user_id).map(&:origin_user_id)
		second_friends_id_array = BlockUser.where(:origin_user_id => user_id).map(&:target_user_id)
		users = first_friends_id_array | second_friends_id_array
	    return users
	end

end
