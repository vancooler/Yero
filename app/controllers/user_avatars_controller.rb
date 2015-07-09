class UserAvatarsController < ApplicationController
  prepend_before_filter :get_api_token, except: [:create_avatar]
  before_action :authenticate_api, except: [:create_avatar]
  skip_before_filter  :verify_authenticity_token

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
            user_info['avatars'] = user_info['avatars'].sort_by { |hsh| hsh["order"] }
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
            user_info['avatars'] = user_info['avatars'].sort_by { |hsh| hsh["order"] }
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
    current_order = UserAvatar.where(:user_id => current_user.id).maximum(:order)
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
          current_user.account_status = 1
          current_user.save
        end
      end
      user_info = current_user.to_json(true)
      user_info["key"] = current_user.key
      # avatars = Array.new
      # user_info['avatars'].each do |avatar|
      #   real_avatar = UserAvatar.find(avatar['avatar_id'].to_i)
      #   return_avatar = Hash.new
      #   return_avatar['avatar'] = real_avatar.avatar.url
      #   return_avatar['default'] = real_avatar.default
      #   return_avatar['avatar_id'] = avatar['avatar_id'].to_i
      #   if avatar['default'].to_s == "true"
      #     avatars.unshift(return_avatar)
      #   else
      #     avatars.push(return_avatar)
      #   end
      # end
      # user_info['avatars'] = avatars
      user_info['avatars'] = user_info['avatars'].sort_by { |hsh| hsh["order"] }
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

    if avatar and !avatar.default
      this_order = avatar.order
      if avatar.destroy
        # check max order
        current_order = UserAvatar.where(:user_id => current_user.id).maximum(:order)
        next_order = current_order.nil? ? 0 : current_order+1
        # minus one for all avatars with greater order
        if this_order + 1 < next_order
          greater_avatars = UserAvatar.where(order: (this_order + 1)..Float::INFINITY).where(user_id: current_user.id)
          greater_avatars.each do |ga|
            ga.order = ga.order - 1
            ga.save!
          end
        end

        user_info = current_user.to_json(true)
        user_info["key"] = current_user.key
        # avatars = Array.new
        # user_info['avatars'].each do |a|
        #   real_avatar = UserAvatar.find(a['avatar_id'].to_i)
        #   return_avatar = Hash.new
        #   return_avatar['avatar'] = real_avatar.avatar.url
        #   return_avatar['default'] = real_avatar.default
        #   return_avatar['avatar_id'] = a['avatar_id'].to_i
        #   if a['default'].to_s == "true"
        #     avatars.unshift(return_avatar)
        #   else
        #     avatars.push(return_avatar)
        #   end
        # end
        # user_info['avatars'] = avatars
        user_info['avatars'] = user_info['avatars'].sort_by { |hsh| hsh["order"] }
        user_info["avatars"].each do |a|
          thumb = a['avatar']
          # a['thumbnail'] = thumb
          a['avatar'] = thumb.gsub! 'thumb_', ''
        end
        render json: success(user_info)
      else
        render json: error(avatar.errors)
      end
    elsif avatar and avatar.default
      render json: error("This is the main avatar, please set another avatar as your main avatar and then delete it.")
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