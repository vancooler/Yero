class WhispersController < ApplicationController
  before_action :authenticate_api, only: [:api_create]
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
    notification_type = params[:notification_type]
    message = (params[:message].nil? and notification_type == "2") ? "Chat Request" : params[:message]

    n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type)

    n.send_push_notification_to_target_user(message)
  end

  def api_create
    # @whisper = Whisper.new(origin_id: current_user.id, target_id: params[:target_id])
    # # if read_notification = current_user.read_notification
    # # else
    # #   read_notification = ReadNotification.new
    # #   read_notification.user = current_user
    # # end

    # # read_notification.before_sending_whisper_notification = true
    # # read_notification.save
    
    # if @whisper.save
    #   render json: success(@whisper.to_json)
    # else
    #   render json: error(@whisper.errors.to_json)
    # end
    # 

    target_id = params[:target_id]
    origin_id = params[:origin_id].nil? ? 0 : params[:origin_id]
    venue_id = params[:venue_id].nil? ? 0 : params[:venue_id]
    notification_type = params[:notification_type]
    if params[:message].nil? and notification_type == "2"
      message = current_user.first_name + " just whispered you! (swipe to view profile)" 
    else
      message = params[:message]
    end

    if notification_type == "2"
      origin_id = current_user.id.to_s
    end
    n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type)
    if n and notification_type == "2"
      current_user.notification_read += 1
      current_user.save
    end
    n.send_push_notification_to_target_user(message)
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

  def api_delete
    id = params[:notification_id]
    result = WhisperNotification.delete_notification(id, current_user)

    if result
      render json: success 
    else
      render json: error
    end
  end

  def chat_accept
    id = params[:notification_id]
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      render json: error('Request not fount')
    else
      attributes = item.attributes.to_h
      notification_type = attributes['notification_type'].to_s
      target_id = attributes['target_id'].to_s
      if notification_type == "2" and target_id == current_user.id.to_s
        result = WhisperNotification.chat_accept(id)
        if result
          render json: success 
        else
          render json: error('Could not accept the chat request.')
        end
      else
        render json: error('Request not fount')
      end
    end
  end


  def all_my_chat_requests
    items = WhisperNotification.my_chatting_requests(current_user.id.to_s)
    render json: success(items)
  end
end


# "whisper"=>{"target_id"=>"162",