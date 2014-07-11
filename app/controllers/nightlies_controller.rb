class NightliesController < ApplicationController

  # This controller is for the backend dashboard for the Venue owners.
  # They are able to change the wait times/other live info for their venue for a particular day

  before_action :authenticate_venue!, except: [:get]

  def show
    @nightly = current_venue.nightlies.find(params[:id])
  end

  def update_guest
    @nightly = current_venue.nightlies.find(params[:id])
    @nightly.guest_wait_time = params[:time]
    if @nightly.save!
      render json: success(nil)
    end
  end

  def update_regular
    @nightly = current_venue.nightlies.find(params[:id])
    @nightly.regular_wait_time = params[:time]
    if @nightly.save!
      render json: success(nil)
    end
  end

  def increase_count
    @nightly = current_venue.nightlies.find(params[:id])

    if params[:gender] == "boy"
      @nightly.boy_count = @nightly.boy_count + 1
    elsif params[:gender] == "girl"
      @nightly.girl_count = @nightly.girl_count + 1
    end

    @nightly.save!

    data = Jbuilder.encode do |json|
      json.id @nightly.id
      json.girl_count @nightly.girl_count
      json.boy_count @nightly.boy_count
      json.guest_wait_time @nightly.guest_wait_time
      json.regular_wait_time @nightly.regular_wait_time
    end

    render json: success(JSON.parse(data))
  end

  def get
    @nightly = current_venue.nightlies.find(params[:id])

    if @nightly
      data = Jbuilder.encode do |json|
                json.id @nightly.id
                json.girl_count @nightly.girl_count
                json.boy_count @nightly.boy_count
                json.guest_wait_time @nightly.guest_wait_time
                json.regular_wait_time @nightly.regular_wait_time
              end
      render json: {
        data: JSON.parse(data)
      }
    else
      render json: error("Nightly does not exist")
    end
  end
end