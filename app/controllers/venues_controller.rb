class VenuesController < ApplicationController
  prepend_before_filter :get_api_key, only: [:list, :people]
  before_action :authenticate_venue!, only: [:tonightly, :nightly, :pick_winner, :lottery_dash, :claim_drink]
  before_action :authenticate_api, only: [:list, :people]
  before_action :authenticate_web_user!, only: [:index, :edit, :show, :update]
  before_action :authenticate_admin_user!, only: [:approve]
  # list all the venues for this owner
  def index
    WebUser.mixpanel_event(current_web_user.id, 'View venues list', nil)

    if mobile_device?
      @device = "mobile"
    else
      @device = "regular"
    end
    @venues = current_web_user.venues.order('updated_at DESC')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venues }
    end
  end

  # show details of a venue
  def show
    
    if mobile_device?
      @device = "mobile"
    else
      @device = "regular"
    end
    @venue = Venue.find_by_id(params[:id])
    WebUser.mixpanel_event(current_web_user.id, 'View venue details page', {
        'Venue Name' => @venue.name,
        'Venue ID' => @venue.id.to_s
    })

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue }
    end
  end

  # edit page of venue
  def edit
    if mobile_device?
      @device = "mobile"
    else
      @device = "regular"
    end
    @venue = Venue.find_by_id(params[:id])
    WebUser.mixpanel_event(current_web_user.id, 'View venue edit page', {
        'Venue Name' => @venue.name,
        'Venue ID' => @venue.id.to_s
    })
    if @venue.draft_pending.nil? or !@venue.draft_pending
      @venue.pending_name = @venue.name
      @venue.pending_venue_type_id = @venue.venue_type_id
      @venue.pending_address = @venue.address_line_one
      @venue.pending_city = @venue.city
      @venue.pending_state = @venue.state
      @venue.pending_zipcode = @venue.zipcode
      @venue.pending_country = @venue.country
      @venue.pending_manager_first_name = @venue.manager_first_name
      @venue.pending_manager_last_name = @venue.manager_last_name
      @venue.pending_email = @venue.email
      @venue.pending_phone = @venue.phone
    end
  end

  def approve
    @venue = Venue.find(params[:venue])
    @venue.name = @venue.pending_name
    @venue.venue_type_id = @venue.pending_venue_type_id
    @venue.address_line_one = @venue.pending_address
    @venue.city = @venue.pending_city
    @venue.state = @venue.pending_state
    @venue.zipcode = @venue.pending_zipcode
    @venue.country = @venue.pending_country
    @venue.manager_first_name = @venue.pending_manager_first_name
    @venue.manager_last_name = @venue.pending_manager_last_name
    @venue.phone = @venue.pending_phone
    @venue.email = @venue.pending_email
    @venue.pending_name = nil
    @venue.pending_venue_type_id = nil
    @venue.pending_address = nil
    @venue.pending_city = nil
    @venue.pending_state = nil
    @venue.pending_zipcode = nil
    @venue.pending_country = nil
    @venue.pending_manager_last_name = nil
    @venue.pending_manager_first_name = nil
    @venue.pending_email = nil
    @venue.pending_phone = nil
    @venue.draft_pending = false
    if @venue.save!
      # TODO: send email to webuser
      if !@venue.web_user.nil?
        UserMailer.delay.venue_info_approved(@venue.web_user, @venue)
      end
      redirect_to admin_venue_url(@venue), :notice => "Pending draft approved!" 
    else
      redirect_to :back, :notice => "Something wrong..."
    end
  end
  # update a venue
  def update
    @venue = Venue.find_by_id(params[:id])

    respond_to do |format|
      get_params = params.require(:venue).permit(:pending_name, :pending_venue_type_id, :pending_address, :pending_city, :pending_state, :pending_zipcode, :pending_country, :pending_manager_first_name, :pending_manager_last_name, :pending_phone, :pending_email)
      puts "PAramssss:"
      puts get_params[:pending_name]
      if !@venue.draft_pending.nil? and @venue.draft_pending
        # has draft
        if @venue.update_attributes(get_params)
          if !@venue.previous_changes.empty?
            if !@venue.web_user.nil?
              UserMailer.delay.venue_info_pending(@venue.web_user, @venue)
            end
          end
          WebUser.mixpanel_event(current_web_user.id, 'Update the venue draft', {
              'Venue Name' => @venue.name,
              'Venue ID' => @venue.id.to_s
          })
          format.html { redirect_to @venue, notice: 'Venue was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @venue.errors, status: :unprocessable_entity }
        end
      else
        # no draft
        if ((get_params[:pending_name].blank? and @venue.name.blank?) or get_params[:pending_name] == @venue.name) and ((get_params[:pending_venue_type_id].blank? and @venue.venue_type_id.blank?) or get_params[:pending_venue_type_id].to_s == @venue.venue_type_id) and ((get_params[:pending_address].blank? and @venue.address_line_one.blank?) or get_params[:pending_address] == @venue.address_line_one) and ((get_params[:pending_city].blank? and @venue.city.blank?) or get_params[:pending_city] == @venue.city) and ((get_params[:pending_state].blank? and @venue.state.blank?) or get_params[:pending_state] == @venue.state) and ((get_params[:pending_zipcode].blank? and @venue.zipcode.blank?) or get_params[:pending_zipcode] == @venue.zipcode) and ((get_params[:pending_country].blank? and @venue.country.blank?) or get_params[:pending_country] == @venue.country) and ((get_params[:pending_manager_first_name].blank? and @venue.manager_first_name.blank?) or get_params[:pending_manager_first_name] == @venue.manager_first_name) and ((get_params[:pending_manager_last_name].blank? and @venue.manager_last_name.blank?) or get_params[:pending_manager_last_name] == @venue.manager_last_name) and ((get_params[:pending_phone].blank? and @venue.phone.blank?) or get_params[:pending_phone] == @venue.phone) and ((get_params[:pending_email].blank? and @venue.email.blank?) or get_params[:pending_email] == @venue.email)
          # nothing changed
          @venue.pending_name = nil
          @venue.pending_venue_type_id = nil
          @venue.pending_address = nil
          @venue.pending_city = nil
          @venue.pending_state = nil
          @venue.pending_zipcode = nil
          @venue.pending_country = nil
          @venue.pending_manager_last_name = nil
          @venue.pending_manager_first_name = nil
          @venue.pending_email = nil
          @venue.pending_phone = nil
          @venue.draft_pending = false
          @venue.save!

          format.html { redirect_to @venue, notice: 'Sorry, nothing changed.' }
          format.json { head :no_content }

        else
          # something changed
          if @venue.update_attributes(get_params)
            @venue.draft_pending = true
            @venue.save
            # TODO: send email to both admin(hello@yero.co) and webuser
            if !@venue.web_user.nil?
              UserMailer.delay.venue_info_pending(@venue.web_user, @venue)
            end
            WebUser.mixpanel_event(current_web_user.id, 'Create a venue draft', {
                'Venue Name' => @venue.name,
                'Venue ID' => @venue.id.to_s
            })

            format.html { redirect_to @venue, notice: 'Venue was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @venue.errors, status: :unprocessable_entity }
          end
        end 
      end
    end
  end



  def venue_location
    r = Geocoder.search("44.981667,-93.27833")
    raise r[0].inspect
  end

  def nightly
    @nightlies = current_venue.nightlies.order("created_at DESC")
  end

  def tonightly
    nightly = Nightly.today_or_create(current_venue)
    redirect_to show_nightly_path(nightly.id)
  end

  def prospect
    if(params[:email] && params[:longitude] && params[:latitude])
      h = {email: params[:email], longitude: params[:longitude], latitude: params[:latitude]}
      save_client = ProspectCityClient.create(h)
      if save_client
        render json: success(true)
      else
        render json: error("Error saving email, longitude, and latitude")
      end
    else
      render json: error("Error saving email, longitude, and latitude")
    end
  end

  def lottery
    @winners = current_venue.winners.order("created_at DESC").first(5)
    @participants = current_venue.participants.all
  end

  def pick_winner
    participants = current_venue.participants.all

    if participants.size > 0
      recipient = participants.sample
      winner = Winner.new
      winner.user = recipient.user
      winner.message = "You've won a free drink under $10!  Go to any bar to claim your drink."
      winner.venue = recipient.room.venue
      winner.save

      winner.send_notification
    end

    redirect_to lotto_path
  end

  def lottery_dash
    @winners = current_venue.winners.where(claimed: false).order("created_at ASC").all
  end

  def claim_drink
    winner = current_venue.winners.where(winner_id: params[:winner_id]).first

    if winner
      winner.claimed = true
      winner.save
    end

    redirect_to lotto_dash_path
  end

  # API

  # List of venues
  # TODO Refactor out the JSON builder into venue.rb
  def list
    if !params[:distance].nil? and params[:distance].to_i > 0
      distance = params[:distance].to_i
    else
      distance = 10000
    end
    user = current_user
    # venues = Venue.all
    venues = Venue.near_venues(user, distance)

    campus = VenueType.find_by_name("Campus")

    if !campus.nil?
      venues = venues.select{|x| !x.venue_type_id.nil? and x.venue_type_id != campus.id.to_s }
    end

    # reorder it based on featured and featured order
    featured_venues = venues.select{|x| !x.featured.nil? and x.featured }
    if !featured_venues.empty?
      other_venues = venues - featured_venues
      featured_venues = featured_venues.sort_by{|e| e[:featured_order]}
      venues = featured_venues + other_venues
    end

    page_number = nil
    venues_per_page = nil
    page_number = params[:page].to_i + 1 if !params[:page].blank?
    venues_per_page = params[:per_page].to_i if !params[:per_page].blank?

    if !page_number.nil? and !venues_per_page.nil? and venues_per_page > 0 and page_number >= 0
      venues = Kaminari.paginate_array(venues).page(page_number).per(venues_per_page) if !venues.nil?
    end

    data = Venue.venues_object(venues)
    # data = Jbuilder.encode do |json|
      
    #   json.array! venues do |v|
    #     # puts "venue:" 
    #     # puts v.inspect
    #     images = VenueAvatar.where(venue_id: v.id).order(default: :desc)
    #     json.id v.id
    #     json.name (v.name.blank? ? '' : v.name.upcase)
    #     json.type  (!v.venue_type.nil? and !v.venue_type.name.nil?) ? v.venue_type.name : ''
    #     json.address v.address_line_one
    #     json.city v.city
    #     json.state v.state
    #     json.longitude v.longitude
    #     json.latitude v.latitude
    #     json.is_favourite FavouriteVenue.where(venue: v, user: current_user).exists?
    #     if !images.empty?
    #       avatars = Array.new
    #       images.each do |i|
    #         # avatar = Hash.new
    #         # avatar['url'] = i.avatar.url
    #         # avatar['default'] = i.default
    #         avatars << i.avatar.url
    #       end
    #       json.images do
    #         json.array! avatars
    #       end
    #     end

    #     json.nightly do
    #       nightly = Nightly.today_or_create(v)
    #       json.boy_count nightly.boy_count
    #       json.girl_count nightly.girl_count
    #       json.guest_wait_time nightly.guest_wait_time
    #       json.regular_wait_time nightly.regular_wait_time
    #     end
    #   end
    # end

    # render json: {
    #   list: JSON.parse(data)
    # }
    render json: success(JSON.parse data)
  end

  # Returns all the current people in the venue which the curent user is in
  # TODO refactor out the JSON data into participant.rb
  def people
    if current_user.participant
      #participants = current_user.venue_network.participants.all.reject { |p| p.user.id == current_user.id }
      participants = Participant.all
      data = Jbuilder.encode do |json|
        json.array! participants do |p|
          json.name p.user.first_name
          json.image p.user.default_avatar.avatar.thumb.url
          json.gender p.user.gender
          json.age p.user.age
          json.id p.user.id
          json.layer_id p.user.layer_id
        end
      end

      render json: {
        list: JSON.parse(data)
      }
    else
      render error("Current user not in a Venue")
    end
  end

  #return active user in venue or venue network
  def active_users
    if params[:venue_id]
      venue_id = params[:venue_id].to_i
      users = ActiveInVenue.where(:venue_id => venue_id)
      data = Jbuilder.encode do |json|
        json.array! users do |p|
          json.name p.user.first_name
          json.image p.user.default_avatar.avatar.thumb.url if p.user.default_avatar and p.user.default_avatar.avatar
          json.gender p.user.gender
          json.age p.user.age
          json.id p.user.id
          json.layer_id p.user.layer_id
        end
      end

      render json: {
        list: JSON.parse(data)
      }
    elsif params[:venue_network_id]
      venue_network_id = params[:venue_network_id].to_i
      users = ActiveInVenueNetwork.where(:venue_network_id => venue_network_id)
      data = Jbuilder.encode do |json|
        json.array! users do |p|
          json.name p.user.first_name
          json.image p.user.default_avatar.avatar.thumb.url if p.user.default_avatar and p.user.default_avatar.avatar
          json.gender p.user.gender
          json.age p.user.age
          json.id p.user.id
          json.layer_id p.user.layer_id
        end
      end

      render json: {
        list: JSON.parse(data)
      }
    else
      errors = Array.new()
      errors[0] = "Need Venue ID or Venue Network ID"
      data = Jbuilder.encode do |json|
        json.array! errors do |p|
          json.error p
        end
      end
      render json:{
        list: JSON.parse(data)
      }
    end
  end

  private
  def get_api_key
    if api_key = params[:key].blank? && request.headers["X-API-KEY"]
      params[:key] = api_key
    end
  end

end
