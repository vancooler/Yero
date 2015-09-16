module V20150930
  class UserAvatarsVersion2Controller < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2
    

    # create new photo
    def create
      if !params['avatar_url'].blank? and !params['thumb_url'].blank?
        current_order = UserAvatar.where(:user_id => current_user.id).where(:is_active => true).maximum(:order)
      
        avatar = UserAvatar.new(user: current_user)
        next_order = current_order.nil? ? 0 : current_order+1
        avatar.order = next_order
        avatar.is_active = true
        avatar.origin_url = params[:avatar_url]
        avatar.thumb_url = params[:thumb_url]
        if avatar.save
          user_info = current_user.to_json(true)
          render json: success(user_info)
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot create this photo"
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      else
        error_obj = {
          code: 400,
          message: "Invalid Parameters"
        }
        render json: error(error_obj, 'error')
      end
    end

    # update a photo
    def update
      if !params[:id].blank? and !params['avatar_url'].blank? and !params['thumb_url'].blank?
        avatar_id = params[:id] 
        avatar = UserAvatar.find_by(user: current_user, id: params[:id])

        if avatar.nil?
          error_obj = {
            code: 404,
            message: "Photo cannot be found"
          }
          render json: error(error_obj, 'error')
        else
          avatar_url = avatar.origin_url
          thumb_url = avatar.thumb_url

          avatar.origin_url = params[:avatar_url]
          avatar.thumb_url = params[:thumb_url]
          if avatar.save
            UserAvatar.remove_from_aws(avatar_url, thumb_url)
            user_info = current_user.to_json(true)
            render json: success(user_info)
          else
            # :nocov:
            error_obj = {
              code: 520,
              message: "Cannot update the photo."
            }
            render json: error(error_obj, 'error')
            # :nocov:
          end
        end
      else  
        error_obj = {
          code: 400,
          message: "Invalid Parameters"
        }
        render json: error(error_obj, 'error')
      end
    end

    # delete a photo
    def destroy
      avatar = UserAvatar.find_by(user: current_user, id: params[:id])
      active_avatars_number = current_user.user_avatars.where(:is_active => true).size
      if avatar
        this_order = avatar.order
        

        avatar_url = avatar.origin_url
        thumb_url = avatar.thumb_url

        if avatar.destroy
          UserAvatar.remove_from_aws(avatar_url, thumb_url)

          UserAvatar.order_minus_one(current_user.id, this_order)

          user_info = current_user.to_json(true)
          render json: success(user_info)
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot delete the photo."
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      else
        error_obj = {
          code: 404,
          message: "Photo cannot be found"
        }
        render json: error(error_obj, 'error')
      end
    end

    private
    def get_api_token
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        params[:token] = api_token 
      end
    end
  end
end