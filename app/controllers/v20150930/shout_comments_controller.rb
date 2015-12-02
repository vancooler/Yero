module V20150930
  class ShoutCommentsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    # create a comment to a shout
    def create
      # content_type = params[:content_type].blank? ? "text" : params[:content_type]
      shout = Shout.find_by_id(params[:shout_id])
      if !shout.nil?
        image_url = params[:image_url].blank? ? "" : params[:image_url]
        image_thumb_url = params[:image_thumb_url].blank? ? "" : params[:image_thumb_url]
        audio_url = params[:audio_url].blank? ? "" : params[:audio_url]

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

        shout_comment = ShoutComment.create_shout_comment(current_user, params[:body], params[:shout_id], image_url, image_thumb_url, audio_url)
        if shout_comment
          # Pusher later
          render json: success(shout_comment)
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot create the comment."
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

    # retrieve comments with comment filter and order
    def index
      shout = Shout.find_by_id(params[:shout_id])
      if !shout.nil?
        page = nil
        per_page = nil
        page = params[:page].to_i + 1 if !params[:page].blank?
        per_page = params[:per_page].to_i if !params[:per_page].blank?

        result = ShoutComment.list(current_user, params[:shout_id], page, per_page)
        response = {
          shout_comments: result['shout_comments']
        }
        deleted_ids = ShoutComment.deleted_ids
        render json: success(response, "data", result['pagination'],deleted_ids, "ShoutComment")
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

    # upvote or downvote
    def update
      shout_comment = ShoutComment.find_by_id(params[:id])
      if !shout_comment.nil?
        result = shout_comment.change_vote(current_user, params[:upvote])

        if result[:result]
          # Pusher later
          render json: success
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot update the comment."
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      else
        if !DeletedObject.where(deleted_object_id: params[:id].to_i).where(deleted_object_type: "ShoutComment").empty?
          # :nocov:
          error_obj = {
            code: 409,
            message: "Reply was deleted."
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      end
    end

    # delete a shout comment
    def destroy
      shout_comment = ShoutComment.find_by_id(params[:id])
      if shout_comment.user_id == current_user.id
        if shout_comment.destroy_single
          render json: success
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot delete this shout comment"
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      else
        error_obj = {
          code: 403,
          message: "You are not the author of this comment"
        }
        render json: error(error_obj, 'error')
      end
    end

    # report a shout comment
    def report
      if !params[:report_type_id].nil?
        report_type_id = params[:report_type_id].to_i + 1
      else
        report_type_id = 0
      end
      shout_comment = ShoutComment.find_by_id(params[:shout_comment_id])
      report_type = ShoutReportType.find_by_id(report_type_id)
      if shout_comment and report_type
        shout_comment.report(current_user, report_type.id)
        render json: success
      else
        # :nocov:
        error_obj = {
          code: 520,
          message: "Cannot report the shout comment."
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