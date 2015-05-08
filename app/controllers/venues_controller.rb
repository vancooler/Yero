class VenuesController < ApplicationController

  before_action :authenticate_venue!, only: [:tonightly, :nightly, :pick_winner, :lottery_dash, :claim_drink]
  before_action :authenticate_api, only: [:list, :people]
  before_action :authenticate_web_user!, only: [:index]


  def index

    @venues = current_web_user.venues.order('updated_at DESC')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venues }
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
    user = User.find_by_key(params[:key])
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
    user = User.find_by_key(params[:key])
    # venues = Venue.all
    venues = Venue.near_venues(user, distance)

    campus = VenueType.find_by_name("Campus")

    if !campus.nil?
      venues = venues.select{|x| !x.venue_type_id.nil? and x.venue_type_id != campus.id.to_s }
    end

    # if params[:after]
    #   new_list = []

    #   venues.each do |venue|
    #     if venue.tonightly.updated_at > Time.at(params[:after].to_i)
    #       new_list << venue
    #     end
    #   end

    #   venues = new_list
    # end

    data = Jbuilder.encode do |json|
      
      json.array! venues do |v|
        # puts "venue:" 
        # puts v.inspect
        images = VenueAvatar.where(venue_id: v.id).order(default: :desc)
        json.id v.id
        json.name v.name
        json.type  (!v.venue_type.nil? and !v.venue_type.name.nil?) ? v.venue_type.name : ''
        json.address v.address_line_one
        json.city v.city
        json.state v.state
        json.longitude v.longitude
        json.latitude v.latitude
        json.is_favourite FavouriteVenue.where(venue: v, user: User.find_by_key(params[:key])).exists?
        if !images.empty?
          avatars = Array.new
          images.each do |i|
            # avatar = Hash.new
            # avatar['url'] = i.avatar.url
            # avatar['default'] = i.default
            avatars << i.avatar.url
          end
          json.images do
            json.array! avatars
          end
        end

        json.nightly do
          nightly = Nightly.today_or_create(v)
          json.boy_count nightly.boy_count
          json.girl_count nightly.girl_count
          json.guest_wait_time nightly.guest_wait_time
          json.regular_wait_time nightly.regular_wait_time
        end
      end
    end

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
end
