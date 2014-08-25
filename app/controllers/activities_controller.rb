class ActivitiesController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token
  
  respond_to :json
  
  def show
    activity = current_user.last_activity
    if activity.present?
      render json: success(activity)
    else
      render json: error("No Activity Found.")
    end
  end
end