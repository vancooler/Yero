class VenuesController < ApplicationController

  before_action :authenticate_venue!, only: [:tonightly, :nightly, :pick_winner, :lottery_dash, :claim_drink]
  before_action :authenticate_api, only: [:list]

  def nightly
    @nightlies = current_venue.nightlies.order("created_at DESC")
  end

  def tonightly
    nightly = Nightly.today_or_create(current_venue)
    redirect_to show_nightly_path(nightly.id)
  end

  def lottery
    @winners = current_venue.winners.order("created_at DESC").first(5)
    @participants = current_venue.participants.all
  end

  def pick_winner
    participants = current_venue.participants.all

    if participants.size > 0
      recipient = participants.sample
      winner = Winner.new
      winner.user = recipient.user
      winner.message = "You've won a free drink under $10!  Go to any bar to claim your drink.  Winner ID: #{}"
      winner.venue = recipient.room.venue
      winner.save

      winner.send_notification
    end

    redirect_to lotto_path
  end

  def lottery_dash
    @winners = current_venue.winners.where(claimed: false).order("created_at ASC").all
  end

  def claim_drink
    winner = current_venue.winners.where(winner_id: params[:winner_id]).first

    if winner
      winner.claimed = true
      winner.save
    end

    redirect_to lotto_dash_path
  end

  # API

  def list
    venues = Venue.all

    if params[:after]
      new_list = []

      venues.each do |v|
        if v.tonightly.updated_at > Time.at(params[:after].to_i)
          new_list << v
        end
      end

      venues = new_list
    end

    data = Jbuilder.encode do |json|
      json.array! venues do |v|
        json.name v.name
        json.address v.address_line_one

        json.nightly do
          nightly = Nightly.today_or_create(v)
          json.boy_count nightly.boy_count
          json.girl_count nightly.girl_count
          json.guest_wait_time nightly.guest_wait_time
          json.regular_wait_time nightly.regular_wait_time
        end
      end
    end

    render json: {
      list: JSON.parse(data)
    }
  end
end
