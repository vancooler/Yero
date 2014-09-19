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
    message = params[:message]

    WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type)
    WhisperNotification.send_push_notification_to_target_user(message)
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
end


# "whisper"=>{"target_id"=>"162",