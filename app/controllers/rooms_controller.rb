class RoomsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  # When a user enters a room, we need to create a new participant.
  # Participants tell us who is in what Venue/Venue Network
  def user_enter
    beacon = Beacon.find_by(key: params[:beacon_key])
    temperature = params[:temperature]

      if beacon
            room = beacon.room
            if room
              participant = Participant.where(user: current_user).where(room_id: room.id).first
              if participant
                participant.temperature = temperature
                participant.room = room
                participant.last_activity = Time.now
                participant.enter_time = Time.now
                participant.save!
              else
                Participant.enter_room(room, current_user, temperature)
              end

              render json: success(room.venue.to_json)
            else
              render json: error("Room does not exist")
            end
      else
        render json: error("Beacon not found")
      end
  end

  def user_leave
    participant = Participant.find_by_user_id(current_user.id)

    if participant
      participant.delete
      render json: success(nil)
    else
      render json: error("Participant does not exist")
    end
  end
end