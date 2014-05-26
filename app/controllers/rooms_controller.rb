class RoomsController < ApplicationController
  before_action :authenticate_api
  skip_before_filter  :verify_authenticity_token

  def user_enter
    room = Beacon.find_by_key(params[:beacon_key]).room
    p = Participant.where(room: room, user: current_user).first

    if room
      if p
        p.room = room
        p.last_activity = Time.now
        p.enter_time = Time.now
        p.save!
      else
        Participant.enter_room(room, current_user)
      end

      render json: success(room.venue.to_json)
    else
      render json: error("Room does not exist")
    end
  end

  def user_leave
    p = Participant.find_by_user_id(current_user.id)

    if p
      p.delete
      render json: success(nil)
    else
      render json: error("Participant does not exist")
    end
  end
end