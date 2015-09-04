class UsersController < ApplicationController
  prepend_before_filter :get_api_token, except: [:import, :email_reset, :set_global_variable, :sign_up, :sign_up_without_avatar, :login, :forgot_password, :reset_password, :password_reset, :check_email]
  before_action :authenticate_api, except: [:import, :email_reset, :set_global_variable, :sign_up, :sign_up_without_avatar, :login, :forgot_password, :reset_password, :password_reset, :check_email]
  before_action :authenticate_admin_user!, only: [:import]
  skip_before_filter  :verify_authenticity_token

  # :nocov:
  def import
    myfile = params[:csv_file]
    require 'csv'    

    if myfile.blank? or myfile.content_type != 'text/csv'
      redirect_to :back, :notice => "Invalid file!" 
    else
      if User.import(myfile)
        redirect_to admin_users_url, :notice => "Users Imported!" 
      else
        redirect_to :back, :notice => "Invalid csv structure!"
      end
    end
    
  end
  # :nocov:

  def show
    puts "THE ID"
    puts current_user.id
    avatar_array = Array.new
    if !current_user.default_avatar.nil?
      user_info = current_user.to_json(true)
      
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
    disabled = current_user.user_avatars.where(:is_active => true).blank?

    gate_number = 4
    # if set in db, use the db value
    if GlobalVariable.exists? name: "min_ppl_size"
      size = GlobalVariable.find_by_name("min_ppl_size")
      if !size.nil? and !size.value.nil? and size.value.to_i > 0
        gate_number = size.value.to_i
      end
    end

    if disabled 
      render json: error("No photos")
    else
      user = current_user
      user.join_network
      puts user
      gender = params[:gender] if !params[:gender].blank?
      min_age = params[:min_age].to_i if !params[:min_age].blank?
      max_age = params[:max_age].to_i if !params[:max_age].blank?
      min_distance = params[:min_distance].to_i if !params[:min_distance].blank?
      max_distance = params[:max_distance].to_i if !params[:max_distance].blank?
      venue_id = params[:venue_id].to_i if !params[:venue_id].blank?
      puts "EVERYONE: " + params[:everyone].to_s
      everyone = true
      everyone = (params[:everyone].to_s == "true" ? true : false) if !params[:everyone].nil?
      puts "EVERYONE2: " + everyone.to_s
      page_number = nil
      users_per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      users_per_page = params[:per_page].to_i if !params[:per_page].blank?

      result = current_user.people_list(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
      
      # if disabled and !default
      #   if result['users'].nil?
      #     final_result = {
      #       avatar: avatar_result,
      #       percentage: result['percentage']
      #     }
      #   else
      #     user.enough_user_notification_sent_tonight = true
      #     user.save
      #     final_result = {
      #       avatar: avatar_result,
      #       users: result['users']
      #     }
      #   end   
      #   render json: success(final_result) #Return users
      # else
        if result['users'].nil?
          render json: success(result) #Return users
        else
          user.enough_user_notification_sent_tonight = true
          user.save
          render json: success(result['users'], "users")
        end 
      # end   
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


  # New API for whispers requests
  def requests_new
    unread =  !params[:unread].blank? ? (params[:unread].to_i == 1) : false

    badge = WhisperNotification.unviewd_whisper_number(current_user.id)

    if unread
      whispers = WhisperToday.whispers_related(current_user.id)
    else
      whispers = WhisperToday.whispers_related(current_user.id)
    end
    if !whispers.blank?
      whispers = WhisperToday.to_json(whispers, current_user)
      whispers_array = Array.new
      # users = return_data.sort_by { |hsh| hsh["timestamp"].to_i }.reverse
      whispers.each do |whisp|
        whispers_array << whisp["whisper_id"]
      end
      if badge[:whisper_number].to_i > badge[:friend_number].to_i
        if !whispers_array.nil? and whispers_array.count > 0
          # update local tmp db
          WhisperToday.where(:paper_owner_id => current_user.id).update_all(:viewed => true)
          # update dynamodb
          if Rails.env == 'production'
            current_user.delay.viewed_by_sender(whispers_array)
          end
        end
      end
    end
    puts "Friend Number:"
    puts badge.inspect
    if badge[:friend_number].to_i > 0
      # update local tmp db
      FriendByWhisper.where(:origin_user_id => current_user.id).update_all(:viewed => true)
      # update dynamodb
      if Rails.env == 'production'
        WhisperNotification.delay.accept_friend_viewed_by_sender(current_user.id)
      end
    end

    response_data = {
      badge_number: badge,
      whispers: whispers
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
      if true or record.blank?
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
        
        render json: error("You have reported this user before")
      end


      # update other records with same type & reported_user_id
    else
      render json: success(false)
    end
    
  end

  
  # new API for friends list
  def myfriends_new
    t0 = Time.now
    friends = WhisperNotification.myfriends(current_user.id)
    t1 = Time.now
    # badge = WhisperNotification.unviewd_whisper_number(current_user.id)
    t2 = Time.now
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
      # WhisperNotification.delay.accept_friend_viewed_by_sender(current_user.id)
      puts "USER ORDER:"
      puts users.inspect
      response_data = {
        friends: users.reverse
      }
    else
      response_data = {
        friends: Array.new
      }
    end
    t3 = Time.now

    puts "GETHER friends"
    puts (t1-t0).inspect
    puts "GETHER badge"
    puts (t2-t1).inspect
    puts "serialize friends"
    puts (t3-t2).inspect

    render json: success(response_data, "data")
  end


  def update_profile
    avatar_ids = params[:avatars].blank? ? [] : params[:avatars].to_a

    if current_user.avatar_reorder(avatar_ids) and current_user.update(introduction_1: CGI.unescape(params[:introduction_1].strip))
      render json: success(current_user.to_json(true))
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
          # n = WhisperNotification.create_in_aws(@user.id, 0, 1, 2, intro)
          
          render json: success(response)
        else
          render json: error(JSON.parse(@user.errors.messages.to_json))
        end
      else
          render json: error("This email has already been taken.")
      end
    end
  end

  # def sign_up
  #   # Rails.logger.info "PARAMETERS: "
  #   # Rails.logger.debug sign_up_params.inspect
  #   # Rails.logger.debug params.inspect
  #   # tmp_params = sign_up_params
  #   # tmp_params.delete('avatar_id')
    
  #   user_registration = UserRegistration.new(sign_up_params)
    
  #   if params[:email].present? 
  #     if params[:email].match(/\s/).blank?
  #       user_registration.user.email = params[:email]
  #     else
  #       user_registration.user.email = params[:email].gsub!(/\s+/, "") 
  #     end
  #   end

  #   if params[:gender].present? 
  #     if params[:gender].match(/\s/).blank?
  #       user_registration.user.gender = params[:gender]
  #     else
  #       user_registration.user.gender = params[:gender].gsub!(/\s+/, "") 
  #     end
  #   end

  #   if params[:first_name].present? 
  #     if params[:first_name].match(/\s/).blank?
  #       first_name = params[:first_name]
  #       user_registration.user.first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)

  #     else
  #       first_name = params[:first_name].gsub!(/\s+/, "") 
  #       user_registration.user.first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)

  #     end
  #   end

  #   if params[:instagram_id].present? 
  #     if params[:instagram_id].match(/\s/).blank?
  #       user_registration.user.instagram_id = params[:instagram_id]
  #     else
  #       user_registration.user.instagram_id = params[:instagram_id].gsub!(/\s+/, "") 
  #     end
  #   end

  #   if params[:snapchat_id].present? 
  #     if params[:snapchat_id].match(/\s/).blank?
  #       user_registration.user.snapchat_id = params[:snapchat_id]
  #     else
  #       user_registration.user.snapchat_id = params[:snapchat_id].gsub!(/\s+/, "") 
  #     end
  #   end

  #   if params[:wechat_id].present? 
  #     if params[:wechat_id].match(/\s/).blank?
  #       user_registration.user.wechat_id = params[:wechat_id]
  #     else
  #       user_registration.user.wechat_id = params[:wechat_id].gsub!(/\s+/, "") 
  #     end
  #   end
  #   if params[:line_id].present? 
  #     if params[:line_id].match(/\s/).blank?
  #       user_registration.user.line_id = params[:line_id]
  #     else
  #       user_registration.user.line_id = params[:line_id].gsub!(/\s+/, "") 
  #     end
  #   end
  #   user_registration.user.password = params[:password] if params[:password].present?
  #   user_registration.user.birthday = params[:birthday] if params[:birthday].present?                       
  #   user_registration.user.nonce = params[:nonce] if params[:nonce].present?
  #   user_registration.user.exclusive = params[:exclusive] if params[:exclusive].present?

  #   if !(User.exists? email: params[:email])
  #     if user_registration.create
  #       user = user_registration.user
  #       user.key_expiration = Time.now + 3.hours
  #       user.account_status = 1
  #       user.save
  #       # save avatar order
  #       if !user.nil? and !user.default_avatar.nil?
  #         avatar = user.default_avatar
  #         avatar.order = 0
  #         avatar.save!
  #       end

  #       # #signup with the avatar id
  #       # avatar_id = sign_up_params[:avatar_id]
  #       # response = user.to_json(true)
  #       # response["avatars"] = Array.new
  #       # if avatar_id.to_i > 0
  #       #   avatar = UserAvatar.find(avatar_id.to_i)
  #       #   if !avatar.nil?
  #       #     avatar.user_id = user.id
  #       #     avatar.save
  #       #     user_avatar = Hash.new
  #       #     user_avatar['thumbnail'] = avatar.avatar.thumb.url
  #       #     user_avatar['avatar'] = avatar.avatar.url
  #       #     response["avatars"] = [user_avatar]
  #       #   end
  #       # end

  #       # avatar = sign_up_params[:avatar]
  #       # if avatar
  #       #   user_avatar = UserAvatar.create(user_id: user_registration.id, avatar: avatar, default_boolean: true )
  #       # else
  #       # end
        
  #       # The way in one step
  #       response = user.to_json(true)
  #       user_info = user

  #       # if !response["avatars"].empty?
  #       #   thumb = response["avatars"].first['avatar']
  #       #   if thumb
  #       #     response["avatars"].first['thumbnail'] = thumb
  #       #     response["avatars"].first['avatar'] = thumb.gsub! 'thumb_', ''
  #       #   end
  #       # end
  #       response['token'] = user.generate_token
  #       # render json: user_registration.to_json.inspect
  #       # render json: user_avatar.to_json.inspect
        
  #       intro = "Welcome to Yero"
  #       # TODO: future feature
  #       # n = WhisperNotification.create_in_aws(user_info.id, 0, 1, 2, intro)
        
  #       render json: success(response)
  #     else
  #       puts user_registration.user.errors.messages
  #       render json: error(JSON.parse(user_registration.user.errors.messages.to_json))
  #     end
  #   else
  #       render json: error("This email has already been taken.")
  #   end
  # end

  # API to login a user
  def login
    if params[:email].nil? or params[:email].empty? or params[:password].nil? or params[:password].empty?
      render json: error("Login information missing.")
    else
      if User.exists? email: params[:email]
        user = User.find_by_email(params[:email]) # find by email, skip key

        if user.authenticate(params[:password])
          # Authenticated successfully
          
          user.last_active = Time.now
          user.save!
          user_info = user.to_json(true)
          user_info['token'] = user.generate_token
          render json: success(user_info)
        else
          render json: error("Your email or password is incorrect")
        end  
      else
        render json: error("Email address not found")
      end
    end
  end


  def logout
    current_user.apn_token = ''
    if current_user.save
      render json: success(true)
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
    
  end


  # Update chatting ids
  def update_chat_accounts
    user = current_user

    if !params[:instagram_id].nil? 
      if params[:instagram_id].match(/\s/).blank?
        user.instagram_id = params[:instagram_id]
      else
        user.instagram_id = params[:instagram_id].gsub!(/\s+/, "") 
      end
    end

    if !params[:instagram_token].nil? 
      if params[:instagram_token].match(/\s/).blank?
        user.instagram_token = params[:instagram_token]
      else
        user.instagram_token = params[:instagram_token].gsub!(/\s+/, "") 
      end
    end

    if !params[:snapchat_id].nil? 
      if params[:snapchat_id].match(/\s/).blank?
        user.snapchat_id = params[:snapchat_id]
      else
        user.snapchat_id = params[:snapchat_id].gsub!(/\s+/, "") 
      end
    end

    if !params[:wechat_id].nil? 
      if params[:wechat_id].match(/\s/).blank?
        user.wechat_id = params[:wechat_id]
      else
        user.wechat_id = params[:wechat_id].gsub!(/\s+/, "") 
      end
    end

    if !params[:line_id].nil? 
      if params[:line_id].match(/\s/).blank?
        user.line_id = params[:line_id]
      else
        user.line_id = params[:line_id].gsub!(/\s+/, "") 
      end
    end

    if user.snapchat_id.blank? and user.wechat_id.blank? and user.line_id.blank?
      puts "errorssssss"
      render json: error("You must have at least one chatting account")
    else
      puts "SAVE"
      if user.save
        render json: success(user.to_json(true))
      else
        render json: error(JSON.parse(user.errors.messages.to_json))
      end
    end
  end

  # :nocov:
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
  # :nocov:


  # # Renders a page for user to change password
  # def reset_password
  #   @user = current_user
  #   render "password_reset"
  # end

  # Reset password page and action
  def password_reset
    if !params[:user].blank? and !params[:user][:password_reset_token].blank?
      @user = User.find_by_password_reset_token(params[:user][:password_reset_token])
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
        @user.password_reset_token = ''
        if @user.save
          puts "saved"
          UserMailer.delay.password_change_success(@user)
          flash[:danger] = nil
          flash[:success] = "Password Change Succeeded"
        end
      end
    else
      # @user = current_user
      @user = User.find_by_password_reset_token(params[:password_reset_token])
      @error = Array.new
      flash[:danger] = nil
      puts "we got into else"
    end
  end

  # change to find by email
  def forgot_password
    @user = User.find_by_email(params[:email])
    if !@user.nil?
      @user.password_reset_token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(password_reset_token: random_token)
      end
      if @user.save
        UserMailer.delay.forget_password(@user)
        render json: success(true)
      else
        render json: error("Cannot generate reset password token for this user.")
      end
    else
      render json: error("The email you have used is not valid.")
    end
  end

  # reset email
  def generate_reset_email_verify
    new_email = params[:new_email]
    @user = current_user
    if !new_email.blank? 
      if User.find_by_email(new_email).nil?
        @user.email_reset_token = Base64.urlsafe_encode64(new_email)
        if @user.save
          UserMailer.delay.email_reset(@user)
          render json: success(true)
        else
          render json: error("Cannot generate reset email token for this user.")
        end
      else
        render json: error("There is already an account with this email address.")
      end

    else
      render json: error("New email cannot be blank")
    end
  end

  def email_reset
    if params[:email_reset_token].blank?
      @message = "Invalid email reset token"
    else
      @user = User.find_by_email_reset_token(params[:email_reset_token])
      if @user.nil?
        @message = "Invalid email reset token"
      else
        new_email = Base64.urlsafe_decode64(params[:email_reset_token])
        if User.find_by_email(new_email).nil?
          @user.email = new_email
          @user.email_reset_token = nil
          if @user.save
            @message = "Email verified successfully"
          else
            @message = "Failed to verify your email"
          end
        else
          @message = "There is already an account with this email address."
        end
      end
    end
  end

  

  # Notification settings
  def update_notification_preferences
    network_online = (!params['network_online'].nil? ? (params['network_online'].to_s == '0' or params['network_online'].to_s == 'false') : nil)
    enter_venue_network = (!params['enter_venue_network'].nil? ? (params['enter_venue_network'].to_s == '0' or params['enter_venue_network'].to_s == 'false') : nil)
    leave_venue_network = (!params['leave_venue_network'].nil? ? (params['leave_venue_network'].to_s == '1' or params['leave_venue_network'].to_s == 'true') : nil)
    
    UserNotificationPreference.update_preferences_settings(current_user, network_online, enter_venue_network, leave_venue_network)
    
    render json: success(true)
  end

  

  # return current user object
  def get_profile
    user = current_user
    render json: success(user.to_json(true))
  end

  


  # block user
  def block
    # user = current_user
    if !params[:user_id].nil?
      user_id = params[:user_id].to_i
      if User.exists? id: user_id
        if !BlockUser.check_block(current_user.id, user_id)
          BlockUser.create!(origin_user_id: current_user.id, target_user_id: user_id)
        else

        end
        black_list = BlockUser.blocked_user_ids(current_user.id)
        render json: success(black_list)
      else
        render json: error("Sorry, this user doesn't exist")
      end
    else
      render json: error("Sorry, user_id required")
    end
  end

  # :nocov:
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
          is_friends = true
          users = requests_user_whisper_json(friends, is_friends)
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
  # :nocov:

  private

  

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
          json.id user_object[:id] 
        end
        json.actions ['chat']
        json.timestamp  user["timestamp"]
        json.timestamp_read  Time.at(user["timestamp"])
        json.viewed user["viewed"].blank? ? 0 : user["viewed"]
        json.object_type "user"
        json.object user_object

      end         
    end
    return users 
  end

  

  def sign_up_params
    params.require(:user).permit(:birthday, :nonce, :first_name, :gender, :email, :instagram_id, :snapchat_id, :wechat_id, :line_id, :password, :password_confirmation, :exclusive, user_avatars_attributes: [:avatar, :avatar_tmp])
    # params.require(:user).permit(:birthday, : :first_name, :gender, :avatar_id)
  end

  def login_params
    params.require(:user).permit(:email, :password, :token)
  end

  def get_api_token
    if Rails.env == 'test' && api_token = params[:token].blank? && request.headers.env["X-API-TOKEN"]
      params[:token] = api_token
    end
    if Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
      params[:token] = api_token
    end
  end

end


# NOTES:
# whisper badge number  = notification unviewed number + # friend
# College: 
