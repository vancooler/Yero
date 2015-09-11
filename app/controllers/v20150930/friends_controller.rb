module V20150930  
  class FriendsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    def show
    	friend_id = params[:id]
    	friend = User.find_by_id(friend_id)
    	if friend.nil?
    	  error_obj = {
          code: 404,
          message: "Sorry, cannot find the friend",
          external_message: ''
        }
        render json: error(error_obj, 'data')
    	else
    	  if !FriendByWhisper.check_friends(current_user.id, friend.id) 
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it",
            external_message: ''
          }
          render json: error(error_obj, 'data')
        elsif BlockUser.check_block(current_user.id, friend.id) 
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it",
            external_message: ''
          }
          render json: error(error_obj, 'data')
        elsif friend.user_avatars.where(is_active: true).blank?        
        	error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it",
            external_message: ''
          }
          render json: error(error_obj, 'data')
        else
          friend_ship = FriendByWhisper.find_friendship(current_user.id, friend.id)
          if !friend_ship.nil? 
            friend_obj = friend_ship.to_json(friend, current_user)
            render json: success(friend_obj)
          else
            # :nocov:
            error_obj = {
              code: 404,
              message: "Sorry, cannot find the friend",
              external_message: ''
            }
            render json: error(error_obj, 'data')
            # :nocov:
          end
        end
    	end
    end

    def index
      # t0 = Time.now
      friends = WhisperNotification.myfriends(current_user.id)
      # t1 = Time.now
      if !friends.blank?
        page_number = nil
        friends_per_page = nil
        page_number = params[:page].to_i + 1 if !params[:page].blank?
        friends_per_page = params[:per_page].to_i if !params[:per_page].blank?

        if !page_number.nil? and !friends_per_page.nil? and friends_per_page > 0 and page_number >= 0
          friends = Kaminari.paginate_array(friends).page(page_number).per(friends_per_page) 
        end
        users = FriendByWhisper.friends_json(friends, current_user)
        users = JSON.parse(users).delete_if(&:blank?)
        users = users.sort_by { |hsh| hsh["timestamp"] }

        puts "USER ORDER:"
        puts users.inspect
        response_data = {
          friends: users.reverse
        }
      else
        response_data = {
          friends: Array.new
        }
      end
      # t3 = Time.now
      # puts "GETHER friends"
      # puts (t1-t0).inspect
      # puts "serialize friends"
      # puts (t3-t1).inspect

      render json: success(response_data, "data")
    end

    def destroy
      friend = FriendByWhisper.find_friendship(current_user.id, params[:id].to_i)
      if friend.nil?
        error_obj = {
          code: 404,
          message: "Friend cannot be found",
          external_message: ''
        }
        render json: error(error_obj, 'data')
      else
        if friend.destroy
          render json: success(true)
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot delete the friend.",
            external_message: ''
          }
          render json: error(error_obj, 'data')
          # :nocov:
        end

      end
    end

    private

    def get_api_token
      params[:token] = api_token if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
    end

  end
end