class UserAvatarsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  def set_default
    current_main_avatar = UserAvatar.find_by(user: current_user, default: true)
    if !current_main_avatar.nil?
      current_main_avatar.default = false
      if current_main_avatar.save        
        avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])
        if avatar
          if avatar.set_as_default
            user_info = current_user.to_json(false)
            avatars = Array.new
            user_info['avatars'].each do |avatar|
              if avatar['default'].to_s == "true"
                avatars.unshift(avatar)
              else
                avatars.push(avatar)
              end
            end
            user_info['avatars'] = avatars
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
          user_info = current_user.to_json(false)
            avatars = Array.new
            user_info['avatars'].each do |avatar|
              if avatar['default'].to_s == "true"
                avatars.unshift(avatar)
              else
                avatars.push(avatar)
              end
            end
            user_info['avatars'] = avatars
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
    if !params[:avatar_id].nil?
      avatar_id = params[:avatar_id] 
      avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])

      if avatar.nil?
        avatar = UserAvatar.new(user: current_user)
      end
    else  
      avatar = UserAvatar.new(user: current_user)
    end
    current_main_avatar = UserAvatar.find_by(user: current_user, default: true)
    avatar.avatar = params[:avatar]
    if avatar.save
      if params[:default].to_s == 'true'      
        logger.info "AVATAR HERE: " + params[:default].to_s
        if !current_main_avatar.nil? and current_main_avatar.id != avatar.id
          logger.info "NOT MAIN"
          current_main_avatar.default = false
          if current_main_avatar.save
            avatar.set_as_default 
          end
        else
          logger.info "Replace Main Avatar " + avatar.id.to_s + " " + avatar.default.to_s
          avatar.set_as_default 
        end
      end
      user_info = current_user.to_json(false)
      avatars = Array.new
      user_info['avatars'].each do |avatar|
        if avatar['default'].to_s == "true"
          avatars.unshift(avatar)
        else
          avatars.push(avatar)
        end
      end
      user_info['avatars'] = avatars
      render json: success(user_info)
      # render json: success(current_user.to_json(false))
    else
      render json: error(avatar.errors)
    end
  end

  def destroy
    avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])

    if avatar and !avatar.default
      if avatar.destroy
        render json: success
      else
        render json: error(avatar.errors)
      end
    elsif avatar and avatar.default
      render json: error("This is the main avatar, please set another avatar as your main avatar and then delete it.")
    else
      render json: error("Avatar not found.")
    end
  end
end