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
        distance = 60
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
      result = Array.new

      # venues nearby
      nearby_venues = Venue.nearby_networks(latitude, longitude, distance)
      # puts latitude
      # puts longitude
      # puts distance
      # puts nearby_venues.inspect
      if !nearby_venues.blank?
        nearby_obj = {
          title: "NEARBY",
          total: nearby_venues.length
        }
        if !nearby_venues.first.venue_avatars.blank? and !nearby_venues.first.venue_avatars.first.avatar.nil?  and !nearby_venues.first.venue_avatars.first.avatar.url.nil?
          nearby_obj[:image] = nearby_venues.first.venue_avatars.first.avatar.url
        end
        result << nearby_obj
      end

      # Colleges
      colleges = Venue.colleges(latitude, longitude)
      if !colleges.blank?
        college_obj = {
          title: "COLLEGES",
          total: colleges.length
        }
        if  !colleges.first.venue_avatars.blank? and !colleges.first.venue_avatars.first.avatar.nil?  and !colleges.first.venue_avatars.first.avatar.url.nil?
          college_obj[:image] = colleges.first.venue_avatars.first.avatar.url
        end
        result << college_obj
      end

      # Stadiums
      stadiums = Venue.stadiums(latitude, longitude)
      if !stadiums.blank?
        stadium_obj = {
          title: "STADIUMS",
          total: stadiums.length
        }
        if  !stadiums.first.venue_avatars.blank? and !stadiums.first.venue_avatars.first.avatar.nil?  and !stadiums.first.venue_avatars.first.avatar.url.nil?
          stadium_obj[:image] = stadiums.first.venue_avatars.first.avatar.url
        end
        result << stadium_obj
      end

      # Festivals
      festivals = Venue.festivals(latitude, longitude)
      if !festivals.blank?
        festival_obj = {
          title: "FESTIVALS",
          total: festivals.length
        }
        if  !festivals.first.venue_avatars.blank? and !festivals.first.venue_avatars.first.avatar.nil?  and !festivals.first.venue_avatars.first.avatar.url.nil?
          festival_obj[:image] = festivals.first.venue_avatars.first.avatar.url
        end
        result << festival_obj
      end

      # Nightlife
      nightlifes = Venue.nightlifes(latitude, longitude)
      if !nightlifes.blank?
        nightlife_obj = {
          title: "NIGHTLIFE",
          total: nightlifes.length
        }
        if  !nightlifes.first.venue_avatars.blank? and !nightlifes.first.venue_avatars.first.avatar.nil?  and !nightlifes.first.venue_avatars.first.avatar.url.nil?
          nightlife_obj[:image] = nightlifes.first.venue_avatars.first.avatar.url
        end
        result << nightlife_obj
      end

      render json: success(result)
    end

    # List of venues
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

      data = Venue.venues_object(venues)
      
      render json: success((JSON.parse data), 'data', pagination)
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