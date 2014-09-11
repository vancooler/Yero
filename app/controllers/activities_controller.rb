class ActivitiesController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token
  
  respond_to :json
  
  def show
    current_user.last_active = Time.now
    current_user.save
    activity = current_user.last_active
    if activity.present?
      #render json: success(activity)
      render json: success((activity - Time.new('1970')).seconds.to_i)
    else
      render json: error("No Activity Found.")
    end
  end
end