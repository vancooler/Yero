class UserAvatarsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  def set_default
    avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])
    if avatar
      if avatar.set_as_default
        render json: success(avatar)
      else
        render json: error(avatar.errors)
      end
    else
      render json: error('Avatar could not be found.')
    end
  end

  def create
    avatar = UserAvatar.new(user: current_user)
    avatar.avatar = params[:avatar]

    if avatar.save
      render json: success(current_user.to_json(false))
    else
      render json: error(avatar.errors)
    end
  end

  def destroy
    avatar = UserAvatar.find_by(user: current_user, id: params[:avatar_id])

    if avatar
      if avatar.destroy
        render json: success
      else
        render json: error(avatar.errors)
      end
    else
      render json: error("Avatar not found.")
    end
  end
end