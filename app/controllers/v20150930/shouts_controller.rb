module V20150930
  class ShoutsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    # create a shout
    def create
      shout = Shout.create_shout(current_user, params[:body], params[:allow_nearby])
      if shout
        # Pusher later
        render json: success
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

      result = Shout.list(current_user, params[:order_by], params[:venue], page, per_page)
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
        shout.shout_votes.delete_all
        shout.shout_comments.delete_all
        shout.delete
        # Pusher later
        render json: success
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