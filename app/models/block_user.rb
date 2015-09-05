class BlockUser < ActiveRecord::Base
    belongs_to :target_user, class_name: "User"
    belongs_to :origin_user, class_name: "User"

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

	def self.blocked_users_json(user_id)
	    current_user = User.find_by_id(user_id)
	    if !current_user.nil?
			first_friends_id_array = BlockUser.where(:target_user_id => user_id).map{ |b| {'user_id' => b.origin_user_id, 'blocked_at' => b.created_at.to_i } }
			second_friends_id_array = BlockUser.where(:origin_user_id => user_id).map{ |b| {'user_id' => b.target_user_id, 'blocked_at' => b.created_at.to_i } }
			users = first_friends_id_array | second_friends_id_array
		    return_users = users.sort_by{ |hsh| hsh['blocked_at'] }.reverse
		    result = Jbuilder.encode do |json|
				json.array! return_users do |a|
					user = User.find_by_id(a['user_id'])
					if !user.nil? and !user.user_avatars.where(is_active: true).blank?
						json.blocked_at 	a['blocked_at']==0 ? 1440461834 : a['blocked_at']
						json.user 			user.user_object(current_user)
					end
				end
			end

			result = JSON.parse(result).delete_if(&:empty?)
			return result
		end
	end

end
