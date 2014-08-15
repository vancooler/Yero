class LocationsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  def create
    if current_user && params[:latitude].present? && params[:latitude].present?
      location = current_user.locations.new(
        latitude: params[:latitude].to_i,
        longitude: params[:longitude].to_i)
      if location.save
        render json: success
      end
    else
      render json: error("Invalid request.")
    end

  end
end