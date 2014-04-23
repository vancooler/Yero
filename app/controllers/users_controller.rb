class UsersController < ApplicationController
  before_action :authenticate_api, except: [:sign_up]
  skip_before_filter  :verify_authenticity_token

  # API
  def update

  end

  def sign_up
    user = User.new(sign_up_params)

    if user.valid?
      user.save!
      render json: success(user.to_json(true))
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def update_settings
    user = User.find(params[:id])
    user.assign_attributes(sign_up_params)

    if user.valid?
      user.save!
      render json: success(user.to_json(true))
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :birthday, :first_name, :gender, :avatar, :last_initial)
  end
end