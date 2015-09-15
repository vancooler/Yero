module V20150930
  class ActivitiesController < ApplicationController
  	prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    # Activity history
    def index
      page_number = nil
      venues_per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      activities_per_page = params[:per_page].to_i if !params[:per_page].blank?

      activities = RecentActivity.all_activities(current_user.id).length
      if !page_number.nil? and !activities_per_page.nil? and activities_per_page > 0 and page_number >= 0
        pagination = Hash.new
        pagination['page'] = page_number - 1
        pagination['per_page'] = activities_per_page
        pagination['total_count'] = activities
      end
      items = WhisperNotification.my_chat_request_history(current_user, page_number, activities_per_page)
      render json: success(items, 'data', pagination)
    end

    def destroy
      activity = RecentActivity.find_by(target_user_id: current_user.id, id: params[:id])
      if activity.nil?
        error_obj = {
          code: 404,
          message: "Activity cannot be found",
          external_message: ''
        }
        render json: error(error_obj, 'error')
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
          render json: error(error_obj, 'error')
          # :nocov:
        end

      end
    end

    def get_api_token
      params[:token] = api_token if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
    end

  end
end