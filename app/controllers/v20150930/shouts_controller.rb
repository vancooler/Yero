module V20150930
  class ShoutsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    # show a shout
    def show
      shout = Shout.find_by_id(params[:id])
      if shout
        page = 1
        per_page = 24
        page = params[:page].to_i + 1 if !params[:page].blank?
        per_page = params[:per_page].to_i if !params[:per_page].blank?
        voted = ShoutVote.where(user_id: current_user.id).where(shout_id: shout.id)
        actions = Array.new
        if !voted.empty?
          if voted.first.upvote.nil?
            actions = ["upvote","downvote"]
          elsif voted.first.upvote
            actions = ["undo_upvote", "downvote"]
          else
            actions = ["upvote", "undo_downvote"]
          end
        else
          actions = ["upvote", "downvote"]
        end
        result = ShoutComment.list(current_user, shout.id, nil, nil)
        attachments = Array.new
        if !shout.image_url.blank?
          image = {
            attachment_type: "image",
            image_url:       shout.image_url.nil? ? '' : shout.image_url,
            image_thumb_url: shout.image_thumb_url.nil? ? '' : shout.image_thumb_url,
          }
          attachments << image
        end
        if !shout.audio_url.blank?
          audio = {
            attachment_type: "audio",
            audio_url:       shout.audio_url.nil? ? '' : shout.audio_url
          }
          attachments << audio
        end
        shout_json = {
          id:                   shout.id,
          body:                 shout.body,
          anonymous:            shout.anonymous,
          exclusive:            !shout.allow_nearby,
          latitude:             shout.latitude,
          longitude:            shout.longitude,
          locality:             shout.city.nil? ? '' : shout.city,
          # content_type:         shout.content_type.nil? ? 'text' : shout.content_type,
          # audio_url:            shout.audio_url.nil? ? '' : shout.audio_url,
          # image_url:            shout.image_url.nil? ? '' : shout.image_url,
          attachments:          attachments,
          subLocality:          shout.neighbourhood.nil? ? '' : shout.neighbourhood,
          timestamp:            shout.created_at.to_i,
          expire_timestamp:     shout.created_at.to_i+7*24*3600,
          total_upvotes:        shout.total_upvotes,
          actions:              actions,
          count:                result['shout_comments'].length,
          shout_comments:       result['shout_comments'],
          network_gimbal_key:   ((shout.venue.nil? or shout.venue.beacons.empty?) ? '' : shout.venue.beacons.first.key),
          author_id:            shout.user_id,
          author_username:      (User.find_by_id(shout.user_id).nil? ? "" : User.find_by_id(shout.user_id).username)
        }
        # response = {
        #   shout:          shout_json,
        #   shout_comments: result['shout_comments'],
        #   pagination:     result['pagination']
        # }
        render json: success(shout_json)
      else
        # :nocov:
        error_obj = {
          code: 404,
          message: "Cannot find the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end


    # create a shout
    def create
      venue = (params[:venue].blank? ? nil : params[:venue])
      # content_type = params[:content_type].blank? ? "text" : params[:content_type]
      image_url = params[:image_url].blank? ? "" : params[:image_url]
      image_thumb_url = params[:image_thumb_url].blank? ? "" : params[:image_thumb_url]
      audio_url = params[:audio_url].blank? ? "" : params[:audio_url]
      latitude = nil
      longitude = nil
      if !params[:latitude].blank? 
        latitude = params[:latitude].to_f
      end
      if !params[:longitude].blank? 
        longitude = params[:longitude].to_f
      end
      anonymous = (!params['anonymous'].nil? ? (params['anonymous'].to_s == '1' or params['anonymous'].to_s == 'true') : true)
      exclusive = (!params['exclusive'].nil? ? (params['exclusive'].to_s == '1' or params['exclusive'].to_s == 'true') : false)
      
      shout = Shout.create_shout(current_user, params[:body], exclusive, anonymous, image_url, image_thumb_url, audio_url, latitude, longitude)
      if shout
        # Pusher later
        render json: success(shout)
      else
        # :nocov:
        error_obj = {
          code: 520,
          message: "Cannot create the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end

    # retrieve shouts with venue filter and order
    def index
      page = nil
      per_page = nil
      page = params[:page].to_i + 1 if !params[:page].blank?
      per_page = params[:per_page].to_i if !params[:per_page].blank?
      latitude = current_user.latitude
      longitude = current_user.longitude
      if !params[:latitude].blank? 
        latitude = params[:latitude].to_f
      end
      if !params[:longitude].blank? 
        longitude = params[:longitude].to_f
      end

      result = Shout.list(current_user, params[:order_by], params[:venue], params[:my_shouts], params[:my_comments], page, per_page, latitude, longitude)
      response = {
        shouts: result['shouts']
      }
      render json: success(response, "data", result['pagination'])
    end

    # upvote or downvote
    def update
      shout = Shout.find_by_id(params[:id])
      result = shout.change_vote(current_user, params[:upvote])

      if result[:result]
        # Pusher later
        render json: success
      else
        # :nocov:
        error_obj = {
          code: 520,
          message: "Cannot update the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end

    # delete a shout
    def destroy
      shout = Shout.find_by_id(params[:id])
      if shout.user_id == current_user.id
        if shout.destroy_single
          render json: success
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot delete this shout"
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      else
        error_obj = {
          code: 403,
          message: "You are not the author of this shout"
        }
        render json: error(error_obj, 'error')
      end
    end

    # report a shout
    def report
      shout = Shout.find_by_id(params[:shout_id])
      report_type = ShoutReportType.find_by_id(params[:report_type_id])
      if shout and report_type
        shout.report(current_user, report_type.id)
        render json: success
      else
        # :nocov:
        error_obj = {
          code: 520,
          message: "Cannot report the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end





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