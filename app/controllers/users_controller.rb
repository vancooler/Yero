class UsersController < ApplicationController
  before_action :authenticate_api, except: [:sign_up]
  skip_before_filter  :verify_authenticity_token

  def show
    # render json: success(Hash[*current_user.as_json.map{|k, v| [k, v || ""]}.flatten])
    user = {
      id: current_user.id,
      first_name: current_user.first_name,
      key: current_user.key,
      since_1970: current_user.last_activity.since_1970,
      birthday: current_user.birthday,
      gender: current_user.gender,
      created_at: current_user.created_at,
      updated_at: current_user.updated_at,
      apn_token: current_user.apn_token,
      layer_id: current_user.layer_id,
      latitude:current_user.latitude,
      longitude:current_user.longitude,
      avatars: {
        avatar_0: current_user.main_avatar.url,
        avatar_1: current_user.secondary_avatars.first,
        avatar_2: current_user.user_avatars.count > 2 ? current_user.secondary_avatars.last : " ",
      }
    }.to_json

    render json: success(user)
  end

  # API
  def index
    # @users = User.active
    # @users = @users.where(gender: "M") if params[:gender] == "M"
    # @users = @users.where(gender: "F") if params[:gender] == "F"
    # @users = @users.where("birthday > ?", (Time.now - params[:max_age].to_i.years)) if params[:max_age]
    # @users = @users.where("birthday < ?", (Time.now - params[:min_age].to_i.years)) if params[:max_age]
    # @users = @users.where("current_venue_id = ?", params[:venue_id].to_i) if params[:venue_id]

    users = Jbuilder.encode do |json|
      json.array! current_user.fellow_participants do |user|
        next unless user.user_avatars.present?
        next unless user.main_avatar.present?
        # next if user.user_avatars.first
        # json.main_avatar    user.main_avatar.present? ? user.main_avatar.avatar.url : nil
        json.avatars do |avatars|
          main_avatar   =  user.user_avatars.find_by(default:true)
          other_avatars =  user.user_avatars.where.not(default:true)

          avatars.avatar_0     main_avatar.avatar.url
          avatars.avatar_1     other_avatars.first.avatar.url if other_avatars.count > 0
          avatars.avatar_2     other_avatars.last.avatar.url if other_avatars.count > 1
        end

        if Whisper.where(origin_id: current_user.id, target_id: user).present?
          json.whisper_sent true
        else
          json.whisper_sent false
        end

        json.same_venue_badge          current_user.same_venue_as?(user.id)

        json.id             user.id
        json.first_name     user.first_name
        json.key            user.key
        json.since_1970     user.last_activity.since_1970
        json.birthday       user.birthday
        json.gender         user.gender

        json.created_at     user.created_at
        json.updated_at     user.updated_at

        json.apn_token      user.apn_token
        json.layer_id       user.layer_id

        # json.main_avatar_processed  user.user_avatars.main.url

        # json.secondary_avatars 
        json.latitude       user.locations.present? ? user.locations.last.latitude  : nil
        json.longitude      user.locations.present? ? user.locations.last.longitude : nil

      end
    end
    users = JSON.parse(users).delete_if(&:empty?)
    render json: success(users, "users")
  end

  def update_profile
    if current_user.update(introduction_1: params[:introduction_1], introduction_2: params[:introduction_2])
      render json: success(user)
    else
      render json: error(user.errors)
    end
  end

  def sign_up
    user_registration = UserRegistration.new(sign_up_params)
    user = user_registration.user

    if user_registration.create
      render json: success(user.to_json(true))
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def update_settings
    user = User.find_by_key(params[:key])
    user.assign_attributes(sign_up_params)

    if user.valid?
      user.save!
      render json: success(user.to_json(false))
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def update_image
    user = User.find_by_key(params[:key])
    avatar = user.user_avatars.find(params[:avatar_id])

    if avatar && avatar.update_image(params[:avatar])
      render json: success(user.to_json(false))
    else
      render json: error("Invalid image")
    end
  end

  def update_apn
    user = User.find_by_key(params[:key])
    user.apn_token = params[:token]
    user.save

    render json: success() #
  end

  def get_profile
    user = User.find_by_key(params[:key])
    render json: success(user.to_json(false))
  end

  def get_lotto
    winnings = User.find_by_key(params[:key]).winners.all

    data = Jbuilder.encode do |json|
      json.winnings winnings, :message, :created_at, :winner_id, :claimed
    end

    render json: success(JSON.parse(data))
  end

  def poke
    pokee = User.find(params[:user_id])

    if pokee
      p = Poke.where(pokee: pokee, poker: current_user).first

      unless p
        p = Poke.new
        p.poker = current_user
        p.pokee = pokee
        p.save
      end

      render json: success(nil)
    else
      render json: error("User does no exist")
    end
  end

  def add_favourite_venue
    user = User.find_by_key(params[:key])
    venue = Venue.find(params[:venue_id])
    if user && venue && !user.favourite_venues.where(venue: venue).first
      fav = FavouriteVenue.new
      fav.user = user
      fav.venue = venue
      fav.save

      render json: success(nil)
    else
      render json: error("Error, user/venue does exist or venue is already a favourite of the user")
    end
  end

  def remove_favourite_venue
    user = User.find_by_key(params[:key])
    venue = Venue.find(params[:venue_id])

    if user && venue
      fav = user.favourite_venues.where(venue: venue).first
      if fav
        fav.destroy

        render json: success(nil)
      end
    else
      render json: error("Error, user/venue does not exist or venue is not a favourite of the user")
    end
  end

  # A list of the user's favourite venues
  # TODO refactor out the JSON data builder to venue.rb
  def favourite_venues
    user = User.find_by_key(params[:key])

    favourites = user.favourite_venues

    data = Jbuilder.encode do |json|
      images = ["https://s3.amazonaws.com/whisprdev/test_nightclub/n1.jpg", "https://s3.amazonaws.com/whisprdev/test_nightclub/n2.jpg", "https://s3.amazonaws.com/whisprdev/test_nightclub/n3.jpg"]

      json.array! favourites do |f|

        v = f.venue

        json.id v.id
        json.name v.name
        json.address v.address_line_one
        json.city v.city
        json.state v.state
        json.longitude v.longitude
        json.latitude v.latitude
        json.is_favourite FavouriteVenue.where(venue: v, user: User.find_by_key(params[:key])).exists?
        json.images do
          json.array! images
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

    render json: {
      list: JSON.parse(data)
    }
  end

  # Get all the chat requests sent to the user
  # TODO refactor out the JSON builder into poke.rb
  def get_pokes
    user = User.find_by_key(params[:key])

    pokes = Poke.where(pokee: user).all

    data = Jbuilder.encode do |json|
      json.array! pokes do |p|

        json.id = p.id

        json.poker do
          poker = p.poker

          json.id poker.id
          json.first_name poker.first_name
          json.avatar poker.default_avatar.avatar.thumb.url
        end

        json.timestamp p.poked_at
      end
    end

    render json: {
      list: JSON.parse(data)
    }
  end

  # def read_notification_update
  #   if current_user.read_notification.nil?
  #     read_notification = ReadNotification.create(user: current_user)
  #   else
  #     read_notification = current_user.read_notification
  #   end
  #   if read_notification.update(before_sending_whisper_notification:true)
  #     render json: success
  #   else
  #     render json: error("could not update read notification")
  #   end
  # end

  private

  def sign_up_params
    params.require(:user).permit(:birthday, :first_name, :gender, user_avatars_attributes: [:avatar])
  end
end