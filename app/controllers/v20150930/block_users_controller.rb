module V20150930
  class BlockUsersController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

  ############################################ API V 2 ############################################

    def index
      black_list = BlockUser.blocked_users_json(current_user.id)
          
      render json: success(black_list)
    end

    def destroy
      if !params[:id].nil?
        user_id = params[:id].to_i
        if User.exists? id: user_id
          if BlockUser.check_block(current_user.id, user_id)
            BlockUser.where(origin_user_id: current_user.id, target_user_id: user_id).delete_all
          end
          render json: success
        else
          error_obj = {
            code: 404,
            message: "Sorry, this user doesn't exist"
          }
          render json: error(error_obj, 'error')
        end
      else
          # :nocov:
          error_obj = {
            code: 400,
            message: "Invalid params"
          }
          render json: error(error_obj, 'error')
          # :nocov:
      end
    end
    

    # block user
    def create
      # user = current_user
      if !params[:user_id].nil?
        user_id = params[:user_id].to_i
        if User.exists? id: user_id
          if !BlockUser.check_block(current_user.id, user_id)
            BlockUser.create!(origin_user_id: current_user.id, target_user_id: user_id)
          end
          black_list = BlockUser.blocked_users_json(current_user.id)
          render json: success(black_list)
        else
          error_obj = {
      		  code: 404,
      		  message: "Sorry, this user doesn't exist"
    	    }
      		render json: error(error_obj, 'error')
        end
      else
        	error_obj = {
      		  code: 400,
      		  message: "Invalid params"
    	    }
      		render json: error(error_obj, 'error')
      end
    end


  ######################################### End of API V 2 #########################################

    private
    def get_api_token
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        params[:token] = api_token 
      end
    end


  end
end