class LocationsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  def create
    if current_user && params[:latitude].present? && params[:longitude].present?
      location_for_analytics = current_user.locations.new(
        latitude: params[:latitude].to_i,
        longitude: params[:longitude].to_i)
      
      user = current_user
      user.latitude = params[:latitude].to_i
      user.longitude = params[:longitude].to_i

      if location.save && user.save
        render json: success
      else
        render json: error("Could not save location.")
      end
    else
      render json: error("Invalid data request.")
    end
  end
  def show
    if current_user && current_user.location.any?
      render json: current_user.location.last
    else
      render json: error("User or Location cannot be found.")
    end
  end
end