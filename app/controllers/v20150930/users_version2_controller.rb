module V20150930
  class UsersVersion2Controller < ApplicationController
    prepend_before_filter :get_api_token, except: [:check_email, :signup, :login, :forgot_password]
    before_action :authenticate_api_v2, except: [:check_email, :signup, :login, :forgot_password]

  ############################################ API V 2 ############################################

    # API V2
    # get a single user object of given user_id
    def show
      user_id = params[:id]
      
      user = User.find_user_by_unique(user_id)
      if user.nil?
        error_obj = {
          code: 404,
          message: "Sorry, cannot find the user"
        }
        render json: error(error_obj, 'error')
      else
        user_obj = user.user_object(current_user)
        render json: success(user_obj)
      end
    end

    # API V2
    # update current user with given fields and return user object
    def update
      user = current_user
      result = true
      if !params[:username].blank?
        if !User.where('lower(username) = ?', params[:username].downcase).empty?
          result = false
          error_obj = {
            code: 403,
            message: "Username exists"
          }
          render json: error(error_obj, 'error')
        end
      end

      if result
        if !params[:username].nil? 
          if params[:username].match(/\s/).blank?
            user.username = params[:username]
          else
            user.username = params[:username].gsub!(/\s+/, "") 
          end
        end

        if !params[:wechat_id].nil? 
          if params[:wechat_id].match(/\s/).blank?
            user.wechat_id = params[:wechat_id]
          else
            user.wechat_id = params[:wechat_id].gsub!(/\s+/, "") 
          end
        end

        if !params[:snapchat_id].nil? 
          if params[:snapchat_id].match(/\s/).blank?
            user.snapchat_id = params[:snapchat_id]
          else
            user.snapchat_id = params[:snapchat_id].gsub!(/\s+/, "") 
          end
        end

        if !params[:line_id].nil? 
          if params[:line_id].match(/\s/).blank?
            user.line_id = params[:line_id]
          else
            user.line_id = params[:line_id].gsub!(/\s+/, "") 
          end
        end
        
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

        if !params[:spotify_id].nil? 
          if params[:spotify_id].match(/\s/).blank?
            user.spotify_id = params[:spotify_id]
          else
            user.spotify_id = params[:spotify_id].gsub!(/\s+/, "") 
          end
        end

        if !params[:spotify_token].nil? 
          if params[:spotify_token].match(/\s/).blank?
            user.spotify_token = params[:spotify_token]
          else
            user.spotify_token = params[:spotify_token].gsub!(/\s+/, "") 
          end
        end

        if !params[:introduction_1].nil? 
          user.introduction_1 = params[:introduction_1]
        end

        # status
        if !params[:status].nil? 
          user.introduction_2 = params[:status]
          user.last_status_active_time = Time.now
        end

        if !params[:exclusive].nil?
          user.exclusive = params[:exclusive]
        end

        if !params[:discovery].nil?
          user.discovery = params[:discovery]
        end

        if !params[:timezone].nil?
          user.timezone_name = params[:timezone]
          if TimeZonePlace.find_by_timezone(params[:timezone]).nil?
            TimeZonePlace.create!(timezone: params[:timezone], time_no_active: 0)
          end
        end

        if !params[:latitude].nil?
          user.latitude = params[:latitude].to_f
        end

        if !params[:longitude].nil?
          user.longitude = params[:longitude].to_f
        end

        if !params[:locality].nil?
          user.current_city = params[:locality]
        end

        if !params[:subLocality].nil?
          user.current_sublocality = params[:subLocality]
        end


        avatar_ids = params[:avatars].blank? ? [] : params[:avatars].to_a

        if user.save and user.avatar_reorder(avatar_ids)
          render json: success(user.to_json(false))
        else
       	  # :nocov:
          error_obj = {
      	    code: 520,
      	    message: "Cannot update the user."
      	  }
      	  render json: error(error_obj, 'error')
          # :nocov:
        end
      end
    end

    # API V2
    # get people list with filter
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
        error_obj = {
          code: 403,
          message: "No photos",
          external_message: 'Please upload a profile photo first'
        }
        render json: error(error_obj, 'error')
      else
        user = current_user
        # user.join_network
        # puts user
        gender = params[:gender] if !params[:gender].blank?
        min_age = params[:min_age].to_i if !params[:min_age].blank?
        max_age = params[:max_age].to_i if !params[:max_age].blank?
        min_distance = params[:min_distance].to_i if !params[:min_distance].blank?
        max_distance = params[:max_distance].to_i if !params[:max_distance].blank?
        venue_id = params[:venue_id].to_i if !params[:venue_id].blank?
        puts "EVERYONE: " + params[:everyone].to_s
        everyone = true
        everyone = ((params[:everyone].to_s == "true" or params[:everyone].to_s == "1") ? true : false) if !params[:everyone].nil?
        puts "EVERYONE2: " + everyone.to_s
        page_number = nil
        users_per_page = nil
        page_number = params[:page].to_i + 1 if !params[:page].blank?
        users_per_page = params[:per_page].to_i if !params[:per_page].blank?

        result = current_user.people_list_2_0(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
        
        if result['users'].nil?
          render json: success(result) #Return users
        else
          user.enough_user_notification_sent_tonight = true
          user.save
          response = {
            users: result['users']
          }
          render json: success(response, "data", result['pagination'])
        end   
      end
    end


    # API V2
    # check email address avalable to signup
    def check_email
      if !params[:email].blank? or !params[:username].blank?
        result = true
        if !params[:email].blank?
          if User.exists? email: params[:email]
            result = false
            error_obj = {
              code: 403,
              message: "Email address exists"
            }
            render json: error(error_obj, 'error')
          end
        end
        if !params[:username].blank?
          if !User.where('lower(username) = ?', params[:username].downcase).empty?
            result = false
            error_obj = {
              code: 403,
              message: "Username exists"
            }
            render json: error(error_obj, 'error')
          end
        end
        if result
          render json: success()
        end
      else 
        error_obj = {
          code: 400,
          message: "Invalid params"
        }
        render json: error(error_obj, 'error')
      end
    end

    ##########################################
    #
    # Signup user without avatar
    # 
    ##########################################
    def signup
      if params[:email].blank? or params[:username].blank? or params[:password].blank? or params[:birthday].blank? or params[:gender].blank?
        error_obj = {
          code: 400,
          message: "Required fields cannot be blank",
          external_message: 'Please fill the required fields'
        }
        render json: error(error_obj, 'error')
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

        if params[:username].match(/\s/).blank?
          username = params[:username]
        else
          username = params[:username].gsub!(/\s+/, "") 
        end

        if params[:first_name].present? 
          if params[:first_name].match(/\s/).blank?
            first_name = params[:first_name]
            first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)
          else
            first_name = params[:first_name].gsub!(/\s+/, "") 
            first_name = first_name.slice(0,1).capitalize + first_name.slice(1..-1)
          end
        end

        @user = User.new(:email => email,
                         :password => params[:password],
                         :birthday => params[:birthday],
                         :first_name => first_name,
                         :gender => gender,
                         :username => username)
                         
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

        @user.account_status = 1
        @user.last_active = Time.now
        if (User.exists? email: email)
          error_obj = {
            code: 400,
            message: "This email has already been taken.",
            external_message: 'Your email is token by another account'
          }
          render json: error(error_obj, 'error')
        elsif (User.exists? username: username)
          error_obj = {
            code: 400,
            message: "This username has already been taken.",
            external_message: 'Your username is token by another account'
          }
          render json: error(error_obj, 'error')
        else
          if @user.save
            response = @user.to_json(true)
            response['token'] = @user.generate_token(true)
            intro = "Welcome to Yero"
            # TODO: future feature
            # n = WhisperNotification.create_in_aws(@user.id, 0, 1, 2, intro)
            
            render json: success(response)
          else
            # :nocov:
            error_obj = {
      		    code: 520,
      		    message: "Cannot sign up this user."
      		  }
      		  render json: error(error_obj, 'error')
            # :nocov:
          end
        	  
        end
      end
    end

    # API to login a user
    def login
      if params[:email].nil? or params[:email].empty? or params[:password].nil? or params[:password].empty?
        error_obj = {
          code: 400,
          message: "Login information missing.",
          external_message: 'Please fill the required fields'
        }
        render json: error(error_obj, 'error')
      else
        if User.exists? email: params[:email]
          user = User.find_by_email(params[:email]) # find by email, skip key

          if user.authenticate(params[:password])
            # Authenticated successfully
            
            user.last_active = Time.now
            user.save!
            ActiveInVenue.leave_venue(nil, user)
            user_info = user.to_json(true)
            user_info['token'] = user.generate_token(true)
            render json: success(user_info)
          else
            error_obj = {
  	        code: 403,
  	        message: "Your email or password is incorrect",
            external_message: 'Email and password do not match'
  	      }
            render json: error(error_obj, 'error')
          end  
        else
          error_obj = {
  	      code: 403,
  	      message: "Email address not found",
          external_message: 'Sorry, cannot find account with ' + params[:email]
  	    }
  	    render json: error(error_obj, 'error')
        end
      end
    end

    def logout
      render json: success(true)
    end

    # reset email
    def change_email
      new_email = params[:new_email]
      @user = current_user
      if !new_email.blank? 
        if User.find_by_email(new_email).nil?
          @user.email_reset_token = Base64.urlsafe_encode64(new_email)
          if @user.save
            UserMailer.delay.email_reset(@user)
            render json: success(true)
          else
            # :nocov:
            error_obj = {
      		    code: 520,
      		    message: "Cannot generate reset email token for this user."
      		  }
      		  render json: error(error_obj, 'error')
            # :nocov:
          end
        else
  	    error_obj = {
    		  code: 403,
    		  message: "There is already an account with this email address.",
          external_message: 'Your email is token by another account'
    		}
  		render json: error(error_obj, 'error')
        end

      else
        error_obj = {
  	    code: 400,
  	    message: "New email cannot be blank",
        external_message: 'Please fill the required fields'
  	  }
  	  render json: error(error_obj, 'error')
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
          # :nocov:
          error_obj = {
      		  code: 520,
        	  message: "Cannot generate reset password token for this user."
      		}
  	    render json: error(error_obj, 'error')
        # :nocov:
        end
      else
        error_obj = {
      		code: 404,
      		message: "Cannot find accout with your email address",
          external_message: 'Sorry, cannot find account with ' + params[:email]
        }
  	  render json: error(error_obj, 'error')
      end
    end

    # Notification settings
    def update_notification_preferences
      # network_online = (!params['network_online'].nil? ? (params['network_online'].to_s == '0' or params['network_online'].to_s == 'false') : nil)
      # enter_venue_network = (!params['enter_venue_network'].nil? ? (params['enter_venue_network'].to_s == '0' or params['enter_venue_network'].to_s == 'false') : nil)
      # leave_venue_network = (!params['leave_venue_network'].nil? ? (params['leave_venue_network'].to_s == '1' or params['leave_venue_network'].to_s == 'true') : nil)
      preferences = params['notification_settings']
      UserNotificationPreference.update_preferences_settings_v2(current_user, preferences)
      render json: success(true)
    end


    ########################
    # To report a user
    # Params: [:key, user_id, type_id, :reason]
    #
    #########################
    def report
      reporting_user = current_user
      reported_user = User.find_user_by_unique(params[:user_id])
      report_type = ReportType.find_by_id(params[:type_id])
      if !reporting_user.nil? and !reported_user.nil? and !report_type.nil?
        	record = ReportUserHistory.find_by_reporting_user_id_and_reported_user_id_and_report_type_id(reporting_user.id, reported_user.id, report_type.id)
        	# no report record found
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
  	      # :nocov:
          error_obj = {
    		    code: 520,
      	    message: "Cannot report this user."
    		  }
  	      render json: error(error_obj, 'error')
          # :nocov:
  	    end
        
      else
        	error_obj = {
      		  code: 400,
      		  message: "Invalid params",
    	    }
      		render json: error(error_obj, 'error')
      end
      
    end

    def collection_delete
      # user = current_user
      if !params[:object_type].blank? and !params[:ids].blank?
        model_name = params[:object_type]
        model = nil
        case model_name
        when "whispers"
          if Rails.env == 'production'
            # :nocov:
            WhisperNotification.delay.delete_whispers(params[:ids].to_a)
            # :nocov:
          else
            whisper_id_array = WhisperToday.where(dynamo_id: params[:ids].to_a).map(&:id)
            WhisperReply.where(whisper_id: whisper_id_array).delete_all
            WhisperToday.where(dynamo_id: params[:ids].to_a).delete_all
          end
          whispers_delete = WhisperToday.where(dynamo_id: params[:ids].to_a).update_all(:declined => true)
          render json: success

        when "conversations"
          whispers = Conversation.where(dynamo_id: params[:ids].to_a)

          whispers.each do |whisper|
            whisper.archive_conversation(current_user)
          end
          render json: success

        when "block_users"
          block_users_delete = BlockUser.where(origin_user_id: current_user.id, target_user_id: params[:ids].to_a).delete_all
          render json: success

        when "friends"
          FriendByWhisper.where(origin_user_id: current_user.id, target_user_id: params[:ids].to_a).delete_all
          FriendByWhisper.where(origin_user_id: params[:ids].to_a, target_user_id: current_user.id).delete_all
          render json: success
        end
        
      else
        	error_obj = {
      		  code: 400,
      		  message: "Invalid parameters"
    	    }
      		render json: error(error_obj, 'error')
      end
    end


  ######################################### End of API V 2 #########################################

    private
    def get_api_token
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        # :nocov:
        params[:token] = api_token 
        # :nocov:
      end
    end


  end
end