module V20150930
  class RoomsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    def user_enter

      beacon_key = [params[:id]]
      beacons = Beacon.where(key: beacon_key)

      if beacons.blank? or beacons.length <= 0
        error_obj = {
          code: 404,
          message: "Venue cannot be found"
        }
        render json: error(error_obj, 'error')
      else
        beacons = beacon_key.collect {|key| beacons.detect {|x| x.key == key}}
        result = true
        beacons.each do |beacon|
          result_tmp = ActiveInVenue.enter_venue(beacon.venue, current_user, beacon)
          if result_tmp
            VenueEntry.unique_enter(beacon.venue, current_user)
          end
          result = result && result_tmp
          first_entry_flag = 0
          n2 = true
          

        end

        if result 
          render json: success("Success")
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot enter the venue."
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      end


    end

    def user_leave
        result = ActiveInVenue.leave_venue(nil, current_user)

        if result
          render json: success
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot leave venues."
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      # end
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