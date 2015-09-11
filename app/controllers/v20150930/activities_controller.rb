module V20150930
  class ActivitiesController < ApplicationController
  	prepend_before_filter :get_api_token, only: [:index]
    before_action :authenticate_api_v2, only: [:index]

    # Activity history
    def index
      page_number = nil
      venues_per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      whispers_per_page = params[:per_page].to_i if !params[:per_page].blank?

      items = WhisperNotification.my_chat_request_history(current_user, page_number, whispers_per_page)
      render json: success(items)
    end

    def destroy
      activity = RecentActivity.find_by(target_user_id: current_user.id, id: params[:id])
      if activity.nil?
        error_obj = {
          code: 404,
          message: "Activity cannot be found",
          external_message: ''
        }
        render json: error(error_obj, 'data')
      else
        if activity.destroy
          render json: success(true)
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot delete the activity.",
            external_message: ''
          }
          render json: error(error_obj, 'data')
          # :nocov:
        end

      end
    end

    def get_api_token
      params[:token] = api_token if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
    end

  end
end