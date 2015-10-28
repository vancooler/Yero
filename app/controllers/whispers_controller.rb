class WhispersController < ApplicationController
  prepend_before_filter :get_api_token, only: [:api_create, :chat_request_history, :whisper_request_state, :api_decline_all_chat, :show]

  before_action :authenticate_api, only: [:api_create, :chat_request_history, :whisper_request_state, :api_decline_all_chat, :show]
  skip_before_filter  :verify_authenticity_token
  before_action :authenticate_admin_user!, only: [:send_test_whisper]

  def show
    whisper_id = params[:id]
    if !/\A\d+\z/.match(whisper_id.to_s)
      whisper = WhisperToday.find_by_dynamo_id(whisper_id)
    else
      whisper = WhisperToday.find_pending_whisper(whisper_id.to_i, current_user.id)
    end
    if whisper.blank?
      error_obj = {
        code: 404,
        message: "Sorry, cannot find the whisper"
      }
      render json: error(error_obj, 'data')
    else

      if current_user.id != whisper.origin_user_id and current_user.id != whisper.target_user_id
        error_obj = {
          code: 403,
          message: "Sorry, you don't have access to it"
        }
        render json: error(error_obj, 'data')
      elsif BlockUser.check_block(whisper.origin_user_id.to_i, whisper.target_user_id.to_i)
        error_obj = {
          code: 403,
          message: "Sorry, you don't have access to it"
        }
        render json: error(error_obj, 'data')
      elsif whisper.photo_disabled(current_user.id)
        error_obj = {
          code: 403,
          message: "Sorry, you don't have access to it"
        }
        render json: error(error_obj, 'data')
      else
        whisper_array = WhisperToday.to_json([whisper], current_user)
        if !whisper_array.nil? and !whisper_array.first.nil?
          whisper_obj = whisper_array.first
          render json: success(whisper_obj)
        else
          # :nocov:
          error_obj = {
            code: 404,
            message: "Sorry, cannot find the whisper"
          }
          render json: error(error_obj, 'data')
          # :nocov:
        end
      end
    end
  end

  # :nocov:
  def send_test_whisper
    target_id = params[:target_user_id]
    origin_id = params[:origin_user_id]
    venue_id = 0
    notification_type = "2"
    intro = params[:message].blank? ? "" : params[:message].to_s
    origin_user = User.find_by_id(origin_id.to_i)
    target_user = User.find_by_id(target_id.to_i)
    if target_user.nil?
      @message = "Cannot find target user!" 
    elsif origin_user.nil? 
      @message = "Cannot find origin user!"
    else
      message = origin_user.first_name + " just sent you a whisper"   
      result = WhisperNotification.send_message(target_id, origin_user, venue_id, notification_type, intro, message)

      if result == "true"
        @message = "Whisper sent!"
      else
        @message = result
      end
    end
    redirect_to :back, :notice => @message
  end
  # :nocov:

  # Create a whisper
  def api_create
    target_id = params[:target_id]
    venue_id = params[:venue_id].nil? ? 0 : params[:venue_id]
    notification_type = params[:notification_type].to_s
    intro = params[:intro].blank? ? "" : params[:intro].to_s
    message = current_user.first_name + " just sent you a whisper"   
    
    result = WhisperNotification.send_whisper(target_id, current_user, venue_id, notification_type, intro, message)

    if result == "true"
      render json: success
    else
      render json: error(result)
    end  
  end

  # def api_read
  #   id = params[:notification_id]
  #   result = WhisperNotification.read_notification(id, current_user)
  #   venue = WhisperNotification.venue_info(id)

  #   if result
  #     render json: success(venue) 
  #   else
  #     render json: error(venue)
  #   end
  # end

  # def get_info
  #   # result = WhisperNotification.read_notification(id, current_user)

    
  #   notifications = WhisperNotification.get_info(current_user)
  #   if notifications.nil?
  #     render json: error("Nothing there")
  #   else
  #     render json: success(notifications)
  #   end
  # end

  # def api_delete
  #   id = params[:notification_id]
  #   result = WhisperNotification.delete_notification(id, current_user)

  #   if result
  #     render json: success 
  #   else
  #     render json: error("Cannot delete!")
  #   end
  # end

  # def api_decline_all_chat
  #   ids = params[:notification_ids]
  #   result = WhisperNotification.decline_all_chat(current_user, ids)

  #   if result
  #     render json: success 
  #   else
  #     render json: error("Cannot decline!")
  #   end
  # end

  # def chat_action
  #   id = params[:notification_id]
  #   handle_action = params[:handle_action]
  #   item = WhisperNotification.find_by_dynamodb_id(id)
  #   if item.nil?
  #     render json: error('Request not found')
  #   else
  #     attributes = item.attributes.to_h
  #     notification_type = attributes['notification_type'].to_s
  #     target_id = attributes['target_id'].to_s
  #     if notification_type == "2" and target_id == current_user.id.to_s
  #       result = WhisperNotification.chat_action(id, handle_action)
  #       if result
  #         render json: success 
  #       else
  #         render json: error('Could not accept/decline the chat request.')
  #       end
  #     else
  #       render json: error('Request not found')
  #     end
  #   end
  # end


  # accept/decline a whisper
  def whisper_request_state
    whisperId = params[:whisper_id]

    item = WhisperToday.find_by_dynamo_id(whisperId)
    if item 
      if params[:accepted].to_i == 1 and item.target_user_id.to_i == current_user.id
        state = 'accepted'
        if Rails.env == 'production'
          # :nocov:
          WhisperNotification.delay.find_whisper(whisperId, state)
          # :nocov:
        else
          WhisperNotification.find_whisper(whisperId, state)
        end
        # item = WhisperNotification.find_by_dynamodb_id(whisperId)
        origin_id = 0
        target_id = 0
        if item.nil?
          
        else 
          # attributes = item.attributes.to_h
          origin_id = item.origin_user_id.to_i
          target_id = item.target_user_id.to_i
          venue_id = item.venue_id.nil? ? 0 : item.venue_id.to_i
        end
        if origin_id.to_i <= 0 
          # :nocov:
          render json: error('There was an error.')
          # :nocov:
        else
          if FriendByWhisper.check_friends(origin_id, target_id) 
            # :nocov:
            render json: error('You are already friends.')
            # :nocov:
          elsif BlockUser.check_block(origin_id, target_id)
            # :nocov:
            render json: error('User blocked.')
            # :nocov:
          else
            if Rails.env == 'production'
              # :nocov:
              n = WhisperNotification.create_in_aws(origin_id, target_id, venue_id, "3", "")
              # :nocov:
            else
              n = WhisperNotification.new 
            end
            if !n.nil?
              current_time = Time.now
              FriendByWhisper.create!(:target_user_id => target_id, :origin_user_id => origin_id, :friend_time => current_time, :viewed => false)
              RecentActivity.add_activity(origin_id.to_i, '3', target_id.to_i, nil, "friend-"+origin_id.to_s+"-"+target_id.to_s+"-"+current_time.to_i.to_s)
              RecentActivity.add_activity(target_id.to_i, '3', origin_id.to_i, nil, "friend-"+target_id.to_s+"-"+origin_id.to_s+"-"+current_time.to_i.to_s)
              WhisperReply.where(whisper_id: item.id).delete_all
              user = User.find(target_id.to_i)
              if Rails.env == 'production'
                # :nocov:
                message = user.first_name + " is now your friend!"
                n.send_push_notification_to_target_user(message, 0)
                # :nocov:
              end
              if Rails.env == 'production'
                # :nocov:
                WhisperReply.delay.archive_history(item)
                # :nocov:
              else
                WhisperReply.where(whisper_id: item.id).delete_all
                item.delete
              end
              render json: success
            else
              # :nocov:
              render json: error('There was an error.')
              # :nocov:
            end
          end
        end
      elsif params[:declined].to_i == 1
        state = 'declined'
        if Rails.env == 'production'
          # :nocov:
          WhisperNotification.delay.find_whisper(whisperId, state)
          # :nocov:
        else
          WhisperNotification.find_whisper(whisperId, state)
        end
        if Rails.env == 'production'
          # :nocov:
          WhisperReply.delay.archive_history(item)
          # :nocov:
        else
          WhisperReply.where(whisper_id: item.id).delete_all
          item.delete
        end
        render json: success
      else
        render json: error('There was an error.')
      end
    else
      render json: error('Cannot find the whisper.')
    end
  end

  # def all_my_chat_requests
  #   # role = params[:role] # "origin", "target", "both"
  #   items = WhisperNotification.my_chatting_requests(current_user.id.to_s)
  #   render json: success(items)
  # end


  # Activity history
  def chat_request_history
    page_number = nil
    venues_per_page = nil
    page_number = params[:page].to_i + 1 if !params[:page].blank?
    whispers_per_page = params[:per_page].to_i if !params[:per_page].blank?

    items = WhisperNotification.my_chat_request_history(current_user, page_number, whispers_per_page)
    puts "ACtivity"
    puts items.inspect
    render json: success(items)
  end

  def decline_whisper_requests
    puts params[:array]
    if params[:array].blank?
      render json: error("ID array is empty")
    else
      if Rails.env == 'production'
        # :nocov:
        WhisperNotification.delay.delete_whispers(params[:array].to_a)
        # :nocov:
      else
        whisper_id_array = WhisperToday.where(dynamo_id: params[:array].to_a).map(&:id)
        WhisperReply.where(whisper_id: whisper_id_array).delete_all
        WhisperToday.where(dynamo_id: params[:array].to_a).delete_all
      end
      whispers_delete = WhisperToday.where(dynamo_id: params[:array].to_a).update_all(:declined => true)
      render json: success(whispers_delete)
    end
  end


  def get_api_token
    if Rails.env == 'test' && api_token = params[:token].blank? && request.headers.env["X-API-TOKEN"]
      params[:token] = api_token
    end
    if Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
      # :nocov:
      params[:token] = api_token
      # :nocov:
    end
  end
end
