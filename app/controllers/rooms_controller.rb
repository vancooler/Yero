class RoomsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  # When a user enters a room, we need to create a new participant.
  # Participants tell us who is in what Venue/Venue Network
  def user_enter
    beacon = Beacon.find_by(key: params[:beacon_key])
    if beacon.blank?
      beacon = BeaconInitialization.new(params[:beacon_key])
      beacon.create
    end
    beacon.temperatures.create(celsius: params[:temperature].to_i) if params[:temperature].present?
    
    activity_item = ActivityItem.new(current_user, beacon, "Enter Beacon")
    
    #log the last active time for venue and venue network
    ActiveInVenue.enter_venue(beacon.room.venue, current_user)

    #log in aws dynamoDB
    UserActivity.create_in_aws(current_user, "Enter Beacon", "Beacon", beacon.id)
    
    if VenueEnteredToday.enter_venue_today(beacon.room.venue, current_user)
      WhisperNotification.create_in_aws(current_user.id, 0, beacon.room.venue.id, "Enter Greeting")
      greeting_message = "Welcome " + current_user.first_name + "!"
      venue_message = "welcome to " + beacon.room.venue.name + "!"
      WhisperNotification.create_in_aws(current_user.id, 0, beacon.room.venue.id, "Enter Venue Greeting")
      # WhisperNotification.send_push_notification_to_target_user(greeting_message)
      # WhisperNotification.send_push_notification_to_target_user(venue_message)
    end
    if activity_item.create
      render json: success
    else
      render json: error("Could not log entry.")
    end
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
    beacon = Beacon.find_or_create_by(key: params[:beacon_key]) 
    
    ActiveInVenue.leave_venue(beacon.room.venue, current_user)
    activity_item = ActivityItem.new(current_user, beacon, "Leave Beacon")
    #log in aws dynamoDB
    UserActivity.create_in_aws(current_user, "Leave Beacon", "Beacon", beacon.id)
    if activity_item.create
      render json: success(beacon.to_json)
    else
      render json: error("Could not log leaving.")
    end

    # participant = Participant.find_by_user_id(current_user.id)

    # if participant
    #   participant.delete
    #   render json: success(nil)
    # else
    #   render json: error("Participant does not exist")
    # end
  end
end