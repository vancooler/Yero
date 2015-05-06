class BetaSignupUsersController < InheritedResources::Base

  def android
  	@beta_signup_user = BetaSignupUser.new
  	@beta_signup_user.phone_type = "Android"
  	# @beta_signup_user.city = "N/A"
  	@models = ["Google Nexus 6", "Google Nexus 5", "HTC One M9", "HTC One M8", "HTC One M7", "LG G4", "LG G3", "Moto X", "Oneplus Two", "Oneplus One", "Samsung Galaxy S6", "Samsung Galaxy S6 Edge", "Samsung Galaxy S5", "Samsung Galaxy S4", "Samsung Galaxy Note 4", "Samsung Galaxy Note 3", "Sony Xperia Z3", "Other"]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @beta_signup_user }
    end
  end

  def beta
  	@beta_signup_user = BetaSignupUser.new
  	@beta_signup_user.phone_type = "iPhone"
  	@beta_signup_user.phone_model = "N/A"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @beta_signup_user }
    end
  end

  def create
    #@city = City.find_or_create_by_name(params[:beta_signup_user][:city])
    @beta_signup_user = BetaSignupUser.new(:email => params[:beta_signup_user][:email], :city => params[:beta_signup_user][:city], :phone_model => params[:beta_signup_user][:phone_model], :phone_type => params[:beta_signup_user][:phone_type])

    respond_to do |format|
      if @beta_signup_user.save
        if @beta_signup_user.phone_type == "Android"
          format.html { redirect_to android_thankyou_url }
          format.json { render json: @beta_signup_user, status: :created, location: @beta_signup_user }
        elsif @beta_signup_user.phone_type == "iPhone"
          format.html { redirect_to beta_thankyou_url }
          format.json { render json: @beta_signup_user, status: :created, location: @beta_signup_user }
        end
      else
        format.html { render action: "new" }
        format.json { render json: @beta_signup_user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def beta_signup_user_params
      params.require(:beta_signup_user).permit(:email, :city, :phone_model, :phone_type)
    end
end

