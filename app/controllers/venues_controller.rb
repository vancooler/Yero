class VenuesController < ApplicationController

  before_action :authenticate_venue!

  def tonightly
    nightly = Nightly.order('created_at DESC').first

    if !nightly || !nightly.is_for_today
      nightly = Nightly.new
      nightly.venue = current_venue
      nightly.save!
    end

    redirect_to show_nightly_path(nightly.id)
  end
end
