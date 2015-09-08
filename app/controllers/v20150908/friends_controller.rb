module V20150908
  class FriendsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api
    skip_before_filter  :verify_authenticity_token

    def show
    	friend_id = params[:id]
    	friend = User.find_by_id(friend_id)
    	if friend.nil?
    	  error_obj = {
          code: 404,
          message: "Sorry, cannot find the friend"
        }
        render json: error(error_obj, 'data')
    	else
    	  if !FriendByWhisper.check_friends(current_user.id, friend.id) 
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'data')
        elsif BlockUser.check_block(current_user.id, friend.id) 
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'data')
        elsif friend.user_avatars.where(is_active: true).blank?        
        	error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'data')
        else
          friend_ship = FriendByWhisper.find_friendship(current_user.id, friend.id)
          if !friend_ship.nil? 
            friend_obj = friend_ship.to_json(friend, current_user)
            render json: success(friend_obj)
          else
            error_obj = {
              code: 404,
              message: "Sorry, cannot find the friend"
            }
            render json: error(error_obj, 'data')
          end
        end


    	end


    end

    private

    def get_api_token
      if Rails.env == 'test' && api_token = params[:token].blank? && request.headers.env["X-API-TOKEN"]
        params[:token] = api_token
      end
      if Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
        params[:token] = api_token
      end
    end

  end
end