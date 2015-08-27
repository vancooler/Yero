class RoomsController < ApplicationController
  prepend_before_filter :get_api_token
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  # When a user enters a room, we need to create a new participant.
  # Participants tell us who is in what Venue/Venue Network
  def user_enter
    if params[:beacon_key].kind_of?(Array)
      beacon_key = params[:beacon_key].to_a
    else
      beacon_key = [params[:beacon_key]]
    end
    beacons = Beacon.where(key: beacon_key)

    if beacons.blank? or beacons.length <= 0
      render json: error("Could not enter.")
      # beacon = BeaconInitialization.new(params[:beacon_key])
      # beacon.create
      # beacon = Beacon.find_by(key: params[:beacon_key])
    else
      beacons = beacon_key.collect {|key| beacons.detect {|x| x.key == key}}
      # beacon.temperatures.create(celsius: params[:temperature].to_i) if params[:temperature].present?
      result = true
      #log the last active time for venue and venue network
      beacons.each do |beacon|
        result_tmp = ActiveInVenue.enter_venue(beacon.venue, current_user, beacon)
        result = result && result_tmp
        #log in aws dynamoDB
        # UserActivity.create_in_aws(current_user, "Enter Beacon", "Beacon", beacon.id)
        first_entry_flag = 0
        n2 = true
        # #check whether the user entered this venue today, if not push greeting notification
        # if VenueEnteredToday.enter_venue_today(beacon.venue, current_user)
        #   first_entry_flag = 1
        #   p "venue message"
        #   venue_message = "Welcome to " + beacon.venue.name + "! Open this to learn more about tonight."
        #   p venue_message
        #   n2 = WhisperNotification.create_in_aws(current_user.id, 0, beacon.venue.id, "1", venue_message)
        #   p "n2"
        #   p n2.inspect
        #   # number of notification to read for this user: +1
        #   if current_user.notification_read.nil? or current_user.notification_read == 0
        #     current_user.notification_read = 1
        #   else
        #     current_user.notification_read += 1
        #   end
        #   current_user.save
        #   n2.send_push_notification_to_target_user(venue_message)
        # end

      end

      if result 
        render json: success("Success")
      else
        render json: error("Could not enter.")
      end
    end



    # activity_item = ActivityItem.new(current_user, beacon, "Enter Beacon")
    # if activity_item.create
    #   render json: success
    # else
    #   render json: error("Could not log entry.")
    # end


    # temperature = params[:temperature]
    #   if beacon
    #         activity_item.create
    #         room = beacon.room
    #         if room
    #           participant = Participant.where(user: current_user).where(room_id: room.id).first
    #           if participant
    #             participant.temperature = temperature
    #             participant.room = room
    #             participant.last_activity = Time.now
    #             participant.enter_time = Time.now
    #             participant.save!
    #           else
    #             Participant.enter_room(room, current_user, temperature)
    #           end

    #           render json: success(room.venue.to_json)
    #         else
    #           render json: error("Room does not exist")
    #         end
    #   else
    #     render json: error("Beacon does not exist")
    #   end
  end

  def user_leave
    # beacons = Beacon.where(:key => params[:beacon_key])
    # if beacons.blank? or beacons.length <= 0
    #   render json: error("Could not leave.")
    # else

      result = ActiveInVenue.leave_venue(nil, current_user)
      #log in aws dynamoDB
      # UserActivity.create_in_aws(current_user, "Leave Beacon", "Beacon", beacon.id)

      if result
        render json: success
      else
        render json: error("Could not leave.")
      end
    # end
  end

  private

  def get_api_token
    if api_token = params[:token].blank? && request.headers["X-API-TOKEN"]
      params[:token] = api_token
    end
  end
end