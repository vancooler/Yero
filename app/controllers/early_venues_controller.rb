class EarlyVenuesController < InheritedResources::Base
  before_filter :sign_in_user, only: [:index]

  def new
    @early_venue = EarlyVenue.new
    if params.has_key?(:username)
      @early_venue.username = params[:username]
    end
    if params.has_key?(:job_title)
      @early_venue.job_title = params[:job_title]
    end
    if params.has_key?(:venue_name)
      @early_venue.venue_name = params[:venue_name]
    end
    if params.has_key?(:email)
      @early_venue.email = params[:email]
    end
    if params.has_key?(:phone)
      @early_venue.phone = params[:phone]
    end
    if params.has_key?(:city)
      @early_venue.city = params[:city]
    end
  end

  def create
    #@city = City.find_or_create_by_name(params[:early_venue][:city])
    @early_venue = EarlyVenue.new(:job_title => params[:early_venue][:job_title], :venue_name => params[:early_venue][:venue_name], :email => params[:early_venue][:email], :city => params[:early_venue][:city], :phone => params[:early_venue][:phone], :username => params[:early_venue][:username])

    # respond_to do |format|
      if @early_venue.save
        redirect_to venues_thankyou_url
        # format.html { redirect_to venues_thankyou_url }
        # format.json { render json: @early_venue, status: :created, location: @early_venue }
      else
        redirect_to get_in_touch_url(:job_title => params[:early_venue][:job_title], :venue_name => params[:early_venue][:venue_name], :email => params[:early_venue][:email], :city => params[:early_venue][:city], :phone => params[:early_venue][:phone], :username => params[:early_venue][:username] )
        # format.html { render action: "new" }
        # format.json { render json: @early_venue.errors, status: :unprocessable_entity }
      end
    # end
  end

  def sign_in_user
    redirect_to get_in_touch_url, notice: 'You cannot access this page!' unless false
  end

  private

    def early_venue_params
      params.require(:early_venue).permit(:username, :city, :job_title, :phone, :email, :venue_name)
    end
end

