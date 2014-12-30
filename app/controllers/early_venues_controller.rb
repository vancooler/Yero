class EarlyVenuesController < InheritedResources::Base

  def create
    #@city = City.find_or_create_by_name(params[:early_venue][:city])
    @early_venue = EarlyVenue.new(:job_title => params[:early_venue][:job_title], :venue_name => params[:early_venue][:venue_name], :email => params[:early_venue][:email], :city => params[:early_venue][:city], :phone => params[:early_venue][:phone], :username => params[:early_venue][:username])

    respond_to do |format|
      if @early_venue.save
        format.html { redirect_to thanks_beta_signup_url }
        format.json { render json: @early_venue, status: :created, location: @early_venue }
      else
        format.html { render action: "new" }
        format.json { render json: @early_venue.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def early_venue_params
      params.require(:early_venue).permit(:username, :city, :job_title, :phone, :email, :venue_name)
    end
end

