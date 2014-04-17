class VenuesController < ApplicationController

  before_action :authenticate_venue!, only: [:tonightly]

  def tonightly
    nightly = Nightly.today_or_create(current_venue)
    redirect_to show_nightly_path(nightly.id)
  end

  def list
    venues = Venue.all

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
