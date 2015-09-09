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

    def get_api_token
      params[:token] = api_token if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
    end

  end
end