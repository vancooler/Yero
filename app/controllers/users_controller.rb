class UsersController < ApplicationController

  before_action :authenticate_api, except: [:sign_up, :sign_up_without_avatar, :login, :forgot_password, :reset_password, :password_reset, :check_email]
  skip_before_filter  :verify_authenticity_token

  def show
    # render json: success(Hash[*current_user.as_json.map{|k, v| [k, v || ""]}.flatten])
    puts "THE ID"
    puts current_user.id
    avatar_array = Array.new
    if current_user.account_status == 1 or !current_user.default_avatar.nil?
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
    end
    user = {
      id: current_user.id,
      first_name: current_user.first_name,
      introduction_1: current_user.introduction_1,
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
    user = User.find_by_key(params[:key])
    user.is_connected = true
    user.save
    puts user
    gender = params[:gender] if !params[:gender].blank?
    min_age = params[:min_age].to_i if !params[:min_age].blank?
    max_age = params[:max_age].to_i if !params[:max_age].blank?
    min_distance = params[:min_distance].to_i if !params[:min_distance].blank?
    max_distance = params[:max_distance].to_i if !params[:max_distance].blank?
    venue_id = params[:venue_id].to_i if !params[:venue_id].blank?
    puts "EVERYONE: " + params[:everyone].to_s
    everyone = (params[:everyone].to_s == "true" ? true : false) if !params[:everyone].blank?
    page_number = params[:page] if !params[:page].blank?
    users_per_page = params[:per_page] if !params[:per_page].blank?

    gate_number = 4
    result = current_user.people_list(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
    
    if result['users'].nil?
      render json: success(result) #Return users
    else
      render json: success(result['users'], "users")
    end
  end

  def whisper_sent
    if params[:timestamp].nil?
      timestamp = Time.now.to_i
    else
      timestamp = params[:timestamp].to_i
    end
    state = WhisperNotification.whisper_sent(params[:current_user_id], params[:target_user_id], timestamp)
    p 'state'
    p state
    if state == true
      render json: success(true)
    else
      render json: success(false)
    end
  end 


  def requests

    # TODO: check venue/user exist
    time_0 = Time.now
    return_users = current_user.whisper_friends
    time_1 = Time.now
    runtime = time_1 - time_0
    puts "User time"
    puts runtime.inspect
    return_venues = current_user.whisper_venue
    time_2 = Time.now
    runtime = time_2 - time_1
    puts "Venue time"
    puts runtime.inspect
    # yero_notify = WhisperNotification.yero_notification(current_user.id)

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
        json.timestamp_read Time.at(venue['timestamp'])
        json.accepted venue["accepted"]
        json.viewed venue["viewed"]
        json.not_viewed_by_sender venue["not_viewed_by_sender"]
        json.created_date venue["created_date"]
        json.whisper_id venue["whisper_id"]
        json.notification_type  1
      end
    end

    users = JSON.parse(users).delete_if(&:blank?)
    venues_array  = JSON.parse(venues_array).delete_if(&:blank?)
    # yero_message = JSON.parse(yero_message).delete_if(&:blank?)

    same_venue_users = []
    different_venue_users = [] 
    no_badge_users = []
    venues = []

    unviewed_badge = 0
    unviewed_whispers = []
    users.each do |u|
      if u['different_venue_badge'].to_s == "true"
        different_venue_users << u
      elsif u['same_venue_badge'].to_s == "true"
        same_venue_users << u
      else
        no_badge_users << u
      end
      if u["viewed"].to_i == 0
        p 'entered into users'
        unviewed_badge = unviewed_badge + 1
        unviewed_whispers << u
      end
      # if (u["accepted"].to_i == 0 and u["declined"].to_i == 0) 
      # end
    end

    venues_array.each do |v|
      venues << v
      unviewed_whispers << v
      if v["not_viewed_by_sender"].nil? or v["not_viewed_by_sender"].to_i != 0
        p 'entered into venues'
        unviewed_badge = unviewed_badge + 1
      end
    end

    # result_array = same_venue_users + different_venue_users + no_badge_users + venues.reverse
    return_data = Array.new
    unviewed_whispers.each do |r|
      return_data << r
    end 
    
    whispers_array = Array.new
    users = return_data.sort_by { |hsh| hsh["timestamp"].to_i }.reverse
    users.each do |whisp|
      whispers_array << whisp["whisper_id"]
    end

    time_3 = Time.now
    if !whispers_array.nil? and whispers_array.count > 0
      current_user.delay.viewed_by_sender(whispers_array)
    end

    time_4 = Time.now
    runtime = time_4 - time_3
    puts "Update time"
    puts runtime.inspect
    render json: success(users, "data")
  end


  ########################
  # To report a user
  # Params: [:key, user_id, type_id, :reason]
  #
  #########################
  def report
    reporting_user = User.find_by_key(params[:key])
    reported_user = User.find(params[:user_id])
    report_type = ReportType.find(params[:type_id])
    if !reporting_user.nil? and !reported_user.nil? and !report_type.nil?
      record = ReportUserHistory.find_by_reporting_user_id_and_reported_user_id(reporting_user.id, reported_user.id)
      # no report record found
      if record.nil?
        rep = ReportUserHistory.new
        rep.reporting_user_id = reporting_user.id
        rep.reported_user_id = reported_user.id
        rep.report_type_id = report_type.id
        rep.reason = params[:reason]
        if rep.save!
          render json: success(true)
        else
          render json: success(false)
        end
      else

      end
    else
      render json: success(false)
    end
    # report_user = ReportedUser.find_by(key: params[:key])
    # if report_user
    #   report_user.count = report_user.count.to_i + 1
    #   report_user.save!
    #   render json: success(true)
    # elsif ReportedUser.create(first_name: params[:first_name], key: params[:key], apn_token: params[:apn_token], email: params[:email], count: 1, user_id: params[:user_id])
    #   render json: success(true)
    # else
    #   render json: success(false)
    # end
  end

  def myfriends
    p 'user_id'
    p current_user.id
    # friends = UserFriends.return_friends(current_user.id)
    friends = WhisperNotification.myfriends(current_user.id)
    puts "friends123: "
    puts friends.inspect
    WhisperNotification.accept_friend_viewed_by_sender(current_user.id)
    if !friends.blank?
      users = requests_friends_json(friends)
      users = JSON.parse(users).delete_if(&:blank?)

      # same_venue_users = []
      # different_venue_users = [] 
      # no_badge_users = []

      # users.each do |u|
      #   if u['different_venue_badge'].to_s == "true"
      #     different_venue_users << u
      #   elsif u['same_venue_badge'].to_s == "true"
      #     same_venue_users << u
      #   else
      #     no_badge_users << u
      #   end
      # end
      
      # return_data = same_venue_users + different_venue_users + no_badge_users 
      users = users.sort_by { |hsh| hsh["timestamp"] }
      puts "USER ORDER:"
      puts users.inspect
      render json: success(users.reverse, "data")
    else
      render json: success(Array.new, "data")
    end
  end

  def update_profile
    if current_user.update(introduction_1: CGI.unescape(params[:introduction_1]))
      render json: success(current_user)
    else
      render json: error(current_user.errors)
    end
  end

  ##########################################
  #
  # Check email address exists
  # 
  ##########################################
  def check_email
    if params[:email].nil? or params[:email].blank?
      render json: error("No email address")
    else
      if User.exists? email: params[:email]
        render json: error("Email address exists")
      else
        render json: success()
      end
    end
  end

  ##########################################
  #
  # Signup user without avatar
  # 
  ##########################################
  def sign_up_without_avatar
    if params[:email].blank? or params[:password].blank? or params[:birthday].blank? or params[:first_name].blank? or params[:gender].blank?
      render json: error("Required fields cannot be blank")
    else
      # good to signup
      @user = User.new(:email => params[:email],
                       :password => params[:password],
                       :birthday => params[:birthday],
                       :first_name => params[:first_name],
                       :gender => params[:gender])
                       
      @user.nonce = params[:nonce] if params[:nonce].present?
      @user.instagram_id = params[:instagram_id] if params[:instagram_id].present?
      @user.wechat_id = params[:wechat_id] if params[:wechat_id].present?
      @user.snapchat_id = params[:snapchat_id] if params[:snapchat_id].present?
      @user.exclusive = params[:exclusive] if params[:exclusive].present?
      # create user key
      @user.key = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end

      @user.last_active = Time.now
      @user.account_status = 0  # inactive without avatar
      if !(User.exists? email: params[:email])
        if @user.save
          response = @user.to_json(true)
          
          intro = "Welcome to Yero"
          # TODO: future feature
          # n = WhisperNotification.create_in_aws(@user.id, 307, 1, 2, intro)
          
          render json: success(response)
        else
          render json: error(JSON.parse(@user.errors.messages.to_json))
        end
      else
          render json: error("This email has already been taken.")
      end
    end
  end

  def sign_up
    # Rails.logger.info "PARAMETERS: "
    # Rails.logger.debug sign_up_params.inspect
    # Rails.logger.debug params.inspect
    # tmp_params = sign_up_params
    # tmp_params.delete('avatar_id')
    
    user_registration = UserRegistration.new(sign_up_params)
    
    user_registration.user.email = params[:email] if params[:email].present?
    user_registration.user.password = params[:password] if params[:password].present?
    user_registration.user.birthday = params[:birthday] if params[:birthday].present?
    user_registration.user.first_name = params[:first_name] if params[:first_name].present?
    user_registration.user.gender = params[:gender] if params[:gender].present?                       
    user_registration.user.nonce = params[:nonce] if params[:nonce].present?
    user_registration.user.instagram_id = params[:instagram_id] if params[:instagram_id].present?
    user_registration.user.wechat_id = params[:wechat_id] if params[:wechat_id].present?
    user_registration.user.snapchat_id = params[:snapchat_id] if params[:snapchat_id].present?
    user_registration.user.exclusive = params[:exclusive] if params[:exclusive].present?

    if !(User.exists? email: params[:email])
      if user_registration.create
        user = user_registration.user
        
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
        user_info = user

        if !response["avatars"].empty?
          thumb = response["avatars"].first['avatar']
          if thumb
            response["avatars"].first['thumbnail'] = thumb
            response["avatars"].first['avatar'] = thumb.gsub! 'thumb_', ''
          end
        end
        
        # render json: user_registration.to_json.inspect
        # render json: user_avatar.to_json.inspect
        
        intro = "Welcome to Yero"
        # TODO: future feature
        # n = WhisperNotification.create_in_aws(user_info.id, 307, 1, 2, intro)
        
        render json: success(response)
      else
        render json: error(JSON.parse(user.errors.messages.to_json))
      end
    else
        render json: error("This email has already been taken.")
    end
  end

  # API to login a user
  def login
    if params[:email].nil? or params[:email].empty? or params[:password].nil? or params[:password].empty? or params[:key].nil?
      render json: error("Login information missing.")
    else
      if User.exists? email: params[:email]
        user = User.find_by_email(params[:email]) # find by email, skip key
        puts "The user"
        puts user.authenticate(params[:password])
        if user.authenticate(params[:password])
          # Authenticated successfully
          # Check key change, means login in another device, do update the key 
          if user.key != params[:key]
            # generate a new key
            user.key = loop do
              random_token = SecureRandom.urlsafe_base64(nil, false)
              break random_token unless User.exists?(key: random_token)
            end

            user.save!
          end
          render json: success(user.to_json(true))
        else
          render json: error("Email/Password does not match")
        end  
      else
        render json: error("Email address not found")
      end
    end
  end

  def update_settings
    user = User.find_by_key(params[:key])

    if user.update(exclusive: params[:exclusive])
      u = Hash.new
      u = {exclusive: user.exclusive}
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

  # Renders a page for user to change password
  def reset_password
    @user = User.find_by_key(params[:key])
    render "password_reset"
  end

  def password_reset
    if !params[:user].blank?
      @user = User.find_by_key(params[:user][:key])
      puts "params[:user].blank"
      puts @user.inspect
      @error = Array.new
      if @user.email.to_s.downcase != params[:user][:email].to_s.downcase 
        flash[:danger] = true 
        @error << "Email given does not match email from password recovery."
        puts "Email given does not match email from password recovery."
        email_mismatch = false
      else
        email_mismatch = true
      end
      if params[:user][:email].blank?
        flash[:danger] = true
        @error << "Email cannot be blank."
        puts "Email cannot be blank."
        email_blank = false
      else
        email_blank = true
      end
      if params[:user][:password].blank?
        flash[:danger] = true 
        @error << "Password cannot be empty."
        puts "Password cannot be empty."
        password_blank = false
      else 
        password_blank = true
      end
      if params[:user][:password_confirmation].blank?
        flash[:danger] = true
        @error << "Password confirmation cannot be empty."
        puts "Password confirmation cannot be empty."
        password_conf_empty = false
      else
        password_conf_empty = true
      end
      if params[:user][:password].length < 6
        flash[:danger]= true
        @error << "Your new password must be at least 6 characters."
        puts "Password is too short (minimum is 6 characters)."
        password_short = false
      else
        password_short = true
      end
      if params[:user][:password] != params[:user][:password_confirmation]
        flash[:danger] = true 
        @error << "Your new passwords do not match."
        puts "Your new passwords do not match"
        password_mismatch = false
      else 
        password_mismatch = true
      end
      if !params[:user][:email].blank?
        if !params[:user][:email].match /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
          flash[:danger] = true 
          @error << "Please enter a valid email address." 
          puts "Please enter a valid email address"
          email_invalid = false
        else
          email_invalid = true
        end
      end

      if email_mismatch && email_blank && password_blank && password_conf_empty && password_short && password_mismatch && email_invalid
        puts "everything passed"
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        if @user.save
          puts "saved"
          UserMailer.password_change_success(@user)
          flash[:danger] = nil
          flash[:success] = "Password Change Succeeded"
        end
      end
    else
      @user = User.find_by_key(params[:key])
      @error = Array.new
      flash[:danger] = nil
      puts "we got into else"
    end
  end

  # change to find by email
  def forgot_password
    @user = User.find_by_email(params[:email])
    if !@user.nil?
      UserMailer.forget_password(@user).deliver
      render json: success(true)
    else
      render json: error("The email you have used is not valid.")
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
    if user.save
      render json: success() #
    else
      render json: error()
    end
  end

  # When user clicked "Connect" button, update field is_connect to true
  def connect
    user = User.find_by_key(params[:key])
    user.is_connected = true
    
    if user.save
      render json: success() #
    else
      render json: error()
    end
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

  # Like / Unlike feature
  def like
    # user = User.find_by_key(params[:key])
    if !params[:user_id].nil?
      if User.exists? id: params[:user_id]
        target_user = User.find(params[:user_id])

        if current_user.follows?(target_user) # Unlike
          current_user.unfollow!(target_user)
        else # Like
          current_user.follow!(target_user)
        end

        # Return friends list
        friends = WhisperNotification.myfriends(current_user.id)

        if !friends.blank?
          users = requests_friends_json(friends)
          users = JSON.parse(users).delete_if(&:blank?)
          users = users.sort_by { |hsh| hsh[:timestamp] }

          render json: success(users.reverse, "data")
        else
          render json: success(Array.new, "data")
        end
      else
        render json: error("Sorry, this user doesn't exist")
      end
    else
      render json: error("Sorry, user_id required")
    end

  end

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
        json.gender         user["target_user"]["gender"]
        if user["target_user"]["id"].to_i != 307
          json.birthday       user["target_user"]["birthday"]
          json.distance       current_user.distance_label(user["target_user"])
        end
        json.created_at     user["target_user"]["created_at"]
        json.updated_at     user["target_user"]["updated_at"]
        json.avatar_thumbnail user["target_user_thumb"] 
        json.avatars         avatar_array
        json.apn_token      user["target_user"].apn_token
        json.notification_read  user["notification_read"].blank? ? nil : user["notification_read"]
        json.email  user["target_user"]["email"]
        json.instagram_id  user["target_user"]["instagram_id"]
        json.snapchat_id  user["target_user"]["snapchat_id"]
        json.wechat_id  user["target_user"]["wechat_id"]
        json.timestamp  user["timestamp"]
        json.timestamp_read  Time.at(user["timestamp"])
        json.accepted   user["accepted"].blank? ? nil : user["accepted"]
        json.declined   user["declined"].blank? ? nil : user["declined"]
        json.whisper_id  user["whisper_id"].blank? ? nil : user["whisper_id"]
        json.intro_message user["intro"].blank? ? nil : user["intro"]
        json.not_viewed_by_sender user["not_viewed_by_sender"].blank? ? 0 : user["not_viewed_by_sender"]

        json.latitude       user["target_user"].latitude  
        json.longitude      user["target_user"].longitude 

        json.introduction_1 user["target_user"].introduction_1.blank? ? nil : user["target_user"].introduction_1
        json.notification_type 2
      end         
    end
    return users 
  end

  def sign_up_params
    params.require(:user).permit(:birthday, :nonce, :first_name, :gender, :email, :instagram_id, :snapchat_id, :wechat_id, :password, :password_confirmation, :exclusive, user_avatars_attributes: [:avatar, :avatar_tmp])
    # params.require(:user).permit(:birthday, : :first_name, :gender, :avatar_id)
  end

  def login_params
    params.require(:user).permit(:email, :password, :token)
  end
end


# NOTES:
# whisper badge number  = notification unviewed number + # friend
# College: 
