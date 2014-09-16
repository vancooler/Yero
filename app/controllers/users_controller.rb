class UsersController < ApplicationController
  before_action :authenticate_api, except: [:sign_up]
  skip_before_filter  :verify_authenticity_token

  def show
    # render json: success(Hash[*current_user.as_json.map{|k, v| [k, v || ""]}.flatten])
    avatar_array = Array.new
    avatar_array[0] = {
          avatar: current_user.main_avatar.avatar.url,
          avatar_id: current_user.main_avatar.id,
          default: true
        }
    avatar_array[1] = {
          avatar: current_user.user_avatars.count > 1 ? current_user.secondary_avatars.first.avatar.url : "",
          avatar_id: current_user.user_avatars.count > 1 ? current_user.secondary_avatars.first.id : "",
          default: false
        }
    avatar_array[2] = {
          avatar: current_user.user_avatars.count > 2 ? current_user.secondary_avatars.last.avatar.url : "",
          avatar_id: current_user.user_avatars.count > 2 ? current_user.secondary_avatars.last.id : "",
          default: false
        }
    user = {
      id: current_user.id,
      first_name: current_user.first_name,
      introduction_1: current_user.introduction_1,
      introduction_2: current_user.introduction_2,
      key: current_user.key,
      since_1970: (current_user.last_active - Time.new('1970')).seconds.to_i, #current_user.last_activity.present? ? current_user.last_activity.since_1970 : "",
      birthday: current_user.birthday,
      gender: current_user.gender,
      created_at: current_user.created_at,
      updated_at: current_user.updated_at,
      apn_token: current_user.apn_token,
      layer_id: current_user.layer_id,
      latitude:current_user.latitude,
      longitude:current_user.longitude,
      avatars: avatar_array
      # avatars: {
      #   avatar_0: {
      #     avatar: current_user.main_avatar.avatar.url,
      #     avatar_id: current_user.main_avatar.id,
      #     default: true
      #   },
      #   avatar_1: {
      #     avatar: current_user.user_avatars.count > 1 ? current_user.secondary_avatars.first.avatar.url : "",
      #     avatar_id: current_user.user_avatars.count > 1 ? current_user.secondary_avatars.first.id : "",
      #     default: false
      #   },
      #   avatar_2: {
      #     avatar: current_user.user_avatars.count > 2 ? current_user.secondary_avatars.last.avatar.url : "",
      #     avatar_id: current_user.user_avatars.count > 2 ? current_user.secondary_avatars.last.id : "",
      #     default: false
      #   }
      # }
    }

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
    gender = params[:gender] if !params[:gender].nil? and !params[:gender].empty?
    min_age = params[:min_age].to_i if !params[:min_age].nil? and !params[:min_age].empty?
    max_age = params[:max_age].to_i if !params[:max_age].nil? and !params[:max_age].empty?
    min_distance = params[:min_distance].to_i if !params[:min_distance].nil? and !params[:min_distance].empty?
    max_distance = params[:max_distance].to_i if !params[:max_distance].nil? and !params[:max_distance].empty?
    venue_id = params[:venue_id].to_i if !params[:venue_id].nil? and !params[:venue_id].empty?
    page_number = params[:page] if !params[:page].nil? and !params[:page].empty?
    users_per_page = params[:per_page] if !params[:per_page].nil? and !params[:per_page].empty?
    users = Jbuilder.encode do |json|
      if !params[:page].nil? and !params[:page].empty? and !params[:per_page].nil? and !params[:per_page].empty?
        return_users = current_user.fellow_participants(gender, min_age, max_age, venue_id, min_distance, max_distance)
        return_users = return_users.page(page_number).per(users_per_page) if !return_users.nil?
      else
        return_users = current_user.fellow_participants(gender, min_age, max_age, venue_id, min_distance, max_distance)
      end



      json.array! return_users do |user|
        next unless user.user_avatars.present?
        next unless user.main_avatar.present?
        # next if user.user_avatars.first
        # json.main_avatar    user.main_avatar.present? ? user.main_avatar.avatar.url : nil
        
        main_avatar   =  user.user_avatars.find_by(default:true)
        other_avatars =  user.user_avatars.where.not(default:true)
        avatar_array = Array.new
        avatar_array[0] = {
              thumbnail: main_avatar.nil? ? '' : main_avatar.avatar.thumb.url,
            }
        avatar_array[1] = {
              avatar: main_avatar.nil? ? '' : main_avatar.avatar.url,
              avatar_id: main_avatar.nil? ? '' : main_avatar.id,
              default: true
            }
        if other_avatars.count > 0
          avatar_array[2] = {
                avatar: other_avatars.count > 0 ? other_avatars.first.avatar.url : '',
                avatar_id: other_avatars.count > 0 ? other_avatars.first.id : '',
                default: false
              }
          if other_avatars.count > 1
            avatar_array[3] = {
                  avatar: other_avatars.count > 1 ? other_avatars.last.avatar.url : '',
                  avatar_id: other_avatars.count > 1 ? other_avatars.last.id : '',
                  default: false
                }
          end
        end
        json.avatars do |a|
          json.array! avatar_array do |avatar|
            a.avatar      avatar[:avatar]    if !avatar[:avatar].nil?
            a.thumbnail   avatar[:thumbnail] if !avatar[:thumbnail].nil?
            a.avatar_id   avatar[:avatar_id] if !avatar[:avatar_id].nil?
            a.default     avatar[:default]   if !avatar[:default].nil?
          end
        end



        # json.avatars do |avatars|
        #   main_avatar   =  user.user_avatars.find_by(default:true)
        #   other_avatars =  user.user_avatars.where.not(default:true)

        #   # avatars.avatar_0     main_avatar.avatar.url if main_avatar and main_avatar.avatar
        #   # avatars.avatar_1     other_avatars.first.avatar.url if other_avatars.count > 0
        #   # avatars.avatar_2     other_avatars.last.avatar.url if other_avatars.count > 1
        #   # avatars.avatar_0_thumbnail     main_avatar.avatar.thumb.url if main_avatar and main_avatar.avatar and main_avatar.avatar.thumb
        #   json.avatar_0 do |avatar_0|
        #     avatar_0.avatar    main_avatar.nil? ? '' : main_avatar.avatar.url
        #     avatar_0.thumbnail main_avatar.nil? ? '' : main_avatar.avatar.thumb.url
        #     avatar_0.avatar_id main_avatar.nil? ? '' : main_avatar.id
        #     avatar_0.default   true
        #   end
        #   json.avatar_1 do |avatar_1|
        #     avatar_1.avatar    other_avatars.count > 0 ? other_avatars.first.avatar.url : ''
        #     avatar_1.avatar_id other_avatars.count > 0 ? other_avatars.first.id : ''
        #     avatar_1.default   false
        #   end
        #   json.avatar_2 do |avatar_2|
        #     avatar_2.avatar    other_avatars.count > 1 ? other_avatars.last.avatar.url : ''
        #     avatar_2.avatar_id other_avatars.count > 1 ? other_avatars.last.id : ''
        #     avatar_2.default   false
        #   end
        # end

        if Whisper.where(origin_id: current_user.id, target_id: user).present?
          json.whisper_sent true
        else
          json.whisper_sent false
        end

        json.same_venue_badge          current_user.same_venue_as?(user.id)

        json.id             user.id
        json.first_name     user.first_name
        json.key            user.key
        json.since_1970     (user.last_active - Time.new('1970')).seconds.to_i
        json.birthday       user.birthday
        json.gender         user.gender
        json.distance       current_user.distance_label(user)
        json.created_at     user.created_at
        json.updated_at     user.updated_at

        json.apn_token      user.apn_token
        json.layer_id       user.layer_id

        # json.main_avatar_processed  user.user_avatars.main.url

        # json.secondary_avatars 
        json.latitude       user.latitude  
        json.longitude      user.longitude 

      end
    end
    users = JSON.parse(users).delete_if(&:empty?)
    render json: success(users, "users")
  end

  def update_profile
    if current_user.update(introduction_1: CGI.unescape(params[:introduction_1]), introduction_2: CGI.unescape(params[:introduction_2]))
      render json: success(current_user)
    else
      render json: error(current_user.errors)
    end
  end

  def sign_up
    logger.info sign_up_params
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
    params.require(:user).permit(:birthday, :nonce, :first_name, :gender, user_avatars_attributes: [:avatar])
  end
end


# i = 1
# while i < 31 do
#   u = User.new
#   u.birthday = "1993-09-09"
#   u.first_name = "TEST_" + i.to_s
#   u.nonce = "TEST_" + i.to_s + "_nonce"
#   u.gender = "Male"
#   u.latitude = rand 49.0..50.0
#   u.longitude = rand -124.0..-123.0
#   u.key = SecureRandom.urlsafe_base64(nil, false)
#   u.save
#   i = i+1
# end