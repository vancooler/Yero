module V20150930
  class VenuesVersion2Controller < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2
    # list all the venues for this owner


    # List of venue types
    def list_types
      user = current_user
      if !params[:distance].nil? and params[:distance].to_i > 0
        distance = params[:distance].to_i
      else
        distance = 30
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

      result = Venue.collect_network_types(current_user, latitude, longitude, distance)
      
      render json: success(result)
    end

    # retrieve networks
    def index
      if params[:type].blank? 
        type = "nearby"
      else
        type = params[:type]
      end
      user = current_user
      if !params[:distance].nil? and params[:distance].to_i > 0
        distance = params[:distance].to_i
      else
        distance = 30
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

      case type
      when 'favourite'
        venues = Venue.favourite_networks(current_user)
      when 'nearby'
        venues = Venue.nearby_networks(latitude, longitude, distance)
      when 'festival'
        venues = Venue.festivals(latitude, longitude)
      when 'college'
        venues = Venue.colleges(latitude, longitude)
      when 'stadium'
        venues = Venue.stadiums(latitude, longitude)
      when 'nightlife'
        venues = Venue.nightlifes(latitude, longitude)
      end

      page_number = nil
      venues_per_page = nil
      page_number = params[:page].to_i + 1 if !params[:page].blank?
      venues_per_page = params[:per_page].to_i if !params[:per_page].blank?
      if !page_number.nil? and !venues_per_page.nil? and venues_per_page > 0 and page_number >= 0
        pagination = Hash.new
        pagination['page'] = page_number - 1
        pagination['per_page'] = venues_per_page
        pagination['total_count'] = venues.length
        venues = Kaminari.paginate_array(venues).page(page_number).per(venues_per_page) if !venues.nil?
      end

      data = Venue.venues_object(current_user, venues)
      
      render json: success(data, 'data', pagination)
    end

    def show
      user = current_user
      venue = Venue.find_venue_by_unique(params[:id])
      if venue.nil?
        error_obj = {
          code: 404,
          message: "Cannot find the venue"
        }
        render json: error(error_obj, 'error')
      else
        data = Venue.venues_object(current_user, [venue])
      
        render json: success(data.first)
      end
    end

    # List of venues
    # :nocov:
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
        pagination = Hash.new
        pagination['page'] = page_number - 1
        pagination['per_page'] = venues_per_page
        pagination['total_count'] = venues.length
        venues = Kaminari.paginate_array(venues).page(page_number).per(venues_per_page) if !venues.nil?
      end

      data = Venue.venues_object(current_user, venues)
      
      render json: success((JSON.parse data), 'data', pagination)
    end
    # :nocov:


    def add_favourite_venue
      venue = Venue.find_venue_by_unique(params[:id])
      if venue.nil?
        error_obj = {
          code: 404,
          message: "Cannot find the network"
        }
        render json: error(error_obj, 'error')

      else
        FavouriteVenue.add_record(venue, current_user)
        render json: success
      end
    end

    def remove_favourite_venue
      venue = Venue.find_venue_by_unique(params[:id])
      if venue.nil?
        error_obj = {
          code: 404,
          message: "Cannot find the network"
        }
        render json: error(error_obj, 'error')

      else
        FavouriteVenue.remove_record(venue, current_user)
        render json: success
      end
    end
   

    private
    def get_api_token
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        # :nocov:
        params[:token] = api_token 
        # :nocov:
      end
    end

  end
end