module V20150930
  class ConversationsController < ApplicationController
    prepend_before_filter :get_api_token, only: [:create, :index, :update, :destroy, :show]
    before_action :authenticate_api_v2, only: [:create, :index, :update, :destroy, :show]

    def index
      # badge = WhisperNotification.unviewd_whisper_number(current_user.id)
      whispers = WhisperToday.conversations_related(current_user.id)

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
        whispers = WhisperToday.conversations_to_json(whispers, current_user)
      end

      response_data = {
        # badge_number: badge,
        conversations: whispers
      }
      render json: success(response_data, "data", pagination)
    end


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
          result = whisper.chatting_replies(current_user, page_number, per_page)

          whispers_json = WhisperToday.conversations_to_json([whisper], current_user)
          whisper_json = whispers_json.first

          whisper_json[:messages] = result['messages']
          render json: success(whisper_json, 'data', result['pagination'])
        end
      end
    end


    def show_messages
      whisper_id = params[:conversation_id]
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

          result = whisper.chatting_replies(current_user, page_number, per_page)
          render json: success(result['messages'], 'data', result['pagination'])
        end
      end
    end

    

    # Create a whisper
    def create
      target_id = params[:target_id]
      notification_type = '2'
      intro = params[:message].blank? ? "" : params[:message].to_s
      message = current_user.first_name + " sent you a whisper"   
      venue_id = nil

      target_user = User.find_user_by_unique(target_id)

      if target_user
        result = WhisperNotification.send_message(target_user.id, current_user, venue_id, notification_type, intro, message)

        if result == "true"
          render json: success
        else
          error_obj = {
            code: 403,
            message: result
          }
          if result != "User blocked" and result != "You are already friends"
            error_obj[:external_message] = result 
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
        whisper = WhisperToday.find_by_dynamo_id(whisper_id)
      else
        whisper = WhisperToday.find_pending_whisper(whisper_id.to_i, current_user.id)
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
            WhisperNotification.delay.find_whisper(whisper.dynamo_id, 'declined')
            whisper.archive_conversation(current_user)
            # :nocov:
          else
            WhisperNotification.find_whisper(whisper.dynamo_id, 'declined')
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