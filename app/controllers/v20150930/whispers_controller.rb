module V20150930
  class WhispersController < ApplicationController
    prepend_before_filter :get_api_token, only: [:create, :index, :update, :destroy, :show]
    before_action :authenticate_api_v2, only: [:create, :index, :update, :destroy, :show]

    def index
      badge = WhisperNotification.unviewd_whisper_number(current_user.id)
      whispers = WhisperToday.whispers_related(current_user.id)

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
              # :nocov:
              current_user.delay.viewed_by_sender(whispers_array)
              # :nocov:
            end
          end
        end
      end
      if badge[:friend_number].to_i > 0
        # update local tmp db
        FriendByWhisper.where(:origin_user_id => current_user.id).update_all(:viewed => true)
        # update dynamodb
        if Rails.env == 'production'
          # :nocov:
          WhisperNotification.delay.accept_friend_viewed_by_sender(current_user.id)
          # :nocov:
        end
      end

      response_data = {
        badge_number: badge,
        whispers: whispers
      }
      render json: success(response_data, "data")
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
            render json: error(error_obj, 'error')
            # :nocov:
          end
        end
      end
    end

    

    # Create a whisper
    def create
      target_id = params[:target_id]
      venue_id = params[:venue_id].nil? ? 0 : params[:venue_id]
      notification_type = params[:notification_type].to_s
      intro = params[:intro].blank? ? "" : params[:intro].to_s
      message = current_user.first_name + " just sent you a whisper"   
      
      result = WhisperNotification.send_whisper(target_id, current_user, venue_id, notification_type, intro, message)

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
    end


    # accept/decline a whisper
    def update
      whisperId = params[:id]

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
          if !item.nil?
            origin_id = item.origin_user_id.to_i
            target_id = item.target_user_id.to_i
            venue_id = item.venue_id.nil? ? 0 : item.venue_id.to_i
          end
          if origin_id.to_i <= 0 
            # :nocov:
            error_obj = {
              code: 404,
              message: "Sorry, cannot find the whisper"
            }
            render json: error(error_obj, 'error')
            # :nocov:
          else
            if FriendByWhisper.check_friends(origin_id, target_id) 
              # :nocov:
              error_obj = {
                code: 403,
                message: "You are already friends."
              }
              render json: error(error_obj, 'error')
              # :nocov:
            elsif BlockUser.check_block(origin_id, target_id)
              error_obj = {
                code: 403,
                message: "User blocked"
              }
              render json: error(error_obj, 'error')
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
                  WhisperReply.delay.archive_history(item)
                  # :nocov:
                else
                  WhisperReply.where(whisper_id: item.id).delete_all
                  item.delete
                end
                render json: success
              else
                # :nocov:
                error_obj = {
                  code: 520,
                  message: "Sorry cannot execute the action"
                }
                render json: error(error_obj, 'error')
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
          # :nocov:
          error_obj = {
            code: 520,
            message: "Sorry cannot execute the action"
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      else
        error_obj = {
          code: 404,
          message: "Sorry, cannot find the whisper"
        }
        render json: error(error_obj, 'error')
      end
    end

    def destroy
      if params[:array].blank?
        error_obj = {
          code: 400,
          message: "Invalid Parameters"
        }
        render json: error(error_obj, 'error')
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
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        params[:token] = api_token 
      end
    end
  end
end