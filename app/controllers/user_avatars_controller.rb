class UserAvatarsController < ApplicationController
  prepend_before_filter :get_api_token, except: [:create_avatar]
  before_action :authenticate_api, except: [:create_avatar]
  skip_before_filter  :verify_authenticity_token


  # work as swap avatars, not used yet
  # def swap_photos
  #   avatar_one = UserAvatar.find_by(user: current_user, id: params[:avatar_id_one])
  #   avatar_two = UserAvatar.find_by(user: current_user, id: params[:avatar_id_two])
  #   tmp_order = avatar_one.order.to_s
  #   avatar_one.order = avatar_two.order
  #   avatar_two.order = tmp_order.to_i

  #   if avatar_one.save 
  #     if avatar_two.save
  #       user_info = current_user.to_json(true)
  #       render json: success(user_info)
  #     else
  #       render json: error(avatar_two.errors)
  #     end
  #   else
  #     render json: error(avatar_one.errors)
  #   end
  # end

  # create new photo
  def create
    current_order = UserAvatar.where(:user_id => current_user.id).where(:is_active => true).maximum(:order)
    if !params[:avatar_id].nil?
      avatar_id = params[:avatar_id] 
      avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])

      if avatar.nil?
        avatar = UserAvatar.new(user: current_user)
        next_order = current_order.nil? ? 0 : current_order+1
        avatar.order = next_order
      end
    else  
      avatar = UserAvatar.new(user: current_user)
      next_order = current_order.nil? ? 0 : current_order+1
      avatar.order = next_order
    end
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

  # update a photo
  def update
    if !params[:avatar_id].nil? and !params[:avatar].nil?
      avatar_id = params[:avatar_id] 
      avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])

      if avatar.nil?
        render json: error("Photo cannot be found")
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
      render json: error("Invalid Parameters")
    end
  end

  # delete a photo
  def destroy
    avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])
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
      render json: error("Avatar not found.")
    end
  end

  private
  def get_api_token
    if api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
      params[:token] = api_token
    end
  end
end