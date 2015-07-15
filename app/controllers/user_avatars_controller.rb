class UserAvatarsController < ApplicationController
  prepend_before_filter :get_api_token, except: [:create_avatar]
  before_action :authenticate_api, except: [:create_avatar]
  skip_before_filter  :verify_authenticity_token


  # work as swap avatars
  def swap_photos
    avatar_one = UserAvatar.find_by(user: current_user, id: params[:avatar_id_one])
    avatar_two = UserAvatar.find_by(user: current_user, id: params[:avatar_id_two])
    tmp_order = avatar_one.order.to_s
    avatar_one.order = avatar_two.order
    avatar_two.order = tmp_order.to_i

    if avatar_one.save 
      if avatar_two.save
        user_info = current_user.to_json(true)
        user_info['avatars'].each do |a|
          thumb = a['avatar']
          # a['thumbnail'] = thumb
          a['avatar'] = thumb.gsub! 'thumb_', ''
        end
        render json: success(user_info)
      else
        render json: error(avatar_two.errors)
      end
    else
      render json: error(avatar_one.errors)
    end
  end


  def set_default
    current_main_avatar = UserAvatar.find_by(user: current_user, default: true)
    if !current_main_avatar.nil?
      current_main_avatar.default = false
      if current_main_avatar.save        
        avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])
        if avatar
          if avatar.set_as_default
            # swap order
            current_main_avatar.order = avatar.order
            current_main_avatar.save
            avatar.order = 0
            avatar.save

            user_info = current_user.to_json(true)
            user_info["key"] = current_user.key
            # avatars = Array.new
            # user_info['avatars'].each do |avatar|
            #   if avatar['default'].to_s == "true"
            #     avatars.unshift(avatar)
            #   else
            #     avatars.push(avatar)
            #   end
            # end
            # user_info['avatars'] = avatars
            
            user_info['avatars'].each do |a|
              thumb = a['avatar']
              # a['thumbnail'] = thumb
              a['avatar'] = thumb.gsub! 'thumb_', ''
            end
            render json: success(user_info)
          else
            render json: error(avatar.errors)
          end
        else
          render json: error('Avatar could not be found.')
        end
      else
        ender json: error('Something wrong here, please contact the administrator.')
      end
    else
      avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])
      if avatar
        if avatar.set_as_default
          avatar.order = 0
          avatar.save
          user_info = current_user.to_json(true)
          user_info["key"] = current_user.key
            # avatars = Array.new
            # user_info['avatars'].each do |avatar|
            #   if avatar['default'].to_s == "true"
            #     avatars.unshift(avatar)
            #   else
            #     avatars.push(avatar)
            #   end
            # end
            # user_info['avatars'] = avatars
            
            user_info["avatars"].each do |a|
              thumb = a['avatar']
              # a['thumbnail'] = thumb
              a['avatar'] = thumb.gsub! 'thumb_', ''
            end
            render json: success(user_info)
        else
          render json: error(avatar.errors)
        end
      else
        render json: error('Avatar could not be found.')
      end
    end
  end

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
      user_info = current_user.to_json(true)
      
      user_info["avatars"].each do |a|
        thumb = a['avatar']
        # a['thumbnail'] = thumb
        a['avatar'] = thumb.gsub! 'thumb_', ''
      end
      render json: success(user_info)
      # render json: success(current_user.to_json(true))
    else
      render json: error(avatar.errors)
    end
  end


  ###################################################################
  #
  # Just create avatar before user register and return avatar id
  #
  ###################################################################
  def create_avatar
    avatar = UserAvatar.new(default: true)    
    avatar.avatar = params[:avatar]
    if avatar.save
      
      render json: success(avatar)
      # render json: success(current_user.to_json(true))
    else
      render json: error(avatar.errors)
    end
  end

  def destroy
    avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])
    active_avatars_number = current_user.user_avatars.where(:is_active => true).size
    if avatar and active_avatars_number > 1
      this_order = avatar.order
      if avatar.destroy
        UserAvatar.order_minus_one(current_user.id, this_order)

        user_info = current_user.to_json(true)
        user_info["avatars"].each do |a|
          thumb = a['avatar']
          a['avatar'] = thumb.gsub! 'thumb_', ''
        end
        render json: success(user_info)
      else
        render json: error(avatar.errors)
      end
    elsif avatar and active_avatars_number == 1
      render json: error("You must have at least one photo.")
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