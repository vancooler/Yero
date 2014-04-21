class UsersControlelr < ApplicationController
  before_action :authenticate_api, except: [:sign_up, :sign_in]

  # API
  def sign_in

  end

  def sign_out

  end

  def sign_up
    user = User.new(sign_up_params)

    if user.valid?
      user.save!
      render json: success(user.to_json)
    else

    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :birthday, :first_name, :gender, :avatar)
  end
end