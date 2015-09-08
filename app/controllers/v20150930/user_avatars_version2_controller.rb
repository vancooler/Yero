module V20150930
  class UserAvatarsVersion2Controller < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2
    

    # create new photo
    def create
      current_order = UserAvatar.where(:user_id => current_user.id).where(:is_active => true).maximum(:order)
    
      avatar = UserAvatar.new(user: current_user)
      next_order = current_order.nil? ? 0 : current_order+1
      avatar.order = next_order
      avatar.is_active = true
      avatar.avatar = params[:avatar]
      if avatar.save
        avatar.origin_url = avatar.avatar.url
        avatar.thumb_url = avatar.avatar.thumb.url
        avatar.save
        user_info = current_user.to_json(true)
        
        
        render json: success(user_info)
      else
        error_obj = {
          code: 520,
          message: "Cannot create this photo"
        }
        render json: error(error_obj, 'data')
      end
    end

    # update a photo
    def update
      if !params[:id].nil? and !params[:avatar].nil?
        avatar_id = params[:id] 
        avatar = UserAvatar.find_by(user: current_user, id: params[:id])

        if avatar.nil?
          error_obj = {
            code: 404,
            message: "Photo cannot be found"
          }
          render json: error(error_obj, 'data')
        else
          avatar.avatar = params[:avatar]
          if avatar.save
            avatar.origin_url = avatar.avatar.url
            avatar.thumb_url = avatar.avatar.thumb.url
            avatar.save
            user_info = current_user.to_json(true)
            
            render json: success(user_info)
          else
            render json: error(avatar.errors)
          end
        end
      else  
        error_obj = {
          code: 400,
          message: "Invalid Parameters"
        }
        render json: error(error_obj, 'data')
      end
    end

    # delete a photo
    def destroy
      avatar = UserAvatar.find_by(user: current_user, id: params[:id])
      active_avatars_number = current_user.user_avatars.where(:is_active => true).size
      if avatar
        this_order = avatar.order
        if avatar.destroy
          UserAvatar.order_minus_one(current_user.id, this_order)

          user_info = current_user.to_json(true)
          render json: success(user_info)
        else
          render json: error(avatar.errors)
        end
      else
        error_obj = {
          code: 404,
          message: "Photo cannot be found"
        }
        render json: error(error_obj, 'data')
      end
    end

    private
    def get_api_token
      if api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
        params[:token] = api_token
      end
    end
  end
end