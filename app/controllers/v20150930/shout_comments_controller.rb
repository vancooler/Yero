module V20150930
  class ShoutCommentsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    # create a comment to a shout
    def create
      # content_type = params[:content_type].blank? ? "text" : params[:content_type]
      image_url = params[:image_url].blank? ? "" : params[:image_url]
      image_thumb_url = params[:image_thumb_url].blank? ? "" : params[:image_thumb_url]
      audio_url = params[:audio_url].blank? ? "" : params[:audio_url]

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
    end

    # retrieve comments with comment filter and order
    def index

      page = nil
      per_page = nil
      page = params[:page].to_i + 1 if !params[:page].blank?
      per_page = params[:per_page].to_i if !params[:per_page].blank?

      result = ShoutComment.list(current_user, params[:shout_id], page, per_page)
      response = {
        shout_comments: result['shout_comments']
      }
      render json: success(response, "data", result['pagination'])
    end

    # upvote or downvote
    def update
      shout_comment = ShoutComment.find_by_id(params[:id])
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
      shout_comment = ShoutComment.find_by_id(params[:shout_comment_id])
      report_type = ShoutReportType.find_by_id(params[:report_type_id])
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