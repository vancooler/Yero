module V20150930
  class ShoutCommentsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    # create a comment to a shout
    def create
      shout_comment = ShoutComment.create_shout_comment(current_user, params[:body], params[:shout_id])
      if shout_comment
        # Pusher later
        render json: success
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
      list = ShoutComment.list(current_user, params[:shout_id])
      render json: success(list)
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

    def destroy
      shout_comment = ShoutComment.find_by_id(params[:id])
      if shout_comment.user_id == current_user.id
        shout_comment.shout_comment_votes.delete_all
        shout_comment.delete
        # Pusher later
        render json: success
      else
        error_obj = {
          code: 403,
          message: "You are not the author of this comment"
        }
        render json: error(error_obj, 'error')
      end
    end

    def report

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