module V20150930
  class ConversationsController < ApplicationController
    prepend_before_filter :get_api_token, only: [:create, :index, :update, :destroy, :show, :show_messages, :show_single_message]
    before_action :authenticate_api_v2, only: [:create, :index, :update, :destroy, :show, :show_messages, :show_single_message]

    def index
      # badge = WhisperNotification.unviewd_whisper_number(current_user.id)
      whispers = Conversation.conversations_related(current_user.id)

      page_number = nil
      per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      per_page = params[:per_page].to_i if !params[:per_page].blank?

      pagination = Hash.new
      if !page_number.nil? and !per_page.nil? and per_page > 0 and page_number >= 0
        pagination['page'] = page_number - 1
        pagination['per_page'] = per_page
        pagination['total_count'] = whispers.length
        whispers = Kaminari.paginate_array(whispers).page(page_number).per(per_page) if !whispers.nil?
      end

      if !whispers.blank?
        whispers = Conversation.conversations_to_json(whispers, current_user)
      end

      response_data = {
        # badge_number: badge,
        conversations: whispers
      }
      render json: success(response_data, "data", pagination)
    end


    def show
      whisper_id = params[:id]
      read_messages = (!params['read'].nil? ? (params['read'].to_s == '1' or params['read'].to_s == 'true') : true)
      
      if !/\A\d+\z/.match(whisper_id.to_s)
        whisper = Conversation.find_by_dynamo_id(whisper_id)
      else
        whisper = Conversation.find_pending_whisper(whisper_id.to_i, current_user.id)
      end
      if whisper.blank?
        error_obj = {
          code: 404,
          message: "Sorry, cannot find the whisper"
        }
        render json: error(error_obj, 'error')
      else

        if current_user.id != whisper.origin_user_id and current_user.id != whisper.target_user_id
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        elsif BlockUser.check_block(whisper.origin_user_id.to_i, whisper.target_user_id.to_i)
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        elsif whisper.photo_disabled(current_user.id)
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        else
          page_number = 1
          per_page = 10
          per_page = params[:per_page].to_i if !params[:per_page].blank?
          # read_messages = true
          result = whisper.chatting_replies(current_user, page_number, per_page, read_messages)

          whispers_json = Conversation.conversations_to_json([whisper], current_user)
          whisper_json = whispers_json.first

          whisper_json[:messages] = result['messages']
          render json: success(whisper_json, 'data', result['pagination'])
        end
      end
    end


    def show_single_message
      message_id = params[:id]
      read = (!params['read'].nil? ? (params['read'].to_s == '1' or params['read'].to_s == 'true') : true)
      
      message = ChattingMessage.find_by_id(message_id)
      if !message.nil?
        if message.whisper.target_user_id != current_user.id and message.whisper.origin_user_id != current_user.id
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        else
          if read
            message.read = true
            message.save
          end
          message_json = message.to_json(current_user)

          render json: success(message_json, 'data')
        end

      else
        error_obj = {
          code: 404,
          message: "Sorry, cannot find the message"
        }
        render json: error(error_obj, 'error')
      end
    end


    def show_messages
      whisper_id = params[:conversation_id]
      if !/\A\d+\z/.match(whisper_id.to_s)
        whisper = Conversation.find_by_dynamo_id(whisper_id)
      else
        whisper = Conversation.find_pending_whisper(whisper_id.to_i, current_user.id)
      end
      if whisper.blank?
        error_obj = {
          code: 404,
          message: "Sorry, cannot find the whisper"
        }
        render json: error(error_obj, 'error')
      else

        if current_user.id != whisper.origin_user_id and current_user.id != whisper.target_user_id
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        elsif BlockUser.check_block(whisper.origin_user_id.to_i, whisper.target_user_id.to_i)
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        elsif whisper.photo_disabled(current_user.id)
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        else
          page_number = nil
          per_page = nil
          page_number = params[:page].to_i + 1 if !params[:page].blank?
          per_page = params[:per_page].to_i if !params[:per_page].blank?
          read_messages = true
          result = whisper.chatting_replies(current_user, page_number, per_page, read_messages)
          response_data = {
            # badge_number: badge,
            messages: result['messages']
          }
          render json: success(response_data, 'data', result['pagination'])
        end
      end
    end

    # create_single_message
    def create_single_message
      time_0 = Time.now
      target_id = params[:target_id]
      notification_type = '2'
      intro = params[:message].blank? ? "" : params[:message].to_s
      client_side_id = params[:id].blank? ? nil : params[:id].to_s
      content_type = params[:content_type].blank? ? "text" : params[:content_type]
      image_url = params[:image_url].blank? ? "" : params[:image_url]
      audio_url = params[:audio_url].blank? ? "" : params[:audio_url]
      timestamp = params[:timestamp].blank? ? nil : params[:timestamp].to_f
      message = current_user.first_name + " sent you a whisper"   
      venue_id = nil

      target_user = User.find_user_by_unique(target_id)

      if target_user
        time_1 = Time.now
        result = WhisperNotification.send_message(target_user.id, current_user, venue_id, notification_type, intro, message, timestamp, content_type, image_url, audio_url, client_side_id)
        time_2 = Time.now
        if result['message'] == "true"
          chat_message = result['chat_message']
          message_json = chat_message.to_json(current_user)
          # read_messages = false
          # # result = whisper.chatting_replies(current_user, nil, nil, read_messages)

          # whispers_json = Conversation.conversations_to_json([whisper], current_user)
          # whisper_json = whispers_json.first
          time_3 = Time.now
          puts "Preparing Time: " + (time_1 - time_0).inspect
          puts "Sending Time: " + (time_2 - time_1).inspect
          puts "Json Time: " + (time_3 - time_2).inspect
          # whisper_json[:messages] = result['messages']
          render json: success(message_json, 'data')
        else
          error_obj = {
            code: 403,
            message: result['message']
          }
          if result['message'] != "User blocked"
            error_obj[:external_message] = result['message']
          end
          render json: error(error_obj, 'error')
        end  
      else
        # :nocov:
        error_obj = {
          code: 404,
          message: 'Cannot find the user'
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end

    # Create a whisper
    def create
      time_0 = Time.now
      target_id = params[:target_id]
      notification_type = '2'
      intro = params[:message].blank? ? "" : params[:message].to_s
      client_side_id = params[:id].blank? ? nil : params[:id].to_s
      content_type = params[:content_type].blank? ? "text" : params[:content_type]
      image_url = params[:image_url].blank? ? "" : params[:image_url]
      audio_url = params[:audio_url].blank? ? "" : params[:audio_url]
      timestamp = params[:timestamp].blank? ? nil : params[:timestamp].to_f
      message = current_user.first_name + " sent you a whisper"   
      venue_id = nil

      target_user = User.find_user_by_unique(target_id)

      if target_user
        time_1 = Time.now
        result = WhisperNotification.send_message(target_user.id, current_user, venue_id, notification_type, intro, message, timestamp, content_type, image_url, audio_url, client_side_id)
        time_2 = Time.now
        if result['message'] == "true"
          whisper = result['whisper']
          read_messages = false
          # result = whisper.chatting_replies(current_user, nil, nil, read_messages)

          whispers_json = Conversation.conversations_to_json([whisper], current_user)
          whisper_json = whispers_json.first
          time_3 = Time.now
          puts "Preparing Time: " + (time_1 - time_0).inspect
          puts "Sending Time: " + (time_2 - time_1).inspect
          puts "Json Time: " + (time_3 - time_2).inspect
          # whisper_json[:messages] = result['messages']
          render json: success(whisper_json, 'data')
        else
          error_obj = {
            code: 403,
            message: result['message']
          }
          if result['message'] != "User blocked"
            error_obj[:external_message] = result['message']
          end
          render json: error(error_obj, 'error')
        end  
      else
        # :nocov:
        error_obj = {
          code: 404,
          message: 'Cannot find the user'
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end

    def destroy
      whisper_id = params[:id]
      if !/\A\d+\z/.match(whisper_id.to_s)
        whisper = Conversation.find_by_dynamo_id(whisper_id)
      else
        whisper = Conversation.find_pending_whisper(whisper_id.to_i, current_user.id)
      end
      if whisper.blank?
        error_obj = {
          code: 404,
          message: "Sorry, cannot find the whisper"
        }
        render json: error(error_obj, 'error')
      else

        if current_user.id != whisper.origin_user_id and current_user.id != whisper.target_user_id
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        elsif BlockUser.check_block(whisper.origin_user_id.to_i, whisper.target_user_id.to_i)
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        elsif whisper.photo_disabled(current_user.id)
          error_obj = {
            code: 403,
            message: "Sorry, you don't have access to it"
          }
          render json: error(error_obj, 'error')
        else
          if Rails.env == 'production'
            # :nocov:
            # WhisperNotification.delay.find_whisper(whisper.dynamo_id, 'declined')
            whisper.archive_conversation(current_user)
            # :nocov:
          else
            # WhisperNotification.find_whisper(whisper.dynamo_id, 'declined')
            whisper.archive_conversation(current_user)
          end
          
          render json: success
        end
      end
    end


    def get_api_token
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        # :nocov:
        params[:token] = api_token 
        # :nocov:
      end
    end
  end
end