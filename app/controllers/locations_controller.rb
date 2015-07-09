class LocationsController < ApplicationController
  prepend_before_filter :get_api_token
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  def create
    # Add && params[:timezone].present? when we are doing timezones
    if current_user && params[:latitude].present? && params[:longitude].present? && params[:timezone].present?
      # location_history = current_user.locations.new(
      #   latitude: params[:latitude].to_f,
      #   longitude: params[:longitude].to_f)
      #TODO: move the data in this table to DynamoDB
      user = current_user
      user.latitude = params[:latitude].to_f
      user.longitude = params[:longitude].to_f

      puts 'current_user'
      puts current_user

      puts 'long and lat'
      puts user.latitude
      puts user.longitude

      if user.save and UserLocation.find_if_user_exist(current_user.id, user.latitude, user.longitude, params[:timezone])
        render json: success
      # elsif location_history.save && user.save
      elsif user.save and UserLocation.create_in_aws(user, params[:latitude].to_f, params[:longitude].to_f, params[:timezone])
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
  private
  def get_api_token
    if api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
      params[:token] = api_token
    end
  end
end