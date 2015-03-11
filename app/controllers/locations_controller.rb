class LocationsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  def create
    if current_user && params[:latitude].present? && params[:longitude].present?
      # location_history = current_user.locations.new(
      #   latitude: params[:latitude].to_f,
      #   longitude: params[:longitude].to_f)
      #TODO: move the data in this table to DynamoDB
      user = current_user
      user.latitude = params[:latitude].to_f
      user.longitude = params[:longitude].to_f

      if user.save and UserLocation.find_if_user_exist(current_user.id, user.latitude, user.longitude)
        render json: success
      # elsif location_history.save && user.save
      elsif user.save and UserLocation.create_in_aws(user, params[:latitude].to_f, params[:longitude].to_f)
        render json: success
      else
        render json: error("Could not save location.")
      end
    else
      render json: error("Invalid data request.")
    end
  end
  def show
    if current_user #&& current_user.location.any?
      location = {
        latitude:current_user.latitude,
        longitude:current_user.longitude,
      }

      render json: location

    else
      render json: error("User or Location cannot be found.")
    end
  end
end