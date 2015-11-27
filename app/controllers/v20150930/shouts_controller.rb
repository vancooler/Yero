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
        replied = false
        if !shout.shout_comments.where(user_id: current_user.id).empty?
          replied = true
        end
        shout_json = {
          id:                   shout.id,
          body:                 shout.body,
          anonymous:            shout.anonymous,
          exclusive:            !shout.allow_nearby,
          latitude:             shout.latitude,
          longitude:            shout.longitude,
          locality:             shout.city.nil? ? '' : shout.city,
          replied:              replied,
          shout_banner_image_url: ((shout.shout_banner_image.nil? or shout.shout_banner_image.avatar.nil? or shout.shout_banner_image.avatar.url.nil?) ? '' : shout.shout_banner_image.avatar.url), 
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
          network_gimbal_key:   ((shout.venue.nil? or shout.venue.gimbal_name.empty?) ? '' : shout.venue.gimbal_name),
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
        current_user.latitude = params[:latitude].to_f
      end
      if !params[:longitude].blank? 
        current_user.longitude = params[:longitude].to_f
      end

      if !params[:locality].blank?
        current_user.current_city = params[:locality]
      else
        current_user.current_city = ""
      end

      if !params[:subLocality].blank?
        current_user.current_sublocality = params[:subLocality]
      else
        current_user.current_sublocality = ""
      end

      current_user.save!

      # network status update
      in_network = false
      # check colleges
      if !params[:network_id].nil?
        network = Venue.find_venue_by_unique(params[:network_id])
        if !network.nil? and !network.beacons.empty?
          ActiveInVenue.enter_venue(network, current_user, network.beacons.first)
          in_network = true
        else
          # FutureCollege.unique_enter(p, user)
        end
      end

      if !in_network
        ActiveInVenue.leave_venue(nil, current_user)
      end

      anonymous = (!params['anonymous'].nil? ? (params['anonymous'].to_s == '1' or params['anonymous'].to_s == 'true') : true)
      exclusive = (!params['exclusive'].nil? ? (params['exclusive'].to_s == '1' or params['exclusive'].to_s == 'true') : false)
      
      shout = Shout.create_shout(current_user, params[:body], exclusive, anonymous, image_url, image_thumb_url, audio_url)
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
        current_user.latitude = params[:latitude].to_f
      end
      if !params[:longitude].blank? 
        current_user.longitude = params[:longitude].to_f
      end

      current_user.save

      # network status update
      in_network = false
      # check colleges
      if !params[:places].nil?
        places = params[:places].to_a
        places.each do |p|
          if p == 'The University Of British Columbia (Ubc)'
            p = 'Vancouver_UBC_test'
          elsif p == 'Simon Fraser University (Sfu)'
            p = 'Vancouver_SFU_test'
          end
          beacon = Beacon.find_by_key(p)
          if !beacon.nil? and !beacon.venue.nil?
            ActiveInVenue.enter_venue(beacon.venue, current_user, beacon)
            in_network = true
          else
            # FutureCollege.unique_enter(p, user)
          end
        end
      end

      if params[:horizontal_accuracy].nil?
        horizontal_accuracy = 0
      else
        horizontal_accuracy = (params[:horizontal_accuracy].to_f / 110000.0)
      end
      # check other networks
      if !:+current_user.latitude.nil? and !current_user.longitude.nil?
        # check festival networks
        venue = Venue.user_inside(current_user.latitude, current_user.longitude, horizontal_accuracy)
        if !venue.nil? and !venue.beacons.blank?
          ActiveInVenue.enter_venue(venue, current_user, venue.beacons.first)
          in_network = true
        end
      end

      if !in_network
        ActiveInVenue.leave_venue(nil, current_user)
      end

      my_shouts = (!params['my_shouts'].nil? ? (params['my_shouts'].to_s == '1' or params['my_shouts'].to_s == 'true') : false)
      my_comments = (!params['my_comments'].nil? ? (params['my_comments'].to_s == '1' or params['my_comments'].to_s == 'true') : false)
      if params[:order_by].nil?
        order_by = 'new'
      else
        order_by = params[:order_by]
      end
      result = Shout.list(current_user, order_by, params[:venue], params[:city], my_shouts, my_comments, page, per_page)
      if result['percentage'].nil?
        response = {
          shouts: result['shouts']
        }
        deleted_ids = Shout.deleted_ids
        render json: success(response, "data", result['pagination'], deleted_ids, "Shout")
      else
        render json: success(result)
      end
    end

    # upvote or downvote
    def update
      shout = Shout.find_by_id(params[:id])
      if !shout.nil?
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
      else
        if !DeletedObject.where(deleted_object_id: params[:id].to_i).where(deleted_object_type: "Shout").empty?
          # :nocov:
          error_obj = {
            code: 409,
            message: "Shout was deleted."
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
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