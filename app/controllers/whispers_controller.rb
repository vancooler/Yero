class WhispersController < ApplicationController
  prepend_before_filter :get_api_token, only: [:api_create, :chat_request_history, :whisper_request_state, :api_decline_all_chat]

  before_action :authenticate_api, only: [:api_create, :chat_request_history, :whisper_request_state, :api_decline_all_chat]
  skip_before_filter  :verify_authenticity_token

  def new
    @whisper = Whisper.new
    # @origin_user = User.find_by(apn_token: "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>")
    @origin_user = User.find_by(apn_token: "<12bc56a79a8859aa12c86fb5712debac3199a4af48e7fc1479bd1289805dfbf3>")
  end

  def create
    # origin_user = current_user || User.find(params[:origin_id])
    # target_user = User.find(params[:whisper_target])
    @whisper = Whisper.new(origin_id: params[:whisper][:origin_id], target_id: params[:whisper][:target_id])
    if @whisper.save
      render json: success(@whisper)
    else
      render json: error(@whisper.errors)
    end
  end


  def create_by_url
    target_id = params[:target_id]
    origin_id = params[:origin_id].nil? ? 0 : params[:origin_id]
    venue_id = params[:venue_id].nil? ? 0 : params[:venue_id]
    notification_type = params[:notification_type].to_s
    message = (params[:message].nil? and notification_type == "2") ? "Chat Request" : params[:message]
    intro = params[:intro].blank? ? "" : params[:intro].to_s
    n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type, intro)

    n.send_push_notification_to_target_user(message)
  end

  def api_create
    target_id = params[:target_id]
    origin_id = params[:origin_id].nil? ? 0 : params[:origin_id]
    venue_id = params[:venue_id].nil? ? 0 : params[:venue_id]
    notification_type = params[:notification_type].to_s
    intro = params[:intro].blank? ? "" : params[:intro].to_s
    
    if params[:message].nil? and notification_type == "2"
      message = current_user.first_name + " just sent you a Whisper!"   
    else
      message = params[:message]
    end

    if notification_type == "2"
      origin_id = current_user.id.to_s
    end
    
    n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type, intro)
    if n and notification_type == "2"
      record_found = WhisperSent.where(:origin_user_id => origin_id.to_i).where(:target_user_id => target_id.to_i)
      if record_found.count <= 0
        WhisperSent.create_new_record(origin_id.to_i, target_id.to_i)
      else
        record_found.first.update(:whisper_time => Time.now)
      end
    end
    n.send_push_notification_to_target_user(message)
      
    render json: success
  end

  def api_read
    id = params[:notification_id]
    result = WhisperNotification.read_notification(id, current_user)
    venue = WhisperNotification.venue_info(id)

    if result
      render json: success(venue) 
    else
      render json: error(venue)
    end
  end

  def get_info
    # result = WhisperNotification.read_notification(id, current_user)

    
    notifications = WhisperNotification.get_info(current_user)
    if notifications.nil?
      render json: error("Nothing there")
    else
      render json: success(notifications)
    end
  end

  def api_delete
    id = params[:notification_id]
    result = WhisperNotification.delete_notification(id, current_user)

    if result
      render json: success 
    else
      render json: error("Cannot delete!")
    end
  end

  def api_decline_all_chat
    ids = params[:notification_ids]
    result = WhisperNotification.decline_all_chat(current_user, ids)

    if result
      render json: success 
    else
      render json: error("Cannot decline!")
    end
  end

  def chat_action
    id = params[:notification_id]
    handle_action = params[:handle_action]
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      render json: error('Request not found')
    else
      attributes = item.attributes.to_h
      notification_type = attributes['notification_type'].to_s
      target_id = attributes['target_id'].to_s
      if notification_type == "2" and target_id == current_user.id.to_s
        result = WhisperNotification.chat_action(id, handle_action)
        if result
          render json: success 
        else
          render json: error('Could not accept/decline the chat request.')
        end
      else
        render json: error('Request not found')
      end
    end
  end

  def whisper_request_state
    whisperId = params[:whisper_id]

    if params[:accepted].to_i == 1 or params[:declined].to_i == 1
      if params[:accepted].to_i == 1
        state = 'accepted'
        WhisperNotification.find_whisper(whisperId, state)
        item = WhisperNotification.find_by_dynamodb_id(whisperId)
        origin_id = 0
        target_id = 0
        if item.nil?
          
        else 
          attributes = item.attributes.to_h
          origin_id = attributes['origin_id'].to_i
          target_id = attributes['target_id'].to_i
          venue_id = attributes['venue_id'].to_i
        end
        if origin_id.to_i <= 0 
          render json: success
        elsif !n.nil?
          if FriendByWhisper.check_friends(origin_id, target_id)
          else
            n = WhisperNotification.create_in_aws(origin_id, target_id, venue_id, "3", "")
            FriendByWhisper.create!(:target_user_id => target_id, :origin_user_id => origin_id)
            user = User.find(target_id.to_i)
            message = user.first_name + " is now your friend!"
            n.send_push_notification_to_target_user(message)
          end
          render json: success
        else
          render json: error('There was an error.')
        end
      elsif params[:declined].to_i == 1
        state = 'declined'
        WhisperNotification.find_whisper(whisperId, state)
        render json: success
      else
        render json: error('There was an error.')
      end
    else
      render json: error('There was an error.')
    end
  end

  def all_my_chat_requests
    # role = params[:role] # "origin", "target", "both"
    items = WhisperNotification.my_chatting_requests(current_user.id.to_s)
    render json: success(items)
  end

  def chat_request_history
    page_number = nil
    venues_per_page = nil
    page_number = params[:page].to_i + 1 if !params[:page].blank?
    whispers_per_page = params[:per_page].to_i if !params[:per_page].blank?

    items = WhisperNotification.my_chat_request_history(current_user, page_number, whispers_per_page)
    render json: success(items)
  end

  def decline_whisper_requests
    puts params[:array]
    if params[:array].blank?
      render json: error("ID array is empty")
    else
      whispers_delete = WhisperNotification.delete_whispers(params[:array].to_a)
      render json: success(whispers_delete)
    end
  end

  def get_api_token
    if api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
      params[:token] = api_token
    end
  end
end
