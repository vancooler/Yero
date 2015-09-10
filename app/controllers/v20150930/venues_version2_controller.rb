module V20150930
  class VenuesVersion2Controller < ApplicationController
    prepend_before_filter :get_api_token, only: [:list]
    before_action :authenticate_api_v2, only: [:list]
    # list all the venues for this owner


    # API

    # List of venues
    # TODO Refactor out the JSON builder into venue.rb
    def list
      user = current_user
      if !params[:distance].nil? and params[:distance].to_i > 0
        distance = params[:distance].to_i
      else
        distance = 10000
      end
      if !params[:latitude].blank? 
        latitude = params[:latitude].to_f
      else
        latitude = user.latitude
      end
      if !params[:longitude].blank? 
        longitude = params[:longitude].to_f
      else
        longitude = user.longitude
      end

      if !params[:latitude].blank? and !params[:longitude].blank? 
        user.latitude = latitude
        user.longitude = longitude
        user.save
      end

      if !params[:without_featured_venues].blank? 
        without_featured_venues = params[:without_featured_venues]=='1'
      else
        without_featured_venues = false
      end

      # venues = Venue.all
      venues = Venue.near_venues(latitude, longitude, distance, without_featured_venues)

      page_number = nil
      venues_per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      venues_per_page = params[:per_page].to_i if !params[:per_page].blank?

      if !page_number.nil? and !venues_per_page.nil? and venues_per_page > 0 and page_number >= 0
        venues = Kaminari.paginate_array(venues).page(page_number).per(venues_per_page) if !venues.nil?
      end

      data = Venue.venues_object(venues)
      
      render json: success(JSON.parse data)
    end

   

    private
    def get_api_token
      params[:token] = api_token if (api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
    end

  end
end