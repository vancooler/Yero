class UsersController < ApplicationController
  prepend_before_filter :get_api_token, except: [:set_global_variable, :sign_up, :sign_up_without_avatar, :login, :forgot_password, :reset_password, :password_reset, :check_email]
  before_action :authenticate_api, except: [:set_global_variable, :sign_up, :sign_up_without_avatar, :login, :forgot_password, :reset_password, :password_reset, :check_email]
  skip_before_filter  :verify_authenticity_token

  def show
    # render json: success(Hash[*current_user.as_json.map{|k, v| [k, v || ""]}.flatten])
    puts "THE ID"
    puts current_user.id
    avatar_array = Array.new
    if !current_user.default_avatar.nil?
      user_info = current_user.to_json(false)
      # user_info['avatars'] = user_info['avatars'].sort_by { |hsh| hsh["order"] }
      user_info["avatars"].each do |a|
        thumb = a['avatar']
        # a['thumbnail'] = thumb
        a['avatar'] = thumb.gsub! 'thumb_', ''
      end
      # avatars = Array.new
      # user_info['avatars'].each do |avatar|
      #   if avatar['default'].to_s == "true"
      #     avatars.unshift(avatar)
      #   else
      #     avatars.push(avatar)
      #   end
      # end
      # user_info['avatars'] = avatars
      # user_info['avatars'].each do |a|
      #   thumb = a['avatar']
      #   a['avatar'] = thumb.gsub! 'thumb_', ''
      # end

      # avatar_array[0] = {
      #       avatar: current_user.main_avatar.avatar.url,
      #       avatar_id: current_user.main_avatar.id,
      #       default: true
      #     }
      # avatar_array[1] = {
      #       avatar: current_user.user_avatars.count > 1 ? current_user.secondary_avatars.first.avatar.url : "",
      #       avatar_id: current_user.user_avatars.count > 1 ? current_user.secondary_avatars.first.id : "",
      #       default: false
      #     }
      # avatar_array[2] = {
      #       avatar: current_user.user_avatars.count > 2 ? current_user.secondary_avatars.last.avatar.url : "",
      #       avatar_id: current_user.user_avatars.count > 2 ? current_user.secondary_avatars.last.id : "",
      #       default: false
      #     }
    end
    user = {
      id: current_user.id,
      first_name: current_user.first_name,
      introduction_1: (current_user.introduction_1.blank? ? '' : current_user.introduction_1),
      key: current_user.key,
      instagram_id:  current_user.instagram_id.blank? ? '' : current_user.instagram_id,
      snapchat_id:  current_user.snapchat_id.blank? ? '' : current_user.snapchat_id,
      wechat_id:  current_user.wechat_id.blank? ? '' : current_user.wechat_id,
      line_id:  current_user.line_id.blank? ? '' : current_user.line_id,
      since_1970: (current_user.last_active - Time.new('1970')).seconds.to_i, #current_user.last_activity.present? ? current_user.last_activity.since_1970 : "",
      birthday: current_user.birthday,
      gender: current_user.gender,
      created_at: current_user.created_at,
      updated_at: current_user.updated_at,
      apn_token: current_user.apn_token,
      latitude:current_user.latitude,
      longitude:current_user.longitude,
      avatars: user_info['avatars']
    }

    render json: success(user)
  end

  # API
  def index
    disabled = !current_user.user_avatars.where(:is_active => false).blank?
    default = !current_user.user_avatars.where(:is_active => false).where(:default => true).blank?
    avatar_result = {
      disabled: disabled,
      main_avatar: default
    }
    gate_number = 4
    # if set in db, use the db value
    if GlobalVariable.exists? name: "min_ppl_size"
      size = GlobalVariable.find_by_name("min_ppl_size")
      if !size.nil? and !size.value.nil? and size.value.to_i > 0
        gate_number = size.value.to_i
      end
    end

    disabled = false
    default = false
    if disabled and default
      render json: success(avatar_result, "avatar")
    else
      user = current_user
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
      page_number = nil
      users_per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      users_per_page = params[:per_page].to_i if !params[:per_page].blank?

      result = current_user.people_list(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
      
      if disabled and !default
        if result['users'].nil?
          final_result = {
            avatar: avatar_result,
            percentage: result['percentage']
          }
        else
          user.enough_user_notification_sent_tonight = true
          user.save
          final_result = {
            avatar: avatar_result,
            users: result['users']
          }
        end   
        render json: success(final_result) #Return users
      else
        if result['users'].nil?
          render json: success(result) #Return users
        else
          user.enough_user_notification_sent_tonight = true
          user.save
          render json: success(result['users'], "users")
        end 
      end   
    end
  end


  def set_global_variable
    if !params[:variable].blank? and !params[:value].blank?
      name = params[:variable]
      value = params[:value]
      if GlobalVariable.exists? name: name
        variable = GlobalVariable.find_by_name(name)
        variable.value = value
      else
        variable = GlobalVariable.new
        variable.name = name
        variable.value = value
      end
      variable.save!
      render json: success(true)
    else
      render json: error("Invalid params")
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

  # New API for whispers requests
  def requests_new
    unread =  !params[:unread].blank? ? (params[:unread].to_i == 1) : false

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
    is_friends = false
    users = requests_user_whisper_json(return_users, is_friends)
    venues = requests_venue_whisper_json(return_venues)

    users = JSON.parse(users).delete_if(&:blank?)
    venues  = JSON.parse(venues).delete_if(&:blank?)
    # yero_message = JSON.parse(yero_message).delete_if(&:blank?)


    unviewed_whisper_number = 0
    unviewed_whispers = []
    users.each do |u|
      # if u["viewed"].to_i == 0
      #   unviewed_whisper_number = unviewed_whisper_number + 1
      # end
      if unread 
        if u["viewed"].nil? or u["viewed"].to_i == 0
          unviewed_whispers << u
        end
      else
        unviewed_whispers << u
      end
    end

    venues.each do |v|
      if unread 
        if v["viewed"].nil? or v["viewed"].to_i == 0
          unviewed_whispers << v
        end
      else
        unviewed_whispers << v
      end

      # if v["viewed"].nil? or v["viewed"].to_i == 0
      #   unviewed_whisper_number = unviewed_whisper_number + 1
      # end
    end

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

    badge = WhisperNotification.unviewd_whisper_number(current_user.id)
    response_data = {
      badge_number: badge,
      whispers: users
    }
    render json: success(response_data, "data")
  end


  ########################
  # To report a user
  # Params: [:key, user_id, type_id, :reason]
  #
  #########################
  def report
    reporting_user = current_user
    reported_user = User.find_by_id(params[:user_id])
    report_type = ReportType.find_by_id(params[:type_id])
    if !reporting_user.nil? and !reported_user.nil? and !report_type.nil?
      record = ReportUserHistory.find_by_reporting_user_id_and_reported_user_id_and_report_type_id(reporting_user.id, reported_user.id, report_type.id)
      # no report record found
      if record.blank?
        rep = ReportUserHistory.new
        rep.reporting_user_id = reporting_user.id
        rep.reported_user_id = reported_user.id
        rep.report_type_id = report_type.id
        # find same report by other users
        other_user_rep = ReportUserHistory.find_by_reported_user_id_and_report_type_id(reported_user.id, report_type.id)
        if other_user_rep.blank?
          rep.frequency = 1
        else
          rep.frequency = other_user_rep.frequency + 1
        end
        rep.reason = params[:reason]
        if rep.save!
          # update other records
          reports_need_update = ReportUserHistory.where(:reported_user_id => reported_user.id, :report_type_id => report_type.id)
          reports_need_update.update_all(:frequency => rep.frequency)
          render json: success(true)
        else
          render json: success(false)
        end
      else
        if record.frequency.blank?
          record.frequency = 1
        else
          record.frequency += 1
        end
        if record.save!
          # update other records
          reports_need_update = ReportUserHistory.where(:reported_user_id => reported_user.id, :report_type_id => report_type.id)
          reports_need_update.update_all(:frequency => record.frequency)
          render json: success(true)
        else
          render json: success(false)
        end
      end


      # update other records with same type & reported_user_id
    else
      render json: success(false)
    end
    
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
      users = users.sort_by { |hsh| hsh["timestamp"] }
      puts "USER ORDER:"
      puts users.inspect
      render json: success(users.reverse, "data")
    else
      render json: success(Array.new, "data")
    end
  end

  # new API for friends list
  def myfriends_new
    friends = WhisperNotification.myfriends(current_user.id)
    badge = WhisperNotification.unviewd_whisper_number(current_user.id)
    if !friends.blank?
      page_number = nil
      friends_per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      friends_per_page = params[:per_page].to_i if !params[:per_page].blank?

      if !page_number.nil? and !friends_per_page.nil? and friends_per_page > 0 and page_number >= 0
        friends = Kaminari.paginate_array(friends).page(page_number).per(friends_per_page) 
      end
      is_friends = true
      users = requests_user_whisper_json(friends, is_friends)
      users = JSON.parse(users).delete_if(&:blank?)
      users = users.sort_by { |hsh| hsh["timestamp"] }
      WhisperNotification.accept_friend_viewed_by_sender(current_user.id)
      puts "USER ORDER:"
      puts users.inspect
      response_data = {
        badge_number: badge,
        friends: users.reverse
      }
    else
      response_data = {
        badge_number: badge,
        friends: Array.new
      }
    end
    render json: success(response_data, "data")
  end


  def update_profile
    if current_user.update(introduction_1: CGI.unescape(params[:introduction_1].strip))
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
      if params[:email].match(/\s/).blank?
        email = params[:email]
      else
        email = params[:email].gsub!(/\s+/, "") 
      end
    
      if params[:gender].match(/\s/).blank?
        gender = params[:gender]
      else
        gender = params[:gender].gsub!(/\s+/, "") 
      end

      if params[:first_name].match(/\s/).blank?
        first_name = params[:first_name]
        first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)
      else
        first_name = params[:first_name].gsub!(/\s+/, "") 
        first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)
      end

      @user = User.new(:email => email,
                       :password => params[:password],
                       :birthday => params[:birthday],
                       :first_name => first_name,
                       :gender => gender)
                       
      if params[:instagram_id].present? 
        if params[:instagram_id].match(/\s/).blank?
          @user.instagram_id = params[:instagram_id]
        else
          @user.instagram_id = params[:instagram_id].gsub!(/\s+/, "") 
        end
      end

      if params[:snapchat_id].present? 
        if params[:snapchat_id].match(/\s/).blank?
          @user.snapchat_id = params[:snapchat_id]
        else
          @user.snapchat_id = params[:snapchat_id].gsub!(/\s+/, "") 
        end
      end

      if params[:wechat_id].present? 
        if params[:wechat_id].match(/\s/).blank?
          @user.wechat_id = params[:wechat_id]
        else
          @user.wechat_id = params[:wechat_id].gsub!(/\s+/, "") 
        end
      end

      if params[:line_id].present? 
        if params[:line_id].match(/\s/).blank?
          @user.line_id = params[:line_id]
        else
          @user.line_id = params[:line_id].gsub!(/\s+/, "") 
        end
      end
      @user.nonce = params[:nonce] if params[:nonce].present?
      @user.exclusive = params[:exclusive] if params[:exclusive].present?
      # create user key
      @user.key = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
      @user.key_expiration = Time.now + 3.hours
      @user.account_status = 1
      @user.last_active = Time.now
      if !(User.exists? email: params[:email])
        if @user.save
          response = @user.to_json(true)
          response['token'] = @user.generate_token
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
    
    if params[:email].present? 
      if params[:email].match(/\s/).blank?
        user_registration.user.email = params[:email]
      else
        user_registration.user.email = params[:email].gsub!(/\s+/, "") 
      end
    end

    if params[:gender].present? 
      if params[:gender].match(/\s/).blank?
        user_registration.user.gender = params[:gender]
      else
        user_registration.user.gender = params[:gender].gsub!(/\s+/, "") 
      end
    end

    if params[:first_name].present? 
      if params[:first_name].match(/\s/).blank?
        first_name = params[:first_name]
        user_registration.user.first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)

      else
        first_name = params[:first_name].gsub!(/\s+/, "") 
        user_registration.user.first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)

      end
    end

    if params[:instagram_id].present? 
      if params[:instagram_id].match(/\s/).blank?
        user_registration.user.instagram_id = params[:instagram_id]
      else
        user_registration.user.instagram_id = params[:instagram_id].gsub!(/\s+/, "") 
      end
    end

    if params[:snapchat_id].present? 
      if params[:snapchat_id].match(/\s/).blank?
        user_registration.user.snapchat_id = params[:snapchat_id]
      else
        user_registration.user.snapchat_id = params[:snapchat_id].gsub!(/\s+/, "") 
      end
    end

    if params[:wechat_id].present? 
      if params[:wechat_id].match(/\s/).blank?
        user_registration.user.wechat_id = params[:wechat_id]
      else
        user_registration.user.wechat_id = params[:wechat_id].gsub!(/\s+/, "") 
      end
    end
    if params[:line_id].present? 
      if params[:line_id].match(/\s/).blank?
        user_registration.user.line_id = params[:line_id]
      else
        user_registration.user.line_id = params[:line_id].gsub!(/\s+/, "") 
      end
    end
    user_registration.user.password = params[:password] if params[:password].present?
    user_registration.user.birthday = params[:birthday] if params[:birthday].present?                       
    user_registration.user.nonce = params[:nonce] if params[:nonce].present?
    user_registration.user.exclusive = params[:exclusive] if params[:exclusive].present?

    if !(User.exists? email: params[:email])
      if user_registration.create
        user = user_registration.user
        user.key_expiration = Time.now + 3.hours
        user.account_status = 1
        user.save
        # save avatar order
        if !user.nil? and !user.default_avatar.nil?
          avatar = user.default_avatar
          avatar.order = 0
          avatar.save!
        end

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
        response['token'] = user.generate_token
        # render json: user_registration.to_json.inspect
        # render json: user_avatar.to_json.inspect
        
        intro = "Welcome to Yero"
        # TODO: future feature
        # n = WhisperNotification.create_in_aws(user_info.id, 307, 1, 2, intro)
        
        render json: success(response)
      else
        puts user_registration.user.errors.messages
        render json: error(JSON.parse(user_registration.user.errors.messages.to_json))
      end
    else
        render json: error("This email has already been taken.")
    end
  end

  # API to login a user
  def login
    if params[:email].nil? or params[:email].empty? or params[:password].nil? or params[:password].empty?
      render json: error("Login information missing.")
    else
      if User.exists? email: params[:email]
        user = User.find_by_email(params[:email]) # find by email, skip key
        puts "The user"
        puts user.authenticate(params[:password])
        if user.authenticate(params[:password])
          # Authenticated successfully
          # Check key change, means login in another device, do update the key 
          if params[:key].blank? or user.key != params[:key]
            # generate a new key
            user.key = loop do
              random_token = SecureRandom.urlsafe_base64(nil, false)
              break random_token unless User.exists?(key: random_token)
            end
          end
          user.key_expiration = Time.now + 3.hours
          user.save!
          user_info = user.to_json(true)
          user_info['token'] = user.generate_token
          render json: success(user_info)
        else
          render json: error("Email/Password does not match")
        end  
      else
        render json: error("Email address not found")
      end
    end
  end

  def update_settings
    user = current_user

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
    user = current_user
    if !params[:active]
      user.update(active: true)
      render json: success(true)
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def update_chat_accounts
    user = current_user

    if !params[:instagram_id].blank? 
      if params[:instagram_id].match(/\s/).blank?
        user.instagram_id = params[:instagram_id]
      else
        user.instagram_id = params[:instagram_id].gsub!(/\s+/, "") 
      end
    end

    if !params[:snapchat_id].blank? 
      if params[:snapchat_id].match(/\s/).blank?
        user.snapchat_id = params[:snapchat_id]
      else
        user.snapchat_id = params[:snapchat_id].gsub!(/\s+/, "") 
      end
    end

    if !params[:wechat_id].blank? 
      if params[:wechat_id].match(/\s/).blank?
        user.wechat_id = params[:wechat_id]
      else
        user.wechat_id = params[:wechat_id].gsub!(/\s+/, "") 
      end
    end

    if !params[:line_id].blank? 
      if params[:line_id].match(/\s/).blank?
        user.line_id = params[:line_id]
      else
        user.line_id = params[:line_id].gsub!(/\s+/, "") 
      end
    end
    
    if user.save
      render json: success(user)
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def remove_chat_accounts
    user = current_user
    if params[:snapchat_id] == true
      user.snapchat_id = nil
    end
    if params[:wechat_id] == true
      user.wechat_id = nil
    end
    if params[:line_id] == true
      user.line_id = nil
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
    @user = current_user
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
          UserMailer.delay.password_change_success(@user)
          flash[:danger] = nil
          flash[:success] = "Password Change Succeeded"
        end
      end
    else
      @user = current_user
      @error = Array.new
      flash[:danger] = nil
      puts "we got into else"
    end
  end

  # change to find by email
  def forgot_password
    @user = User.find_by_email(params[:email])
    if !@user.nil?
      UserMailer.delay.forget_password(@user)
      render json: success(true)
    else
      render json: error("The email you have used is not valid.")
    end
  end

  def update_image
    user = current_user
    avatar = user.user_avatars.find(params[:avatar_id])

    if avatar && avatar.update_image(params[:avatar])
      render json: success(user.to_json(false))
    else
      render json: error("Invalid image")
    end
  end

  def update_apn
    user = current_user
    user.apn_token = params[:token]
    if user.save
      render json: success() #
    else
      render json: error()
    end
  end

  # When user clicked "Connect" button, update field is_connect to true
  def connect
    user = current_user
    user.is_connected = true
    
    if user.save
      render json: success() #
    else
      render json: error()
    end
  end

  def get_profile
    user = current_user
    render json: success(user.to_json(false))
  end

  def get_lotto
    winnings = current_user.winners.all

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
    user = current_user
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
    user = current_user
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
    user = current_user

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
        json.is_favourite FavouriteVenue.where(venue: v, user: current_user).exists?
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
    user = current_user

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
    user = current_user
    if params[:accept_contract] == true
      user.update(accept_contract: true)
      render json: success(true)
    else
      render json: success(false)
    end
  end

  # Like / Unlike feature
  def like
    # user = current_user
    if !params[:user_id].nil?
      if User.exists? id: params[:user_id]
        target_user = User.find(params[:user_id])

        if current_user.follows?(target_user) # Unlike
          # REMOVED unlike
          # current_user.unfollow!(target_user)
        else # Like
          current_user.follow!(target_user)

          # Send notifications to target user 
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
        json.line_id  user["target_user"]["line_id"]
        json.timestamp  user["timestamp"]
        json.seconds_left  user["seconds_left"]
        json.timestamp_read  Time.at(user["timestamp"])
        json.accepted   user["accepted"].blank? ? nil : user["accepted"]
        json.declined   user["declined"].blank? ? nil : user["declined"]
        json.whisper_id  user["whisper_id"].blank? ? nil : user["whisper_id"]
        json.intro_message user["intro"].blank? ? nil : user["intro"]
        json.not_viewed_by_sender user["not_viewed_by_sender"].blank? ? 0 : user["not_viewed_by_sender"]

        json.latitude       user["target_user"].latitude  
        json.longitude      user["target_user"].longitude 

        json.introduction_1 user["target_user"].introduction_1.blank? ? '' : user["target_user"].introduction_1
        json.notification_type 2
      end         
    end
    return users 
  end

  def requests_user_whisper_json(return_users, is_friends)
    users = Jbuilder.encode do |json|
      json.array! return_users.each do |user|
        target_user = User.find_by_id(user["target_user"]["id"].to_i)
        if !target_user.nil?
          user_object = target_user.user_object(current_user)
        end

        if !is_friends
          json.seconds_left  user["seconds_left"]
          json.expire_timestamp  user["expire_timestamp"]
          json.accepted   user["accepted"].blank? ? 0 : user["accepted"]
          json.declined   user["declined"].blank? ? 0 : user["declined"]
          json.intro_message user["intro"].blank? ? '' : user["intro"]
          json.whisper_id  user["whisper_id"].blank? ? '' : user["whisper_id"]
          json.notification_type 2
        else
          json.notification_type 3
        end
        json.id = user_object['id'] 
        json.timestamp  user["timestamp"]
        json.timestamp_read  Time.at(user["timestamp"])
        json.viewed user["viewed"].blank? ? 0 : user["viewed"]
        json.object_type "user"
        json.object user_object

      end         
    end
    return users 
  end

  def requests_venue_whisper_json(return_venues)
    venues = Jbuilder.encode do |json|
      json.array! return_venues.each do |venue|
        venue_obj = Venue.find(venue["venue_id"])
        if !venue_obj.nil?
          venue_object = venue_obj.venue_object
        end
        # venue_avatar = VenueAvatar.find_by_venue_id(venue["venue_id"])
        # if venue_avatar 
        #   json.venue_avatar venue_avatar["avatar"]
        # end

        # json.venue_name venue_obj["name"]
        # json.venue_message "Welcome to "+venue_obj["name"]+"! Open this Whisper to learn more about tonight."
        json.timestamp venue["timestamp"]
        json.seconds_left  nil
        json.timestamp_read Time.at(venue['timestamp'])
        json.accepted   venue["accepted"].blank? ? 0 : venue["accepted"]
        json.declined   venue["declined"].blank? ? 0 : venue["declined"]
        json.viewed venue["viewed"]
        json.intro_message venue["intro"].blank? ? '' : venue["intro"]
        # json.not_viewed_by_sender venue["not_viewed_by_sender"]
        # json.created_date venue["created_date"]
        json.whisper_id venue["whisper_id"]
        json.notification_type  1
        json.object_type "venue"
        json.object venue_object
      end
    end

    return venues
  end

  def sign_up_params
    params.require(:user).permit(:birthday, :nonce, :first_name, :gender, :email, :instagram_id, :snapchat_id, :wechat_id, :line_id, :password, :password_confirmation, :exclusive, user_avatars_attributes: [:avatar, :avatar_tmp])
    # params.require(:user).permit(:birthday, : :first_name, :gender, :avatar_id)
  end

  def login_params
    params.require(:user).permit(:email, :password, :token)
  end

  def get_api_token
    if api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
      params[:token] = api_token
    end
  end

end


# NOTES:
# whisper badge number  = notification unviewed number + # friend
# College: 
