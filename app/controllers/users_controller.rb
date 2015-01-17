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
      # layer_id: current_user.layer_id,
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
    gender = params[:gender] if !params[:gender].blank?
    min_age = params[:min_age].to_i if !params[:min_age].blank?
    max_age = params[:max_age].to_i if !params[:max_age].blank?
    min_distance = params[:min_distance].to_i if !params[:min_distance].blank?
    max_distance = params[:max_distance].to_i if !params[:max_distance].blank?
    venue_id = params[:venue_id].to_i if !params[:venue_id].blank?
    everyone = params[:everyone] == "1"? true : false
    page_number = params[:page] if !params[:page].blank?
    users_per_page = params[:per_page] if !blank?
    diff_1 = 0
    diff_2 = 0
    s_time = Time.now
    if ActiveInVenueNetwork.count > 10
      users = Jbuilder.encode do |json|
        if !params[:page].blank? and !params[:per_page].blank?
          #fellow_participants basically returns all users that are out or in your particular venue
          return_users = current_user.fellow_participants(gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
          # Basically a pagination thing for mobile.
          return_users = return_users.page(page_number).per(users_per_page) if !return_users.nil?
        else
          return_users = current_user.fellow_participants(gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
        end
        
        json.array! return_users do |user|
          next unless user.user_avatars.present?
          next unless user.main_avatar.present?
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

          start_time = Time.now
          json.whisper_sent WhisperNotification.whisper_sent(current_user, user) #Returns a boolean of whether a whisper was sent between this user and target user
          end_time = Time.now
          diff_1 += (end_time - start_time)
          json.same_venue_badge          current_user.same_venue_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
          json.different_venue_badge     current_user.different_venue_as?(user.id)
          json.same_beacon               current_user.same_beacon_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
          json.actual_distance           current_user.actual_distance(user) # Returns the distance of current user from the target user
          json.id             user.id
          json.first_name     user.first_name
          json.key            user.key
          json.since_1970     (user.last_active - Time.new('1970')).seconds.to_i
          json.birthday       user.birthday
          json.gender         user.gender
          json.distance       current_user.distance_label(user) # Returns a label such as "Within 2 km"
          json.created_at     user.created_at
          json.updated_at     user.updated_at
          json.wechat_id      user.wechat_id
          json.snapchat_id    user.snapchat_id
          json.instagram_id   user.instagram_id

          json.apn_token      user.apn_token
          
          json.latitude       user.latitude  
          json.longitude      user.longitude 

          json.introduction_1 user.introduction_1
          json.introduction_2 user.introduction_2

        end
        
      end
      users = JSON.parse(users).delete_if(&:empty?)
      different_venue_users = [] # Make a empty array for users in the different venue
      same_venue_users = [] #Make a empty array for users in the same venue
      no_badge_users = [] # Make an empty array for no badge users
      users.each do |u| # Go through the users
        if u['different_venue_badge'].to_s == "true" #If the users' same beacon field is true
          different_venue_users << u # Throw the user into the array
        elsif u['same_venue_badge'].to_s == "true" #If the users' same venue field is true
          same_venue_users << u # Throw the user into the array
        else 
          no_badge_users << u
        end
      end
      # users = users - same_beacon_users - same_venue_users # Split out the users such that users only contain those that are not in the same venue or same beacon
      users = same_venue_users.sort_by { |hsh| hsh[:actual_distance] } + different_venue_users.sort_by { |hsh| hsh[:actual_distance] } + no_badge_users #Sort users by distance
      final_time = Time.now
      # diff_2 = final_time - end_time
      e_time = Time.now
      runtime = e_time - s_time
      puts "The runtime is: "
      puts runtime.inspect
      logger.info "NEWTIME: " + diff_1.to_s 
    else
      users = []
    end
    render json: success(users, "users") #Return users
  end

  def requests
    
    return_users = current_user.whisper_friends
    return_venues = current_user.whisper_venue

    users = requests_friends_json(return_users)

    venues_array = Jbuilder.encode do |json|
      #Loop through the return_venues ids and do a find to get the object
      # Then do the json dance to include venue id, link to venue_avatars to get the picture
      # And make a dynamic name with the welcome message
      json.array! return_venues.each do |venue|
        venue_obj = Venue.find(venue["venue_id"])
        venue_avatar = VenueAvatar.find_by_venue_id(venue["venue_id"])
        if venue_avatar 
          json.venue_avatar venue_avatar["avatar"]
        end

        json.venue_name venue_obj["name"]
        json.venue_message "Welcome to "+venue_obj["name"]+"! Open this Whisper to learn more about tonight."
        json.timestamp venue["timestamp"]
        json.accepted venue["accepted"]
        json.viewed venue["viewed"]
        json.created_date venue["created_date"]
        json.whisper_id venue["whisper_id"]
        json.notification_type  1
      end
    end

    users = JSON.parse(users).delete_if(&:blank?)
    venues_array  = JSON.parse(venues_array).delete_if(&:blank?)
    
    same_venue_users = []
    different_venue_users = [] 
    no_badge_users = []
    venues = []

    users.each do |u|
      if u['different_venue_badge'].to_s == "true"
        different_venue_users << u
      elsif u['same_venue_badge'].to_s == "true"
        same_venue_users << u
      else
        no_badge_users << u
      end
    end
    venues_array.each do |v|
      venues << v
    end

    return_data = same_venue_users + different_venue_users + no_badge_users + venues
    # users = venues.sort_by { |hsh| hsh[:timestamp] } + same_venue_users.sort_by { |hsh| hsh[:timestamp] } + different_venue_users.sort_by { |hsh| hsh[:timestamp] } + no_badge_users.sort_by { |hsh| hsh[:timestamp] }
    users = return_data.sort_by { |hsh| hsh[:timestamp] }
    users = users.reverse
    render json: success(users, "data")
  end

  def myfriends
    p 'user_id'
    p current_user.id
    friends = WhisperNotification.myfriends(current_user.id)
    users = requests_friends_json(friends)
    users = JSON.parse(users).delete_if(&:blank?)
    
    same_venue_users = []
    different_venue_users = [] 
    no_badge_users = []

    users.each do |u|
      if u['different_venue_badge'].to_s == "true"
        different_venue_users << u
      elsif u['same_venue_badge'].to_s == "true"
        same_venue_users << u
      else
        no_badge_users << u
      end
    end
    
    return_data = same_venue_users + different_venue_users + no_badge_users 
    users = return_data.sort_by { |hsh| hsh[:timestamp] }
    users = users.reverse
    p users
    render json: success(users, "data")
  end

  def update_profile
    if current_user.update(introduction_1: CGI.unescape(params[:introduction_1]), introduction_2: CGI.unescape(params[:introduction_2]))
      render json: success(current_user)
    else
      render json: error(current_user.errors)
    end
  end

  def sign_up
    # Rails.logger.info "PARAMETERS: "
    # Rails.logger.debug sign_up_params.inspect
    # Rails.logger.debug params.inspect
    # tmp_params = sign_up_params
    # tmp_params.delete('avatar_id')
    
    user_registration = UserRegistration.new(sign_up_params)
    
    user = user_registration.user

    if user_registration.create
      # #signup with the avatar id
      # avatar_id = sign_up_params[:avatar_id]
      # response = user.to_json(true)
      # response["avatars"] = Array.new
      # if avatar_id.to_i > 0
      #   avatar = UserAvatar.find(avatar_id.to_i)
      #   if !avatar.nil?
      #     avatar.user_id = user.id
      #     avatar.save
      #     user_avatar = Hash.new
      #     user_avatar['thumbnail'] = avatar.avatar.thumb.url
      #     user_avatar['avatar'] = avatar.avatar.url
      #     response["avatars"] = [user_avatar]
      #   end
      # end

      # avatar = sign_up_params[:avatar]
      # if avatar
      #   user_avatar = UserAvatar.create(user_id: user_registration.id, avatar: avatar, default_boolean: true )
      # else
      # end
      
      # The way in one step
      response = user.to_json(true)
      # p 'here is response:'
      # p response.inspect
      thumb = response["avatars"].first['avatar']
      if thumb
        response["avatars"].first['thumbnail'] = thumb
        response["avatars"].first['avatar'] = thumb.gsub! 'thumb_', ''
      end
      
      # render json: user_registration.to_json.inspect
      # render json: user_avatar.to_json.inspect
      # 

      render json: success(response)
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def login
    user = User.find_by_key(params[:key])
    if (params[:email] == user.email and params[:password] == user.password)
      render json: success(user.to_json(true))
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end  
  end

  def update_settings
    user = User.find_by_key(params[:key])
    # user.assign_attributes(sign_up_params)

    if user.update(exclusive: params[:exclusive], discovery: params[:discovery])
      u = Hash.new
      u = {exclusive: user.exclusive, discovery: user.discovery}
      render json: success(u)
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
    # if user.valid?
    #   user.save!
    #   render json: success(user.to_json(false))
    # else
    #   render json: error(JSON.parse(user.errors.messages.to_json))
    # end
  end

  def deactivate
    user = User.find_by_key(params[:key])
    if !params[:active]
      user.update(active: true)
      render json: success(true)
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def update_chat_accounts
    user = User.find_by_key(params[:key])
    snapchat_id = params[:snapchat_id]? params[:snapchat_id] : user.snapchat_id
    wechat_id = params[:wechat_id]? params[:wechat_id] : user.wechat_id
    instagram_id = params[:instagram_id]? params[:instagram_id] : user.wechat_id
    user.snapchat_id = snapchat_id
    user.wechat_id = wechat_id
    user.instagram_id = instagram_id
    if user.save
      render json: success(user)
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def remove_chat_accounts
    user = User.find_by_key(params[:key])
    if params[:snapchat_id] == true
      user.snapchat_id = nil
    end
    if params[:wechat_id] == true
      user.wechat_id = nil
    end
    if params[:instagram_id] == true
      user.instagram_id = nil
    end
    if user.save
      render json: success(true)
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def forgot_password
    @user = User.find_by_key(params[:key])
    if (params[:email] == @user.email)
      UserMailer.forget_password(@user).deliver
      render json: success(true)
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

  # Accept contract makes sure the user accepts the rules of yero
  def accept_contract
    user = User.find_by_key(params[:key])
    if params[:accept_contract] == true
      user.update(accept_contract: true)
      render json: success(true)
    else
      render json: success(false)
    end
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

  def requests_friends_json(return_users)
    users = Jbuilder.encode do |json|
      json.array! return_users.each do |user|
        avatar_array = Array.new
        avatar_array[0] = {
              avatar: user["target_user_main"],
              default: true
            }
        avatar_array[1] = {
              avatar: user["target_user_secondary1"],
              default: false
            }
        avatar_array[2] = {
              avatar: user["target_user_secondary2"],
              default: false
            }
        json.same_venue_badge          current_user.same_venue_as?(user["target_user"]["id"].to_i)
        json.different_venue_badge     current_user.different_venue_as?(user["target_user"]["id"].to_i) 
        json.actual_distance           current_user.actual_distance(user["target_user"])
        json.id             user["target_user"]["id"]
        json.first_name     user["target_user"]["first_name"]
        json.key            user["target_user"]["key"]
        json.last_active    user["target_user"]["last_active"]
        json.last_activity  user["target_user"]["last_activity"]
        json.since_1970     (user["target_user"]["last_active"] - Time.new('1970')).seconds.to_i
        json.birthday       user["target_user"]["birthday"]
        json.gender         user["target_user"]["gender"]
        json.distance       current_user.distance_label(user["target_user"])
        json.created_at     user["target_user"]["created_at"]
        json.updated_at     user["target_user"]["updated_at"]
        json.avatar_thumbnail user["target_user_thumb"] 
        json.avatars         avatar_array
        json.apn_token      user["target_user"].apn_token
        json.notification_read  user["notification_read"]
        json.email  user["target_user"]["email"]
        json.instagram_id  user["target_user"]["instagram_id"]
        json.snapchat_id  user["target_user"]["snapchat_id"]
        json.wechat_id  user["target_user"]["wechat_id"]
        json.timestamp  user["timestamp"]
        json.whisper_id  user["whisper_id"]

        json.latitude       user["target_user"].latitude  
        json.longitude      user["target_user"].longitude 

        json.introduction_1 user["target_user"].introduction_1
        json.introduction_2 user["target_user"].introduction_2
      end         
    end
    return users 
  end

  def sign_up_params
    params.require(:user).permit(:birthday, :nonce, :first_name, :gender, :email, :instagram_id, :snapchat_id, :wechat_id, :password, :discovery, :exclusive, user_avatars_attributes: [:avatar])
    # params.require(:user).permit(:birthday, : :first_name, :gender, :avatar_id)
  end

  def login_params
    params.require(:user).permit(:email, :password, :key)
  end
end


# i = 1
# while i < 31 do
#   u = User.new
#   u.birthday = "1993-09-09"
#   u.first_name = "TEST_" + i.to_s

#   u.gender = "Male"
#   u.latitude = rand 49.0..50.0
#   u.longitude = rand -124.0..-123.0
#   u.key = SecureRandom.urlsafe_base64(nil, false)
#   u.save
#   i = i+1
# end