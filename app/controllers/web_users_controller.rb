class WebUsersController < ApplicationController

  before_action :authenticate_web_user!, only: [:edit, :update]


  def edit
  	WebUser.delay.mixpanel_event(current_web_user.id, 'View WebUser account edit', {
		    'Name' => current_web_user.name,
		    'ID' => current_web_user.id.to_s
	})
  	if mobile_device?
      @device = "mobile"
    else
      @device = "regular"
    end
    @id = current_web_user.id
    @web_user = WebUser.find_by_id(@id)
    
  end

  def update
    @web_user = WebUser.find_by_id(params[:id])

    respond_to do |format|
      get_params = params.require(:web_user).permit(:email, :business_phone, :password, :password_confirmation, :first_name, :last_name)
      puts get_params[:password]
      password_update = true
      if get_params[:password].blank?
		get_params.delete(:password)
		get_params.delete(:password_confirmation)
      	password_update = false
	  end
	  if @web_user.update_attributes(get_params)
	  	WebUser.delay.mixpanel_event(current_web_user.id, 'WebUser account updated', {
		    'Name' => current_web_user.name,
		    'ID' => current_web_user.id.to_s
		})
	  	if password_update
		  	sign_in(@web_user, bypass: true)
		end
        format.html { redirect_to venues_path, notice: 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @web_user.errors, status: :unprocessable_entity }
      end
    end
    
  end

end